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

def empty_note_xml
  '<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
</osm>'
end

def currently_present_note_at(lat, lon)
  # in case of note present it accepts cache
  # in case of missing note and cache that is not current it checks to be sure
  range = 0.025
  if CartoCSSHelper::NotesDownloader.cache_timestamp(lat, lon, range) == nil
    puts "note download (cache was not present) (note check of #{lat}, #{lon})"
  end
  notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range).strip
  return true if notes != empty_note_xml
  timestamp_in_h = (Time.now - CartoCSSHelper::NotesDownloader.cache_timestamp(lat, lon, range)).to_i / 60 / 60
  if timestamp_in_h >= time_in_hours_that_forces_note_redoing
    puts "note download after discarding cache (cache age was #{timestamp_in_h}h) (note check of #{lat}, #{lon})"
    notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range, invalidate_cache: true)
  end
  return notes != empty_note_xml
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
