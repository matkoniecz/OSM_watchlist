# frozen_string_literal: true
require 'json'

def watchlist_entries
  watchlist = []
  watchlist += watch_beton
  watchlist += watch_invalid_wikipedia
  watchlist += watch_descriptive_names
  watchlist += watch_tree_species_in_name
  watchlist += watch_valid_tags_unexpected_in_krakow
  watchlist += watch_lifecycle_state_in_the_name
  #watchlist += watch_nonmilitary_military_danger

  # TODO: bardzo stare highway=construction

  distance_in_km = 6
  watchlist << { list: get_list({ 'bicycle' => 'official' }, 50, 20, distance_in_km), message: "bicycle=official within #{distance_in_km}km from [50, 20]" }
  distance_in_km *= 5
  watchlist << { list: get_list({ 'bicycle' => 'official' }, 50, 20, distance_in_km), message: "bicycle=official within #{distance_in_km}km from [50, 20]" }

  # wszystkie nawiasy; http://overpass-turbo.eu/s/gVo

  # watchlist for rare landuse values in Kraków, ; w surface

  # type=site relation http://overpass-turbo.eu/s/fwU

#TODO:
#puts "access=public eliminator http://overpass-turbo.eu/s/gTt"
# more https://github.com/osmlab/name-suggestion-index/blob/master/filter.json https://lists.openstreetmap.org/pipermail/talk/2015-May/072923.html
#should be highway=path http://overpass-turbo.eu/s/khG 
#bicycle_road=yes w Krakowie http://overpass-turbo.eu/s/pcO
#site=parking elimination
#(planowany) w osm, (w budowie) nie jest lepsze
#walidator: name=Garaże
#building=bridge w Krakowie - http://overpass-turbo.eu/s/dGR 
#type=site relation http://overpass-turbo.eu/s/fwU 
#name=Ogródki działkowe http://overpass-turbo.eu/s/dr3 
#planowan* - tagowanie pod render http://overpass-turbo.eu/s/dtf 
#landuse=basin bez natural=water

#https://www.openstreetmap.org/way/33711547
#note=taśmociąg na filarach + highway=service
#to man_made=goods_conveyor

  return watchlist
end

def watch_invalid_wikipedia
  watchlist = []
  values = ["pl:Pomniki Jana Pawła II w Krakowie", "pl:Ringstand 58c"]

  values.each do |value|
    tags = { 'wikipedia' => value }
    wiki_docs = "only provide links to articles which are 'about the feature'. A link from St Paul's Cathedral in London to an article about St Paul's Cathedral on Wikipedia is fine. A link from a bus depot to the company that operates it is not (see section below)."
    message = "\"wikipedia=#{value}\"? \"#{wiki_docs}\" - https://wiki.openstreetmap.org/wiki/Key:wikipedia"
    watchlist << { list: get_list(tags), message: message }
  end

  return watchlist
end

# in case of note present it accepts cache
# in case of missing note and cache that is not current it checks to be sure
def currently_present_note_at(lat, lon)
  empty = '<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
</osm>'
  range = 0.005
  notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range).strip
  return true if notes != empty
  timestamp_in_h = (Time.now - CartoCSSHelper::NotesDownloader.cache_timestamp(lat, lon, range)).to_i / 60 / 60
  if timestamp_in_h > 1
    puts "note download after discarding cache (cache age was #{timestamp_in_h}h)"
    notes = CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range, invalidate_cache: true)
  end
  return notes != empty
end

def run_watchlist
  watchlist_entries.each do |entry|
    mentioned = false
    entry[:list].each do |data|
      if data[:lat].nil? || data[:lon].nil?
        raise "#{entry[:message]} has broken data"
      end
      if currently_present_note_at(data[:lat], data[:lon])
        next
      end
      unless mentioned
        puts
        puts
        puts entry[:message]
        mentioned = true
      end
      puts "# #{data[:url]}"
    end
  end
end

def watchlist_query(tags, lat, lon, distance)
  query = '[timeout:25][out:json];
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

