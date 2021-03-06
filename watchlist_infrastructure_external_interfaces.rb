require 'nokogiri'

def get_full_user_xml(id, invalidate_cache: false)
  url = "http://api.openstreetmap.org/api/0.6/user/#{id}"
  timeout = 60
  downloader = GenericCachedDownloader.new(timeout: timeout, stop_on_timeout: false)
  description = "user_#{id}"
  cache_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_cache + "/osm-api/#{description}"
  changeset_xml = downloader.get_specified_resource(url, cache_filename, description: description, invalidate_cache: invalidate_cache)
end

def get_full_user_data(id, invalidate_cache: false)
  returned = {}
  doc = Nokogiri::XML(get_full_user_xml(id, invalidate_cache: invalidate_cache))
  main_metadata = doc.at_xpath('//user')
  returned[:current_username] = main_metadata[:display_name]
  returned[:account_created] = main_metadata[:account_created]
  returned[:changeset_count] = main_metadata.at_xpath('//changesets')[:count]
  returned[:trace_count] = main_metadata.at_xpath('//traces')[:count]
  blocks = main_metadata.at_xpath('//blocks').at_xpath('//received')
  returned[:block_count] = blocks[:count]
  returned[:block_active] = blocks[:active]
  return returned
end

def get_full_changeset_xml(id, invalidate_cache: false)
  url = "http://api.openstreetmap.org/api/0.6/changeset/#{id}?include_discussion=true"
  timeout = 60
  downloader = GenericCachedDownloader.new(timeout: timeout, stop_on_timeout: false)
  description = "changeset_with_discussion_#{id}"
  cache_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_cache + "/osm-api/#{description}"
  changeset_xml = downloader.get_specified_resource(url, cache_filename, description: description, invalidate_cache: invalidate_cache)
end

def get_full_changeset_json(id, invalidate_cache: false)
  #TODO: it is not JSON!
  returned = {}
  doc = Nokogiri::XML(get_full_changeset_xml(id, invalidate_cache: invalidate_cache))
  main_metadata = doc.at_xpath('//changeset')
  returned[:author_id] = main_metadata[:uid]
  returned[:timestamp] = DateTime.parse(main_metadata[:closed_at]).to_time.to_i
  returned[:discussion] = []
  discussion = doc.at_xpath('//discussion')
  for comment in discussion.xpath('comment')
    text = comment.at_xpath('//text')
    posted_timestamp = DateTime.parse(comment['date']).to_time.to_i
    returned[:discussion] << {text: text, timestamp: posted_timestamp}
  end
  return returned
end

def get_data_from_overpass(query, explanation, invalidate_old_cache = false)
  debug = false
  cache_not_present = false
  if CartoCSSHelper::OverpassDownloader.cache_timestamp(query) == nil
    puts "running query, cache is not present"
    puts query
    cache_not_present = true
  end
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation, debug)
  return json_string if cache_not_present
  cache_age_in_seconds = (Time.now - CartoCSSHelper::OverpassDownloader.cache_timestamp(query)).to_i
  cache_age_in_minutes = cache_age_in_seconds / 60
  cache_age_in_hours = cache_age_in_minutes / 60

  timestamp_description = "#{cache_age_in_hours}h"
  if cache_age_in_hours == 0
    if cache_age_in_minutes < 2
      timestamp_description = "#{cache_age_in_seconds}s"
    else
      timestamp_description = "#{cache_age_in_minutes}min"
    end
  end

  if !invalidate_old_cache
    return json_string
  end

  if cache_age_in_hours <= time_in_hours_that_protects_query_from_redoing
    puts "not redoing #{timestamp_description} old query (#{cache_age_in_hours}h <= #{time_in_hours_that_protects_query_from_redoing}h)"
    return json_string
  end

  puts "redoing #{timestamp_description} old query"
  return CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation, debug, invalidate_cache: true)
end

def empty_note_xml
  '<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
</osm>'
end

def currently_present_note_at(lat, lon, reason)
  # in case of note present it accepts cache
  # in case of missing note and cache that is not current it checks to be sure
  range = 0.05
  if (lat-50).abs < 0.5 && (lon-20).abs < 0.5
    range = 0.001
  end
  fresh = CartoCSSHelper::NotesDownloader.cache_timestamp(lat, lon, range) == nil
  notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range).strip
  puts "note download (cache was not present) (note check of #{lat}, #{lon}) for #{reason}" if fresh
  if notes != empty_note_xml
    puts "notes found" if fresh
    return true
  end
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
    retro(u(t['created']))
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

def list_of_objects_with_this_tag_part(tag, partial_match_wanted_list, notes_block_report: true)
  watchlist = []
  query = '[out:json][timeout:250];
  (' + "\n"
  partial_match_wanted_list.each do |match|
    query += '  node["' + tag + '"~"' + match + '"];' + "\n"
    query += '  way["' + tag + '"~"' + match + '"];' + "\n"
    query += '  relation["' + tag + '"~"' + match + '"];' + "\n"
  end
  query += ');
  out body;
  >;
  out skel qt;'
  return get_list_from_arbitrary_query(query, reason: "partial match of <#{tag}> to <#{partial_match_wanted_list}> ", notes_block_report: false)
end
