# in case of note present it accepts cache
# in case of missing note and cache that is not current it checks to be sure
def currently_present_note_at(lat, lon)
  empty = '<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
</osm>'
  range = 0.025
  notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range).strip
  return true if notes != empty
  timestamp_in_h = (Time.now - CartoCSSHelper::NotesDownloader.cache_timestamp(lat, lon, range)).to_i / 60 / 60
  if timestamp_in_h > 1
    puts "note download after discarding cache (cache age was #{timestamp_in_h}h)"
    notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range, invalidate_cache: true)
  end
  return notes != empty
end

def count_entries(watchlist)
  count = 0
  watchlist.each do |entry|
    entry[:list].each do |data|
      if data[:lat].nil? || data[:lon].nil?
        raise "#{entry[:message]} has broken data"
      end
      if currently_present_note_at(data[:lat], data[:lon])
        next
      end
      count += 1
    end
  end
  return count
end

def watchlist_query(tags, lat, lon, distance)
  query = '[timeout:250][out:json];
(
  ' + CartoCSSHelper::OverpassQueryGenerator.get_query_element_to_get_location(tags, lat, lon, 'node', distance) + '
  ' + CartoCSSHelper::OverpassQueryGenerator.get_query_element_to_get_location(tags, lat, lon, 'way', distance) + '
  ' + CartoCSSHelper::OverpassQueryGenerator.get_query_element_to_get_location(tags, lat, lon, 'relation', distance) + '
);
out body;
>;
out skel qt;'
  return query
end

def get_node_database(json_obj)
  locations = {}
  json_obj["elements"].each do |entry|
    if entry["type"] == "node"
      locations[entry["id"]] = entry["lat"].to_f, entry["lon"].to_f
    end
  end
  return locations
end

def get_list(required_tags, lat = 0, lon = 0, distance_in_km = :infinity)
  distance = :infinity
  distance = if distance_in_km == :infinity
               :infinity
             else
               distance_in_km * 1000
             end
  query = watchlist_query(required_tags, lat, lon, distance)
  list = get_list_from_arbitrary_query(query, required_tags)
  return list
end

def get_list_from_arbitrary_query(query, required_tags = {})
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, "for watchlist #{required_tags}", false)

  timestamp_in_h = (Time.now - CartoCSSHelper::OverpassDownloader.cache_timestamp(query)).to_i / 60 / 60

  base = 24 * 30

  if rand(base) < timestamp_in_h
    puts "redoing #{timestamp_in_h}h old query"
    json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, "for watchlist #{required_tags}", false, invalidate_cache: true)
  end

  obj = JSON.parse(json_string)

  list = []
  locations = get_node_database(obj)
  elements = obj["elements"]

  elements.each do |entry|
    next if not_fully_matching_tag_set(entry["tags"], required_tags)
    lat, lon = nil, nil
    if entry["type"] == "way"
      lat, lon = locations[entry["nodes"][0]]
      if is_location_undefined(lat, lon, entry)
        puts "location not loaded for way"
        puts query
      end
    elsif entry["type"] == "node"
      lat = entry["lat"].to_f
      lon = entry["lon"].to_f
    else
      puts "skipped #{entry["type"]}"
      next
    end
    url = "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']}#map=17/#{lat}/#{lon}layers=N"
    if is_location_undefined(lat, lon, entry)
      next
    end
    list << { lat: lat, lon: lon, url: url }
  end
  return list
end

def is_location_undefined(lat, lon, entry)
  if lat.nil? || lon.nil?
    puts "Unexpected nil in get_list_from_arbitrary_query"
    puts entry.to_s
    return true
  end
  return false
end

def not_fully_matching_tag_set(json_response_tags, tags_in_dict)
  return true if json_response_tags.nil?
  tags_in_dict.each do |tag|
    return true if json_response_tags[tag[0]] != tag[1]
  end
  return false
end


def list_of_objects_with_this_name_part(name_part)
  watchlist = []
  name_part_query = '[out:json][timeout:250];
  (
    node["name"~"' + name_part + '"];
    way["name"~"' + name_part + '"];
    relation["name"~"' + name_part + '"];
  );
  out body;
  >;
  out skel qt;'
  return get_list_from_arbitrary_query(name_part_query)
end