def get_node_database(json_obj)
  locations = {}
  json_obj["elements"].each do |entry|
    if entry["type"] == "node"
      locations[entry["id"]] = entry["lat"].to_f, entry["lon"].to_f
    end
  end
  return locations
end

def get_list(required_tags, lat = 0, lon = 0, distance_in_km = :infinity)
  distance = :infinity
  distance = if distance_in_km == :infinity
               :infinity
             else
               distance_in_km * 1000
             end
  query = watchlist_query(required_tags, lat, lon, distance)
  list = get_list_from_arbitrary_query(query, required_tags)
  return list
end

def get_list_from_arbitrary_query(query, required_tags = {})
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, "for watchlist #{required_tags}", false)

  timestamp_in_h = (Time.now - CartoCSSHelper::OverpassDownloader.cache_timestamp(query)).to_i / 60 / 60

  base = 24 * 30

  if rand(base) < timestamp_in_h
    puts "redoing #{timestamp_in_h}h old query"
    json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, "for watchlist #{required_tags}", false, invalidate_cache: true)
  end

  obj = JSON.parse(json_string)

  list = []
  locations = get_node_database(obj)
  elements = obj["elements"]

  elements.each do |entry|
    next if not_fully_matching_tag_set(entry["tags"], required_tags)
    lat, lon = nil, nil
    if entry["type"] == "way"
      lat, lon = locations[entry["nodes"][0]]
    elsif entry["type"] == "node"
      lat = entry["lat"].to_f
      lon = entry["lon"].to_f
    else
      puts "skipped #{entry["type"]}"
      next
    end
    url = "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']}#map=15/#{lat}/#{lon}layers=N"
    if lat.nil? || lon.nil?
      puts "Unexpected nil in get_list_from_arbitrary_query"
      next
    end
    list << { lat: lat, lon: lon, url: url }
  end
  return list
end

def not_fully_matching_tag_set(json_response_tags, tags_in_dict)
  return true if json_response_tags.nil?
  tags_in_dict.each do |tag|
    return true if json_response_tags[tag[0]] != tag[1]
  end
  return false
end

def watch_beton
  watchlist = []
  beton_variations = ["Beton", "beton"]

  beton_variations.each do |beton_variation|
    tags = { 'surface' => beton_variation }
    beton_problem = "surface=#{beton_variation}? 'beton' is word for concrete in some languages but not in the English"
    overpass_code = 'gT2'
    message = beton_problem + "\n\n" + "See http://overpass-turbo.eu/s/#{overpass_code} for more problems of this type"
    watchlist << { list: get_list(tags), message: message }
  end

  return watchlist
end

def suspicious_name_watchlist_entry(name, description = nil)
  return { list: get_list({ 'name' => name }), message: "name = '#{name}' #{description}" }
end

def watch_descriptive_names
  watchlist = []
  watchlist << suspicious_name_watchlist_entry('Maszt telekomunikacyjny')
  watchlist << suspicious_name_watchlist_entry('wiatrak')
  watchlist << suspicious_name_watchlist_entry('Wiatrak')
  watchlist << suspicious_name_watchlist_entry('plac zabaw', 'Czy tag name nie jest tu przypadkiem błednie użyty jako opis obiektu? leisure=playground wystarcza by oznaczyć to jako plac zabaw...')
  watchlist << suspicious_name_watchlist_entry('Plac zabaw', 'Czy tag name nie jest tu przypadkiem błednie użyty jako opis obiektu? leisure=playground wystarcza by oznaczyć to jako plac zabaw...')
  watchlist << suspicious_name_watchlist_entry('Parking', 'Is it really parking named parking or is it just a parking and name tag is incorrectly used as a description?')
  watchlist << suspicious_name_watchlist_entry('parking', 'Is it really parking named parking or is it just a parking and name tag is incorrectly used as a description?')
  watchlist << suspicious_name_watchlist_entry('dojazd do przedszkola')
  watchlist << suspicious_name_watchlist_entry('Dojazd do przedszkola')
  # dojazd do
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
  watchlist << suspicious_name_watchlist_entry('Wieża kościelna')
  watchlist << suspicious_name_watchlist_entry('wieża kościelna')
  watchlist << suspicious_name_watchlist_entry('mieszkanie')
  watchlist << suspicious_name_watchlist_entry('dom')
