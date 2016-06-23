require 'json'

def suspicious_name_watchlist_entry(name)
  return {list: get_list({'name' => name}), message: "name = '#{name}"}
end

def watchlist_entries
  watchlist = []
  
  beton_variation = "Beton"
  tags = { 'surface' => beton_variation}
  beton_problem = "surface=#{beton_variation}? 'beton' is word for concrete in some languages but not in the English"
  overpass_code = 'gT2'
  message = beton_problem +"\n\n" + "See http://overpass-turbo.eu/s/#{overpass_code} for more problems of this type"
  watchlist << {list: get_list(tags), message: message}

  beton_variation = "beton"
  tags = { 'surface' => beton_variation}
  beton_problem = "surface=#{beton_variation}? 'beton' is word for concrete in some languages but not in the English"
  overpass_code = 'gT4'
  message = beton_problem +"\n\n" + "See http://overpass-turbo.eu/s/#{overpass_code} for more problems of this type"
  watchlist << {list: get_list(tags), message: message}

  watchlist << suspicious_name_watchlist_entry('Maszt telekomunikacyjny')
  watchlist << suspicious_name_watchlist_entry('wiatrak')
  watchlist << suspicious_name_watchlist_entry('Wiatrak')
  watchlist << suspicious_name_watchlist_entry('plac zabaw')
  watchlist << suspicious_name_watchlist_entry('Plac zabaw')
  watchlist << suspicious_name_watchlist_entry('Parking')
  watchlist << suspicious_name_watchlist_entry('parking')
  watchlist << suspicious_name_watchlist_entry('dojazd do przedszkola')
  watchlist << suspicious_name_watchlist_entry('Dojazd do przedszkola')
  #dojazd do
  watchlist << suspicious_name_watchlist_entry('apteka')
  watchlist << suspicious_name_watchlist_entry('Apteka')
 # watchlist << suspicious_name_watchlist_entry('warzywniak')
 # watchlist << suspicious_name_watchlist_entry('Warzywniak')
  watchlist << suspicious_name_watchlist_entry('śmietnik')
  watchlist << suspicious_name_watchlist_entry('Śmietnik')
  watchlist << suspicious_name_watchlist_entry('drzewo')
  watchlist << suspicious_name_watchlist_entry('Drzewo')
  watchlist << suspicious_name_watchlist_entry('las')
  watchlist << suspicious_name_watchlist_entry('Las')

  #bardzo stare highway=construction

  watchlist << {list: get_list({'name' => 'jarząb pospolity (jarząb zwyczajny)', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'jarząb pospolity', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'jarząb zwyczajny', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'tree', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'drzewo', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'Drzewo', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'Platan klonolistny', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'choinka', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'Choinka', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'brzoza', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}
  watchlist << {list: get_list({'name' => 'Brzoza', 'natural' => 'tree'}), message: "opis drzewa w nazwie"}

  watchlist << {list: get_list({'bicycle' => 'official'}, 50, 20, 2), message: "bicycle=official"}
  watchlist << {list: get_list({'bicycle' => 'official'}, 50, 20, 3), message: "bicycle=official"}

  watchlist << {list: get_list({'highway' => 'bridleway'}, 50, 20, 2), message: "highway=bridleway"}
  watchlist << {list: get_list({'highway' => 'bridleway'}, 50, 20, 3), message: "highway=bridleway"}

  watchlist << {list: get_list({'highway' => 'bus_guideway'}, 50, 20, 5), message: "highway=bus_guideway"}
  watchlist << {list: get_list({'highway' => 'bus_guideway'}, 50, 20, 10), message: "highway=bus_guideway"}

  watchlist << {list: get_list({'natural' => 'volcano'}, 50, 20, 5), message: "highway=bus_guideway"}
  watchlist << {list: get_list({'natural' => 'volcano'}, 50, 20, 25), message: "highway=bus_guideway"}

project_mess_query = '[out:json][timeout:250];
(
  /* query part for: “name~planowan” */
  node["name"~"planowan"];
  way["name"~"planowan"];
  relation["name"~"planowan"];

  /* query part for: “name~projektowan and name!=Nowoprojektowana” */
  node["name"~"projektowan"]["name"!="Nowoprojektowana"];
  way["name"~"projektowan"]["name"!="Nowoprojektowana"];
  relation["name"~"projektowan"]["name"!="Nowoprojektowana"];

  /* query part for: “name~/proj\./ and name!=Nowoprojektowana” */
  node["name"~"proj\\."]["name"!="Nowoprojektowana"];
  way["name"~"proj\\."]["name"!="Nowoprojektowana"];
  relation["name"~"proj\\."]["name"!="Nowoprojektowana"];

  /* query part for: “name~/w budowie/ and name!=Nowoprojektowana” */
  node["name"~"w budowie"];
  way["name"~"w budowie"];
  relation["name"~"w budowie"];

  // query part for: “name~koncepcja and name!=Nowoprojektowana”
  node["name"~"koncepcja"];
  way["name"~"koncepcja"];
  relation["name"~"koncepcja"];
);
out body;
>;
out skel qt;'
# and highway!=proposed and highway!=planned and railway!=proposed
#["highway"!="proposed"]["highway"!="planned"]["railway"!="proposed"]

  watchlist << {list: get_list_from_arbitrary_query(project_mess_query), message: "planowane/projektowane"}

#wszystkie nawiasy; http://overpass-turbo.eu/s/gVo

extended_project_mess_query = '[out:json][timeout:250];
(
);
out body;
>;
out skel qt;'

  watchlist << {list: get_list_from_arbitrary_query(extended_project_mess_query), message: "planowane/projektowane ++"}
  #watchlist for rare landuse values in Kraków, ; w surface

  return watchlist  
end

def run_watchlist
  empty = '<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
</osm>'

  puts "access=public eliminator http://overpass-turbo.eu/s/gTt"
  #more https://github.com/osmlab/name-suggestion-index/blob/master/filter.json https://lists.openstreetmap.org/pipermail/talk/2015-May/072923.html

  watchlist_entries.each do |entry|
    mentioned = false
    entry[:list].each do |data|
    	range = 0.005
      notes = CartoCSSHelper::NotesDownloader.run_note_query(data[:lat], data[:lon], range)
      next if notes.strip != empty
      timestamp_in_h = (Time.now - CartoCSSHelper::NotesDownloader.cache_timestamp(data[:lat], data[:lon], range)).to_i/60/60
      if timestamp_in_h > 1
        notes = CartoCSSHelper::NotesDownloader.run_note_query(data[:lat], data[:lon], range, invalidate_cache: true)
      end
      next if notes.strip != empty
      if !mentioned
        puts
        puts
        puts entry[:message]
        mentioned = true
      end
      timestamp_in_h = (Time.now - CartoCSSHelper::NotesDownloader.cache_timestamp(data[:lat], data[:lon], range)).to_i/60/60
      puts "# #{data[:url]} #{timestamp_in_h}h ago"
    end
  end
end

def watchlist_query(tags, lat, lon, distance)
  filter = OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter(tags)
  query = '[timeout:25][out:json];
(
  '+CartoCSSHelper::OverpassQueryGenerator.get_query_element_to_get_location(tags, lat, lon, 'node', distance)+'
  '+CartoCSSHelper::OverpassQueryGenerator.get_query_element_to_get_location(tags, lat, lon, 'way', distance)+'
  '+CartoCSSHelper::OverpassQueryGenerator.get_query_element_to_get_location(tags, lat, lon, 'relation', distance)+'
);
out body;
>;
out skel qt;'
  return query
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

def get_list(required_tags, lat=0, lon=0, distance=:infinity)
	query = watchlist_query(required_tags, lat, lon, distance)
	return get_list_from_arbitrary_query(query, required_tags)
end

def get_list_from_arbitrary_query(query, required_tags={})
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, "for watchlist #{required_tags}")
  obj = JSON.parse(json_string)

  list = []
  locations = get_node_database(obj)
  elements = obj["elements"]

  elements.each do |entry|
    next if not_fully_matching_tag_set(entry["tags"], required_tags)
    if entry["type"] == "way"
      lat, lon = locations[entry["nodes"][0]]
      url = "https://www.openstreetmap.org/#{entry["type"]}/#{entry["id"]}"
      list << {lat: lat, lon: lon, url: url}
    end
  end
  return list
end
 
def not_fully_matching_tag_set(json_response_tags, tags_in_dict)
	return true if json_response_tags == nil
  tags_in_dict.each do |tag|
    return true if json_response_tags[tag[0]] != tag[1]
  end
  return false
end