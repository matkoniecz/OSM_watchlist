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
  return nil if [3263728, 5441968, 7567187].include?(id) # known issues with entry in TODO or opened notes
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

def tactile_paving_stats
  filters = ["[highway=crossing]", "[highway=bus_stop]"]
  filters.each do |filter|
    key = "tactile_paving"
    value_distribution_for_each_territory(json_overpass_list_of_countries(), key, filter).each do |entry|
      description = entry[:english_name] + " (" + entry[:iso3166_code] + ")"
      filter_description = "#{key} on #{filter}"
      filter_description = "#{key}" if filter == ""
      show_stats(entry[:stats], filter_description + " in " + description)


      blacklist = []
      whitelist = []

      yes = yes_no_stats(entry[:stats])[:yes]
      no = yes_no_stats(entry[:stats])[:no]
      next if yes + no == 0
      percent = yes*100/(yes+no)
      if no > 500 && percent < 5
        blacklist << description
      end
      if yes > 100 && percent > 5
        whitelist << description
      end
    end
    show_whitelist_blacklist(whitelist, blacklist)
  end
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

def bikeway_stats()
  bikeway_stats_by_area_in_area('US', 4)
  bikeway_stats_by_area_in_area('CN', 4)
  bikeway_stats_by_country()
end

def bikeway_stats_by_country()
  bikeway_stats_by_territory_group(json_overpass_list_of_countries())
end

def bikeway_stats_by_area_in_area(iso3166_code, admin_level)
    bikeway_stats_by_territory_group(json_overpass_list_of_territories_in_area(iso3166_code, admin_level))

end

def bikeway_stats_by_territory_group(territory_areas)
  # currently enabled
  # https://github.com/westnordost/StreetComplete/blob/f4aa38fa48d2408835f563db246a6b3e9665657d/app/src/main/java/de/westnordost/streetcomplete/quests/bikeway/AddCycleway.java#L201
  filters = [""]
  filters.each do |filter|
    keys = ["cycleway:both", "cycleway", "cycleway:left", "cycleway:right"]
    data = {}
    merged_data_for_each_territory = {}
    keys.each do |key|
      data = value_distribution_for_each_territory(territory_areas, key, filter)
      data.each do |entry|
        key = entry[:english_name] + " (" + entry[:iso3166_code] + ")"
        merged_data_for_each_territory[key] ||= {}
        entry[:stats].each do |value, count|
          merged_data_for_each_territory[key][value] ||= 0
          merged_data_for_each_territory[key][value] += count
        end
      end
    end

    blacklist = []
    whitelist = []

    merged_data_for_each_territory.each do |english_identifier, stats|
      yes = yes_no_stats(stats)[:other] + yes_no_stats(stats)[:yes]
      no = yes_no_stats(stats)[:no]
      next if yes + no == 0
      percent = yes*100/(yes+no)
      if no > 500 && percent < 5
        blacklist << english_identifier
      end
      if yes > 100 && percent > 5
        whitelist << english_identifier
      end

      filter_description = "#{keys} on #{filter}"
      filter_description = "#{keys}" if filter == ""
      show_stats(stats, filter_description + " in " + english_identifier)
    end

    show_whitelist_blacklist(whitelist, blacklist)
  end
end
    #puts value_distribution(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:both")
    #puts value_distribution(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:left")
    #puts value_distribution(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:right")
