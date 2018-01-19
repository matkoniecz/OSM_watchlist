require_relative 'tag_analysis.rb'

def religion_stats_by_country
  filters = ["[amenity=place_of_worship]"] #'[historic=wayside_shrine'], '[man_made=cross]', '[historic=wayside_cross']
  key = "religion"
  filters.each do |filter|
    value_distribution_for_each_territory(json_overpass_list_of_countries(), key, filter).each do |entry|
      description = entry[:english_name] + " (" + entry[:iso3166_code] + ")"
      filter_description = "#{key} on #{filter}"
      filter_description = "#{key}" if filter == ""
      show_stats(entry[:stats], filter_description + " in " + description)
    end
  end
end

def tactile_paving_stats
  filters = ["[highway=crossing]", "[highway=bus_stop]"]
  key = "tactile_paving"
  filters.each do |filter|
    value_distribution_for_each_territory(json_overpass_list_of_countries(), key, filter).each do |entry|
      description = entry[:english_name] + " (" + entry[:iso3166_code] + ")"
      filter_description = "#{key} on #{filter}"
      filter_description = "#{key}" if filter == ""
      show_yes_no_stats(entry[:stats], filter_description + " in " + description)


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
      show_yes_no_stats(stats, filter_description + " in " + english_identifier)
    end

    show_whitelist_blacklist(whitelist, blacklist)
  end
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