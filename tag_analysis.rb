require_relative 'query_builder.rb'

def value_distribution(region_name, readable_region_name, key, filter)
  query = filter_across_named_region("['#{key}']"+filter, region_name)
  explanation = "analysis of #{key} in #{readable_region_name}"
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
  obj = JSON.parse(json_string)
  elements = obj["elements"]
  stats = {}
  elements.each do |entry|
    if entry["tags"] != nil
      if entry["tags"][key] != nil
        value = entry["tags"][key]
        stats[value] ||= 0
        stats[value] += 1
      end
    end
  end
  return stats
end

def json_overpass_list_of_countries
  query = '[out:json];relation["admin_level"="2"][boundary=administrative][type!=multilinestring];out;'
  explanation = 'list of countries'
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
  parsed = JSON.parse(json_string)
  return parsed
end

def json_overpass_list_of_territories_in_area(code_of_parent_area, admin_level_of_child_area)
  query = "[out:json][timeout:3600];
area
  ['ISO3166-1'='#{code_of_parent_area}'] -> .parent_area;
(
  rel
    (area.parent_area)
    [admin_level=#{admin_level_of_child_area}][boundary=administrative];
);
out;"
  explanation = "list of admin_level=#{admin_level_of_child_area} for 'ISO3166-1'='#{code_of_parent_area}'"
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
  parsed = JSON.parse(json_string)
  return parsed
end

def entry_to_url(entry)
  id = entry["id"]
  type = entry["type"]
  return "http://www.openstreetmap.org/#{type}/#{id}"
end

def sanity_check_of_territories(parsed_json_with_territories)
  territories = parsed_json_with_territories["elements"]
  who_has_code = {}
  territories.each do |entry|
    area_code = get_iso3166_code(entry)
    if who_has_code[area_code] != nil && area_code != nil
      puts "duplicate: #{area_code} has both #{entry_to_url(entry)} and #{who_has_code[area_code]}"
    end
    who_has_code[area_code] = entry_to_url(entry)
  end
end

def get_iso3166_code(entry)
  tags = ["ISO3166-1", "ISO3166-1:alpha2", "ISO3166-2"]
  tags.each do |tag|
    code = entry["tags"][tag]
    return code if code != nil
  end
  id = entry["id"]
  return nil if [3263728, 5441968, 7567187, 7534382].include?(id) # known issues with entry in TODO or opened notes
  puts "no ISO3166 code for #{entry_to_url(entry)}"
  return nil
end

def get_name(entry)
  name = entry["tags"]["name:en"]
  return name if name != nil
  id = entry["id"]
  return nil if [].include?(id) # known issues with entry in TODO or opened notes
  puts "no English name for #{entry_to_url(entry)}"
  name = entry["tags"]["name"]
  return name if name != nil
  puts "no name for #{entry_to_url(entry)}"
  return nil
end

def value_distribution_for_each_territory(parsed_areas, key, filter="")
  sanity_check_of_territories(parsed_areas)
  territories = parsed_areas["elements"]
  list_of_stats = []
  territories.each do |entry|
    iso3166_code = get_iso3166_code(entry)
    next if iso3166_code == nil
    name = get_name(entry)
    stats = value_distribution(entry["tags"]["name"], name, key, filter)
    list_of_stats << {stats: stats, english_name: name, iso3166_code: iso3166_code}
  end
  return list_of_stats
end

def yes_no_stats(stats)
  yes = stats["yes"]
  no = stats["no"]
  yes = 0 if yes == nil
  no = 0 if no == nil
  other = 0
  stats.each do |value, count|
    if value != "yes" and value != "no"
      other += count
    end
  end
  return {yes: yes, no: no, other: other}
end

def show_yes_no_stats(stats)
  yes = yes_no_stats(stats)[:yes]
  no = yes_no_stats(stats)[:no]
  other = yes_no_stats(stats)[:other]
  if yes + no < other * 10
    return false
  end
  total = yes + no + other
  if total == 0
    return false
  end
  puts "yes: #{yes*100/total}%"
  puts "no: #{no*100/total}%"
  puts "other: #{other*100/total}%"
  puts stats
  return true
end

def show_empty_stats(stats)
  if stats.length != 0
    return false
  end
  puts "tag is not present in this area"
  return true
end

def show_stats(stats, description)
  puts
  puts description
  return if show_empty_stats(stats)
  return if show_yes_no_stats(stats)
  puts stats
end

def show_whitelist_blacklist(whitelist, blacklist)
    puts
    puts "whitelist:"
    for area_description in whitelist
      puts "- #{area_description}"
    end
    puts
    puts "blacklist:"
    for area_description in blacklist
      puts "- #{area_description}"
    end
    puts
    puts
end
