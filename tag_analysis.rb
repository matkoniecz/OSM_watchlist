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

def show_empty_stats(stats)
  if stats.length != 0
    return false
  end
  puts "tag is not present in this area"
  return true
end

def categorize_using_regexp(stats, list_of_patterns)
  returned = {}
  returned[:match_count] = 0
  returned[:match] = {}
  returned[:other_count] = 0
  returned[:other] = {}
  stats.each do |value, count|
    match = false
    list_of_patterns.each do |pattern|
      match = true if value =~ pattern
    end
    if match
      returned[:match_count] += count
      returned[:match][value] = count
    else
      returned[:other_count] += count
      returned[:other][value] = count
    end
  end
  return returned
end

def show_numbers_stats(stats)
  list_of_patterns = [/^\d+$/, /^\d+\.\d+$/, /^\d+,\d+$/]
  data = categorize_using_regexp(stats, list_of_patterns)
  numbers_count = data[:match_count]
  other_count = data[:other_count]
  if numbers_count < other_count * 10
    return false
  end
  puts "#{numbers_count*100/(numbers_count+other_count)}% are numbers"
  if data[:other] != {}
    puts "exceptions:"
    puts data[:other]
  end
  return true
end

def show_alphanumeric_soup_stats(stats)
  soup = {}
  soup_count = 0
  other = {}
  other_count = 0
  stats.each do |value, count|
    nonmuber_count = 0
    number_count = 0
    value.each_char do |letter|
      if ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].include?(letter)
        number_count += 1
      else
        nonmuber_count += 1
      end
    end
    if number_count > 0 && nonmuber_count <= 1
      soup[value] = count
      soup_count += count
    else
      other[value] = count
      other_count += count
    end
    if soup_count < other_count * 10
      return false
    end
    puts "#{soup_count*100/(soup_count+other_count)}% are mix of number(s) with at most one other character"
    if other != {}
      puts "exceptions:"
      puts other
    end
    return true
  end
end

def show_limited_values_stats(stats, values_count)
  total_count = 0
  stats.each do |key, count|
    total_count += count
  end

  count_of_top_ones = 0

  sorted = stats.to_a 
  sorted.sort_by! {|a| -a[1]}
  (0..values_count-1).each do |i|
    count_of_top_ones += sorted[i][1]
  end

  if count_of_top_ones < (total_count - count_of_top_ones) * 10
    return false
  end
  (0..values_count-1).each do |i|
    puts "#{sorted[i][0]} x#{sorted[i][1]}"
    stats.delete([i][0])
    count_of_top_ones += sorted[i][1]
  end
  if stats != {} 
    puts "exceptions:"
    puts stats
  end
  return true
end

def date_in_evil_american_format(stats)
  #MM/DD/YYYY
  mmddyyyy_leading_zero = /(01|02|03|04|05|06|07|08|09|10|11|12)\/\d\d\/\d\d\d\d/
  mmddyy = /(1|2|3|4|5|6|7|8|9|10|11|12)\/(\d|\d\d)\/\d\d\d\d/
  list_of_patterns = [mmddyyyy_leading_zero, mmddyy]
  description = "dates in evil american format (MM/DD/YYYY or mm/dd/yyyy)"
  data = categorize_using_regexp(stats, list_of_patterns)
  if data[:match_count] < data[:other_count] * 10
    return false
  end
  puts "#{data[:match_count]*100/(data[:match_count] + data[:other_count])}% are #{description}"
  if data[:other] != {}
    puts "exceptions:"
    puts data[:other]
  end
  return true
end

def show_stats(stats, description)
  puts
  puts description
  return if show_empty_stats(stats)

  return if show_limited_values_stats(stats, 1)
  return if show_limited_values_stats(stats, 2)
  return if show_limited_values_stats(stats, 3)
  return if show_limited_values_stats(stats, 4)
  return if show_numbers_stats(stats)
  return if show_alphanumeric_soup_stats(stats)
  puts stats
end