=begin
 /*
This has been generated by the overpass-turbo wizard.
The original search was:
“name=dom and building=* in Poland”
*/
[out:xml]/*fixed by auto repair*/[timeout:2500];
// fetch area “Poland” to search in
{{geocodeArea:Poland}}->.searchArea;
// gather results
(
  // query part for: “name=dom and building=*”
  node["name"="dom"]["building"](area.searchArea);
  way["name"="dom"]["building"](area.searchArea);
  relation["name"="dom"]["building"](area.searchArea);
);
// print results
out meta;/*fixed by auto repair*/
>;
out meta qt;/*fixed by auto repair*/
=end
  watchlist << suspicious_name_watchlist_entry('budynek gospodarczy')
  return watchlist
end

def watch_tree_species_in_name
  watchlist = []
  watchlist << { list: get_list({ 'name' => 'jarząb pospolity (jarząb zwyczajny)', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'jarząb pospolity', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'jarząb zwyczajny', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'tree', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'drzewo', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Drzewo', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Platan klonolistny', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'choinka', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Choinka', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'brzoza', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Brzoza', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  return watchlist
end

def watch_valid_tags_unexpected_in_krakow
  watchlist = []
  range_in_km = 3
  watchlist << { list: get_list({ 'horse' => 'designated' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) horse=designated" }
  range_in_km = 30
  watchlist << { list: get_list({ 'horse' => 'designated' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) horse=designated" }

  range_in_km = 6
  watchlist << { list: get_list({ 'highway' => 'bridleway' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) highway=bridleway Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?" }
  range_in_km = 9
  watchlist << { list: get_list({ 'highway' => 'bridleway' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) highway=bridleway Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?" }

  range_in_km = 250
  watchlist << { list: get_list({ 'highway' => 'bus_guideway' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ? Czy po prostu zwykła droga po której tylko autobusy mogą jeździć?" }
  range_in_km *= 2
  watchlist << { list: get_list({ 'highway' => 'bus_guideway' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ? Czy po prostu zwykła droga po której tylko autobusy mogą jeździć?" }

  range_in_km = 300
  watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  range_in_km = 400
  watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  return watchlist
end

def watch_lifecycle_state_in_the_name
  watchlist = []
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
  # ["highway"!="proposed"]["highway"!="planned"]["railway"!="proposed"]

  watchlist << { list: get_list_from_arbitrary_query(project_mess_query), message: "planowane/projektowane" }
  return watchlist
end

def watch_nonmilitary_military_danger
  watchlist = []
  query = '/*
  This has been generated by the overpass-turbo wizard.
  The original search was:
  “"military"="danger_area" global”
  */
  [out:json][timeout:25];
  // gather results
  (
    // query part for: “military=danger_area”
    node["military"="danger_area"][landuse!=military];
    way["military"="danger_area"][landuse!=military];
    relation["military"="danger_area"][landuse!=military];
  );
  // print results
  out body;
  >;
  out skel qt;'

  info_message = 'military=danger_area without landuse=military If it is military landuse and landuse=military is missing and should be added.

If not then using **military**=danger_area just because it renders seems to be a poor idea. And either it should be changed or https://wiki.openstreetmap.org/wiki/Tag:military%3Ddanger_area with "landuse=military mandatory" should be changed.

http://forum.openstreetmap.org/viewtopic.php?pid=598288#p598288 - de thread
http://www.openstreetmap.org/note/597863#map=14/68.7102/20.4516 - case of civilian rocketry range
https://help.openstreetmap.org/questions/50552/former-military-danger-areas
'
  watchlist << { list: get_list_from_arbitrary_query(query), message: info_message }
  return watchlist
end
