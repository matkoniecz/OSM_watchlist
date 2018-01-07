require_relative 'query_builder.rb'

def test_tag_analysis(english_country_name, country_code)
  puts english_country_name
  puts country_code
  tag = "tactile_paving"
  query = filter_across_named_region("[#{tag}]", english_country_name)
  explanation = "analysis of #{tag} in #{english_country_name}"
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
  obj = JSON.parse(json_string)
  elements = obj["elements"]
  elements.each do |entry|
    if entry["tags"] != nil
      if entry["tags"][tag] != nil
       puts "#{tag}=#{entry["tags"][tag]} in #{english_country_name}"
      end
    end
  end
end

def debug_lister
	query = '[out:json];relation["admin_level"="2"][boundary=administrative][type!=multilinestring];out;'
  explanation = 'list of countries'
	json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
  obj = JSON.parse(json_string)
  elements = obj["elements"]
  elements.each do |entry|
    test_tag_analysis(entry["tags"]["name:en"], entry["tags"]["ISO3166-1"])
  end
end
