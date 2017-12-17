def currently_present_note_at(lat, lon)
  # in case of note present it accepts cache
  # in case of missing note and cache that is not current it checks to be sure
  empty = '<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
</osm>'
  range = 0.025
  if CartoCSSHelper::NotesDownloader.cache_timestamp(lat, lon, range) == nil
    puts "note download (cache was not present) (note check of #{lat}, #{lon})"
  end
  notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range).strip
  return true if notes != empty
  timestamp_in_h = (Time.now - CartoCSSHelper::NotesDownloader.cache_timestamp(lat, lon, range)).to_i / 60 / 60
  if timestamp_in_h >= time_in_hours_that_forces_note_redoing
    puts "note download after discarding cache (cache age was #{timestamp_in_h}h) (note check of #{lat}, #{lon})"
    notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range, invalidate_cache: true)
  end
  return notes != empty
end

def get_history_query(type, id)
return   "[out:json];
  timeline(#{type},#{id});
  foreach(
    retro(u(t[created]))
    (
      #{type}(#{id});
      out meta;
    );
  );"
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


def count_entries(watchlist)
  count = 0
  watchlist.each do |entry|
    entry[:list].each do |data|
      if data[:lat].nil? || data[:lon].nil?
        raise "#{entry[:message]} has broken data"
      end
      count += 1
    end
  end
  return count
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

def get_list(required_tags, lat = 0, lon = 0, distance_in_km = :infinity, include_history_of_tags: false)
  puts include_history_of_tags
  puts required_tags
  distance = :infinity
  distance = if distance_in_km == :infinity
               :infinity
             else
               distance_in_km * 1000
             end
  query = watchlist_query(required_tags, lat, lon, distance)
  list = get_list_from_arbitrary_query(query, required_tags, include_history_of_tags)
  return list
end

def get_data_from_overpass(query, explanation)
  debug = false
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation, debug)
  timestamp_in_h = (Time.now - CartoCSSHelper::OverpassDownloader.cache_timestamp(query)).to_i / 60 / 60

  if time_in_hours_that_forces_query_redoing >= timestamp_in_h
    puts "not redoing #{timestamp_in_h}h old query"
    return json_string
  end

  puts "redoing #{timestamp_in_h}h old query"
  return CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation, debug, invalidate_cache: true)
end

def build_string_describing_tag_appearance_from_json_history(json_history, required_tags)
  previous_version_was_matching = false
  appeared_in = ""
  for v in json_history["elements"]
    matching = fully_matching_tag_set(v["tags"], required_tags)
    if matching and !previous_version_was_matching
      appeared_in += ", " if appeared_in != ""
      appeared_in = "appeared in " if appeared_in == ""
      appeared_in += "https://www.openstreetmap.org/changeset/#{v['changeset']}"
    end
    previous_version_was_matching = matching
  end
  return appeared_in
end

def description_of_tag_appearances_in_history(type, id, required_tags)
  # show all revisions that match and previous revision is not matchhing
  # "appeared in CHANGESET_LINK, CHANGESET_LINK, CHANGESET_LINK"
  json_history = get_json_history_representation(type, id)
  return build_string_describing_tag_appearance_from_json_history(json_history, required_tags)
end

def get_json_history_representation(type, id)
  puts "using http://dev.overpass-api.de/api_mmd - switch to normal overpass instance once possible"
  CartoCSSHelper::Configuration.set_overpass_instance_url('http://dev.overpass-api.de/api_mmd') #TEST instance, limit querries
  query = get_history_query(type, id)
  explanation = "testing"
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
  CartoCSSHelper::Configuration.set_overpass_instance_url('http://overpass-api.de/api') #restore normal instance
  return JSON.parse(json_string)
end

def get_list_from_arbitrary_query(query, required_tags = {}, include_history_of_tags = false)
  explanation = "for watchlist #{required_tags}"
  json_string = get_data_from_overpass(query, explanation)


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
    if not currently_present_note_at(lat, lon)
      history = nil
      if include_history_of_tags
        history = description_of_tag_appearances_in_history(entry['type'], entry['id'], required_tags)
      end
      list << { lat: lat, lon: lon, url: url, id: entry['id'], type: entry['type'], history: history}
      if list.length >= requested_watchlist_entries
        return list
      end
    end
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

def fully_matching_tag_set(json_response_tags, tags_in_dict)
  return !not_fully_matching_tag_set(json_response_tags, tags_in_dict)
end

def not_fully_matching_tag_set(json_response_tags, tags_in_dict)
  return true if json_response_tags.nil?
  tags_in_dict.each do |tag|
    if is_failing_tag_match(json_response_tags, tag)
      return true
    end
  end
  return false
end

def is_failing_tag_match(json_response_tags, tag)
    key = tag[0]
    if tag[1].class == Hash
      if tag[1][:operation] == :not_equal_to
        return is_failing_negative_tag_match(json_response_tags, key, tag[1][:value])
      end
    end
    value = tag[1]
    if value == :any_value
      if json_response_tags[key] == nil
        # tag not present
        return true
      end
    else
      if json_response_tags[key] != value
        # not matching specified value
        return true
      end
    end
end

def is_failing_negative_tag_match(json_response_tags, key, value)
    if value == :any_value
      # was not supposed to be present
      return true if json_response_tags[key] != nil
    else
      # was supposed to have a different value
      return true if json_response_tags[key] == value
    end
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
