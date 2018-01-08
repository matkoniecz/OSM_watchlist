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
  return JSON.parse(json_string)
end

def value_distribution_for_each_country(key, filter="")
  countries = json_overpass_list_of_countries["elements"]
  list_of_stats = []
  countries.each do |entry|
    english_name = entry["tags"]["name:en"]
    country_code_tag = "ISO3166-1"
    fallback_country_code_tag = "ISO3166-1:alpha2"
    country_code = entry["tags"][country_code_tag]
    if country_code == nil
      country_code = entry["tags"][fallback_country_code_tag]
      if country_code == nil
        puts "no code for http://www.openstreetmap.org/relation/#{entry["id"]} country"
        next
      end
    end
    stats = value_distribution(entry["tags"]["name"], english_name, key, filter)
    list_of_stats << {stats: stats, english_name: english_name, country_code: country_code}
  end
  return list_of_stats
end

def tactile_paving_stats
  filters = ["[highway=crossing]", "[highway=bus_stop]"]
  filters.each do |filter|
    blacklist = []
    whitelist = []
    tag = "tactile_paving"
    value_distribution_for_each_country(tag, filter).each do |entry|
      country_description = entry[:english_name] + " (" + entry[:country_code] + ")"
      filter_description = "#{tag} on #{filter}"
      filter_description = "#{tag}" if filter == ""
      show_stats(entry[:stats], filter_description + " in " + country_description)


      yes = yes_no_stats(entry[:stats])[:yes]
      no = yes_no_stats(entry[:stats])[:no]
      next if yes + no == 0
      percent = yes*100/(yes+no)
      if no > 500 && percent < 5
        blacklist << country_description
      end
      if yes > 100 && percent > 5
        whitelist << country_description
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
  puts "tag is not present in this country"
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
    for country_description in whitelist
      print "#{country_description}, "
    end
    puts
    puts "blacklist:"
    for country_description in blacklist
      print "#{country_description}, "
    end
    puts
    puts
end

def bikeway_stats
  # currently enabled
  # https://github.com/westnordost/StreetComplete/blob/f4aa38fa48d2408835f563db246a6b3e9665657d/app/src/main/java/de/westnordost/streetcomplete/quests/bikeway/AddCycleway.java#L201
  filters = [""]
  filters.each do |filter|
    blacklist = []
    whitelist = []
    tag = "cycleway:both"
    value_distribution_for_each_country(tag, filter).each do |entry|
      country_description = entry[:english_name] + " (" + entry[:country_code] + ")"
      filter_description = "#{tag} on #{filter}"
      filter_description = "#{tag}" if filter == ""
      show_stats(entry[:stats], filter_description + " in " + country_description)
    end
    show_whitelist_blacklist(whitelist, blacklist)
  end
end
    #puts value_distribution(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:both")
    #puts value_distribution(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:left")
    #puts value_distribution(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:right")
