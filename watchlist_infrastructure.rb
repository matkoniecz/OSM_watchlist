require_relative 'watchlist_infrastructure_external_interfaces.rb'

def count_entries(watchlist)
  count = 0
  watchlist.each do |entry|
    entry[:list].each do |data|
      if data[:lat].nil? || data[:lon].nil?
        raise "<#{entry[:message]}> has broken data"
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

def changesets_that_caused_tag_to_appear_in_history(json_history, required_tags)
  previous_version_was_matching = false
  appeared_in = []
  for v in json_history["elements"]
    matching = fully_matching_tag_set(v["tags"], required_tags)
    if matching and !previous_version_was_matching
      appeared_in << v['changeset']
    end
    previous_version_was_matching = matching
  end
  return appeared_in
end

def description_of_tag_appearances_in_history(type, id, required_tags)
  # show all revisions that match and previous revision is not matchhing
  # "appeared in CHANGESET_LINK, CHANGESET_LINK, CHANGESET_LINK"
  json_history = get_json_history_representation(type, id)
  return changesets_that_caused_tag_to_appear_in_history(json_history, required_tags)
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

def get_json_history_representation_cache_age_in_seconds(type, id)
  query = get_history_query(type, id)
  return (Time.now - CartoCSSHelper::OverpassDownloader.cache_timestamp(query)).to_i
end

def get_date_of_latest_appearance_in_changeset_discussion(changeset_id, wanted_text, invalidate_cache)
  changeset = get_full_changeset_json(changeset_id, invalidate_cache: invalidate_cache)
  latest = nil
  for comment in changeset[:discussion]
    text = comment[:text]
    if text.find(wanted_text) != -1
      if latest == nil || latest < comment[:timestamp]
        latest = comment[:timestamp]
      end
    end
  end
  return latest
end

def is_element_under_active_discussion(type, id, required_tags, invalidate_cache = false)
    json_history = get_json_history_representation(type, id)
    changesets = changesets_that_caused_tag_to_appear_in_history(json_history, required_tags)
    for changeset_id in changesets
      url = "https://www.openstreetmap.org/#{type}/#{id}"
      posted_date = get_date_of_latest_appearance_in_changeset_discussion(changeset_id, url, invalidate_cache)
      if posted_date != nil
        time_in_seconds = DateTime.now.to_time.to_i - posted_date
        time_in_days = time_in_seconds / 60 / 60 / 24
        return true if time_in_days < 30 # give time to respond
      end
    end
    if invalidate_cache == false
      cache_age_in_hours = get_json_history_representation_cache_age_in_seconds(type, id) / 60 / 60
      if cache_age_in_hours >= default_cache_timeout_age_in_hours
        return is_element_under_active_discussion(type, id, required_tags, invalidate_cache: true)
      end
    end
    return false
end

def get_location(entry, node_database)
  lat, lon = nil, nil
  if entry["type"] == "way"
    lat, lon = node_database[entry["nodes"][0]]
    if is_location_undefined(lat, lon, entry)
      puts "location not loaded for way"
      puts query
      return nil, nil
    end
    return lat, lon
  elsif entry["type"] == "relation"
    entry["members"].each do |member|
      if member["type"] == "node"
        lat, lon = node_database[member["ref"]]
        return lat, lon if lat != nil && lon != nil
      end
    end
    puts "skipped relation"
    return nil, nil
  elsif entry["type"] == "node"
    lat = entry["lat"].to_f
    lon = entry["lon"].to_f
    return lat, lon
  else
    puts "skipped #{entry["type"]}"
    return nil, nil
  end
  return nil, nil
end

def build_string_describing_tag_appearance_from_changeset_list(changesets_that_caused_object_to_match, required_tags)
  description = ""
  for changeset_id in changesets_that_caused_object_to_match
      description += ", " if description != ""
      description = "appeared in " if description == ""
      description += "https://www.openstreetmap.org/changeset/#{changeset_id}"
  end
  return description
end

def json_string_to_list_of_actionable_elements(json_string, required_tags, include_history_of_tags, reason)
  obj = JSON.parse(json_string)

  list = []
  node_database = get_node_database(obj)
  elements = obj["elements"]

  elements.each do |entry|
    next if not_fully_matching_tag_set(entry["tags"], required_tags)
    lat, lon = get_location(entry, node_database)
    if lat == nil or lon == nil
      puts "no location data"
      next
    end

    url = "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']}#map=17/#{lat}/#{lon}layers=N"
    if is_location_undefined(lat, lon, entry)
      next
    end
    if not currently_present_note_at(lat, lon, reason + " " + url)
      history = nil
      if include_history_of_tags
        next if is_element_under_active_discussion(entry['type'], entry['id'], required_tags)
        history = description_of_tag_appearances_in_history(entry['type'], entry['id'], required_tags)
        history_string = build_string_describing_tag_appearance_from_changeset_list(history, required_tags)
      end
      list << { lat: lat, lon: lon, url: url, id: entry['id'], type: entry['type'], history: history, history_string: history_string }
      if list.length >= requested_watchlist_entries
        return list
      end
    end
  end
  return list
end

def get_list_from_arbitrary_query(query, required_tags = {}, include_history_of_tags = false, reason: "")
  reason = "#{required_tags}" if reason == ""
  explanation = "for watchlist <#{reason}>"
  invalidate_old_cache = false
  json_string = get_data_from_overpass(query, explanation, invalidate_old_cache)
  list = json_string_to_list_of_actionable_elements(json_string, required_tags, include_history_of_tags, reason)
  if list.length > 0
    invalidate_old_cache = true
    json_string = get_data_from_overpass(query, explanation, invalidate_old_cache)
    list = json_string_to_list_of_actionable_elements(json_string, required_tags, include_history_of_tags, reason)
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
