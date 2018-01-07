require_relative 'query_builder.rb'

def test_tag_analysis(name, english_country_name, tag, filter)
  query = filter_across_named_region("['#{tag}']"+filter, name)
  explanation = "analysis of #{tag} in #{english_country_name}"
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
  #puts query
  obj = JSON.parse(json_string)
  elements = obj["elements"]
  stats = {}
  elements.each do |entry|
    if entry["tags"] != nil
      if entry["tags"][tag] != nil
        value = entry["tags"][tag]
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

def stats_for_each_country(tag, filter)
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
    stats = test_tag_analysis(entry["tags"]["name"], english_name, tag, filter)
    list_of_stats << {stats: stats, english_name: english_name, country_code: country_code}
  end
  return list_of_stats
end

def debug_lister
  filters = ["[highway=crossing]", "[highway=bus_stop]"]
  filters.each do |filter|
    blacklist = []
    whitelist = []
    stats_for_each_country("tactile_paving", "[highway=crossing]").each do |entry|
      country_description = entry[:english_name] + " (" + entry[:country_code] + ")"
      filter_description = "tag on #{filter}"
      show_stats(entry[:stats], country_description, filter_description)


      yes = yes_no_stats(entry[:stats])[:yes]
      no = yes_no_stats(entry[:stats])[:no]
      next if yes + no == 0
      percent = yes*100/(yes+no)
      if no > 500 && percent < 5
        blacklist << entry[:country_code]
      end
      if yes > 100 && percent > 5
        whitelist << entry[:country_code]
      end
    end
    for country_code in whitelist
      print "#{country_code}, "
    end
    puts
    puts
    for country_code in blacklist
      print "#{country_code}, "
    end
  end
end

def yes_no_stats(stats)
  yes = stats["yes"]
  no = stats["no"]
  yes = 0 if yes == nil
  no = 0 if no == nil
  return {yes: yes, no: no}
end

def show_stats(stats, country_description, tag)
  yes = yes_no_stats(stats)[:yes]
  no = yes_no_stats(stats)[:no]
  if (yes + no) > 10
    percent = yes*100/(yes+no)
    puts
    puts country_description
    puts tag
    puts "yes: #{percent}%"
    puts stats
  end
end

    #puts test_tag_analysis(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:both")
    #puts test_tag_analysis(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:left")
    #puts test_tag_analysis(entry["tags"]["name"], entry["tags"]["name:en"], entry["tags"]["ISO3166-1"], "cycleway:right")
