puts "run overpass queeries mentioned here before running watchlist itself"
return

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


  distance_in_km = 6
  watchlist << { list: get_list({ 'bicycle' => 'official' }, 50, 20, distance_in_km), message: "bicycle=official within #{distance_in_km}km from [50, 20]" }
  distance_in_km *= 5
  watchlist << { list: get_list({ 'bicycle' => 'official' }, 50, 20, distance_in_km), message: "bicycle=official within #{distance_in_km}km from [50, 20]" }

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
  range = 0.025
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
  query = '[timeout:250][out:json];
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
      if is_location_undefined(lat, lon, entry)
        puts "location not loaded for way"
        puts query
      end
    elsif entry["type"] == "node"
      lat = entry["lat"].to_f
      lon = entry["lon"].to_f
    else
      puts "skipped #{entry["type"]}"
      next
    end
    url = "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']}#map=15/#{lat}/#{lon}layers=N"
    if is_location_undefined(lat, lon, entry)
      next
    end
    list << { lat: lat, lon: lon, url: url }
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

  beton_variations.each do |value|
    tags = { 'surface' => value }
    beton_problem = "surface=#{value}? 'beton' is word for concrete in some languages but not in the English"
    overpass_code = 'gT2'
    message = beton_problem + "\n\n" + "See http://overpass-turbo.eu/s/#{overpass_code} for more problems of this type"
    watchlist << { list: get_list(tags), message: message }
  end

  return watchlist
end

def list_of_objects_with_this_name_part(name_part)
  watchlist = []
  name_part_query = '[out:json][timeout:250];
  (
    node["name"~"' + name_part + '"];
    way["name"~"' + name_part + '"];
    relation["name"~"' + name_part + '"];
  );
  out body;
  >;
  out skel qt;'
  return get_list_from_arbitrary_query(name_part_query)
end

def suspicious_name_watchlist_entry(name, language_code_of_name, description = nil, matching_tag_list = [{}], overpass_url = nil)
  # TODO rename to objects_using_this_name
  # TODO switch description and matching_tag_list
  # TODO add prefix to description with correct name tag value and name tag
  #TODO support nonacsii https://stackoverflow.com/a/38016153/4130619
  returned = []
  matching_tag_list.each do |required_tags|
    required_tags_info = ""
    required_tags_info = "with #{required_tags.to_s}" if required_tags != {}
    [
      {key: 'name', value: name},
      {key: 'name', value: name.capitalize},
      {key: 'name:'+language_code_of_name, value: name},
      {key: 'name:'+language_code_of_name, value: name.capitalize},
    ].each do |data|
      returned << { list: get_list({ data[:key] => data[:value] }.merge(required_tags)), message: "#{data[:key]} = '#{data[:value]}' #{description}" }
    end
  end
  return returned
end

def objects_using_this_name_part(name_part, description)
  return [{ list: list_of_objects_with_this_name_part(name_part), message: description }]
end

def watch_descriptive_names
  #https://wiki.openstreetmap.org/wiki/Naming_conventions#Don.27t_describe_things_using_name_tag
  #see also https://github.com/osmlab/name-suggestion-index - names should end here to discourage iD users from using them
  watchlist = []
  watchlist += objects_using_this_name_part('boisko do gry w', 'name used instead sport tags')
  watchlist += suspicious_name_watchlist_entry('boisko', 'pl', 'name=boisko', [{'leisure' => 'pitch'}])
  watchlist += suspicious_name_watchlist_entry('Maszt telekomunikacyjny', 'pl')
  watchlist += suspicious_name_watchlist_entry('wiatrak', 'pl')
  playground_complaint = 'Czy tag name nie jest tu przypadkiem błędnie użyty jako opis obiektu? leisure=playground wystarcza by oznaczyć to jako plac zabaw.'
  watchlist += suspicious_name_watchlist_entry('plac zabaw', 'pl', playground_complaint, [{'leisure' => 'playground'}], 'http://overpass-turbo.eu/s/qZ6')
  parking_complaint = 'Is it really parking named parking or is it just a parking and name tag is incorrectly used as a description?'
  watchlist += suspicious_name_watchlist_entry('playground', 'en', [{'leisure' => 'playground'}], 'http://overpass-turbo.eu/s/qZ8')
  #watchlist += suspicious_name_watchlist_entry('parking', 'pl', parking_complaint, [{'amenity' => 'parking'}])
  watchlist += suspicious_name_watchlist_entry('parking bezpłatny', 'pl', parking_complaint, [{'amenity' => 'parking'}])
  watchlist += suspicious_name_watchlist_entry('parking strzeżony', 'pl', parking_complaint, [{'amenity' => 'parking'}])
  watchlist += suspicious_name_watchlist_entry('Parking Strzeżony', 'pl', parking_complaint, [{'amenity' => 'parking'}])
  watchlist += suspicious_name_watchlist_entry('free parking', 'en', 'free parking tagged using name rather than fee tag. overpass helper query: http://overpass-turbo.eu/s/qZf', [{'amenity' => 'parking'}])
  watchlist += suspicious_name_watchlist_entry('supervised parking', 'en', 'supervised parking tagged using name rather than proper tag. overpass helper query: http://overpass-turbo.eu/s/qZf', [{'amenity' => 'parking'}])
  #TODO name=parking nie na parkingu
  watchlist += suspicious_name_watchlist_entry('dojazd do przedszkola', 'pl')
  # dojazd do
  #watchlist += suspicious_name_watchlist_entry('apteka', 'pl', 'name=apteka - overpass query: http://overpass-turbo.eu/s/qZa') - zakomentowane bo styl domyślny ma słabą ikonkę
  watchlist += suspicious_name_watchlist_entry('kiosk', 'pl', 'shop=kiosk', [{'shop' => 'kiosk'}], 'http://overpass-turbo.eu/s/qYg')
  # watchlist += suspicious_name_watchlist_entry('warzywniak')
  # watchlist += suspicious_name_watchlist_entry('Warzywniak')
  complaint = 'for areas OSM data sometimes makes clear that <amenity = waste_disposal> is missing'
  watchlist += suspicious_name_watchlist_entry('śmietnik', 'pl', complaint, [{'amenity' => 'waste_disposal'}], 'http://overpass-turbo.eu/s/qZh')
  watchlist += suspicious_name_watchlist_entry('drzewo', 'pl')
  watchlist += suspicious_name_watchlist_entry('kamieniołom', 'pl')
  watchlist += suspicious_name_watchlist_entry('quarry', 'en')
  watchlist += suspicious_name_watchlist_entry('garaż', 'pl')
  watchlist += suspicious_name_watchlist_entry('garaże', 'pl')
  watchlist += suspicious_name_watchlist_entry('garage', 'en')
  watchlist += suspicious_name_watchlist_entry('garages', 'en')
  watchlist += suspicious_name_watchlist_entry('fontanna', 'pl')
  watchlist += suspicious_name_watchlist_entry('fountain', 'en')
  watchlist += suspicious_name_watchlist_entry('las', 'pl', 'name=las', [{'natural' => 'wood'}, {'landuse' => 'forest'}])
  watchlist += suspicious_name_watchlist_entry('forest', 'en', 'name=forest', [{'natural' => 'wood'}, {'landuse' => 'forest'}], 'http://overpass-turbo.eu/s/rpJ')
  watchlist += suspicious_name_watchlist_entry('big forest', 'en', 'name=big forest', [{'natural' => 'wood'}, {'landuse' => 'forest'}])
  watchlist += suspicious_name_watchlist_entry('small forest', 'en', 'name=small forest', [{'natural' => 'wood'}, {'landuse' => 'forest'}])

  # TODO - las nie na lesie, miejscowości
  watchlist += suspicious_name_watchlist_entry('wieża kościelna', 'pl', 'wieża kościelna (zamienić na   description = Wieża kościelna?, dodać man_made = tower)') #http://overpass-turbo.eu/s/qZo
  watchlist += suspicious_name_watchlist_entry('mieszkanie', 'pl')
  watchlist += suspicious_name_watchlist_entry('dom', 'pl', 'name=dom, overpass: http://overpass-turbo.eu/s/qZn', [{'building' => :any_value}, {'historic' => 'ruins'}])
  #dom - also in Czechia
  #TODO - other values
  watchlist += suspicious_name_watchlist_entry('obora', 'pl', 'name=obora', [{'building' => :any_value}])
  watchlist += suspicious_name_watchlist_entry('barn', 'en', 'name=barn', [{'building' => :any_value}])
  #TODO - other values
  watchlist += suspicious_name_watchlist_entry('restauracja', 'pl', 'name=restauracja', [{'amenity' => 'restaurant'}])
  watchlist += suspicious_name_watchlist_entry('restaurant', 'en', 'name=restaurant', [{'amenity' => 'restaurant'}])
  #TODO - not only for amenity=restaurant
  watchlist += suspicious_name_watchlist_entry('sklep', 'en', 'name=sklep', [{'shop' => :any_value}])

  watchlist += suspicious_name_watchlist_entry('open field', 'en', 'what kind of open field is here?')
  complaint = "water tap - to copy: <\n  man_made = water_tap\n  description = Water tap\n> overpass query helper: http://overpass-turbo.eu/s/qZe"
  watchlist += suspicious_name_watchlist_entry('water tap', 'en', complaint, [{'man_made' => 'water_tap'}])
  watchlist += suspicious_name_watchlist_entry('park', 'en', 'name=park/name=Park', [{'leisure' => 'park'}], 'http://overpass-turbo.eu/s/qZb')
  watchlist += suspicious_name_watchlist_entry('park', 'pl', 'name=park/name=Park', [{'leisure' => 'park'}], 'http://overpass-turbo.eu/s/qZb')

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
  watchlist += suspicious_name_watchlist_entry('budynek gospodarczy', 'pl')
  return watchlist
end

def watch_tree_species_in_name
  watchlist = []
  watchlist << { list: get_list({ 'name' => 'jarząb pospolity (jarząb zwyczajny)', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'jarząb pospolity', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'jarząb zwyczajny', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'tree', 'natural' => 'tree' }), message: "name=tree ( http://overpass-turbo.eu/s/qAX dla level0)" }
  watchlist << { list: get_list({ 'name' => 'Tree', 'natural' => 'tree' }), message: "name=tree ( http://overpass-turbo.eu/s/qAX dla level0)" }
  watchlist << { list: get_list({ 'name' => 'drzewo', 'natural' => 'tree' }), message: "name=drzewo ( http://overpass-turbo.eu/s/qZq )" }
  watchlist << { list: get_list({ 'name' => 'Drzewo', 'natural' => 'tree' }), message: "opis drzewa w nazwie ( http://overpass-turbo.eu/s/qZq )" }
  watchlist << { list: get_list({ 'name' => 'Platan klonolistny', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'choinka', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Choinka', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'brzoza', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Brzoza', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'dąb', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Dąb', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'dąb szypułkowy', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Dąb szypułkowy', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  return watchlist
end

def watch_valid_tags_unexpected_in_krakow
  watchlist = []
  range_in_km = 6
  watchlist << { list: get_list({ 'horse' => 'designated' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) horse=designated" }
  range_in_km = 40
  watchlist << { list: get_list({ 'horse' => 'designated' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) horse=designated" }

  range_in_km = 9
  watchlist << { list: get_list({ 'highway' => 'bridleway' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) highway=bridleway Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?" }
  range_in_km = 12
  watchlist << { list: get_list({ 'highway' => 'bridleway' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) highway=bridleway Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?" }

  range_in_km = 600
  watchlist << { list: get_list({ 'highway' => 'bus_guideway' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ? Czy po prostu zwykła droga po której tylko autobusy mogą jeździć?" }
  range_in_km *= 2
  watchlist << { list: get_list({ 'highway' => 'bus_guideway' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ? Czy po prostu zwykła droga po której tylko autobusy mogą jeździć?" }

  range_in_km = 6
  watchlist << { list: get_list({ 'historic' => 'battlefield' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) historic=battlefield" }
  range_in_km = 40
  watchlist << { list: get_list({ 'historic' => 'battlefield' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) historic=battlefield" }

  #TODO: exclude volcano:status   extinct
  #range_in_km = 300
  #watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  #range_in_km = 400
  #watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  return watchlist
end

#TODO escaping fails (copy pasted to overpass works...)
=begin
    node["name"~"proj\."]["name"!="Nowoprojektowana"];
    way["name"~"proj\."]["name"!="Nowoprojektowana"];
    relation["name"~"proj\."]["name"!="Nowoprojektowana"];
=end

def watch_lifecycle_state_in_the_name
  watchlist = []
  project_mess_query = '[out:json][timeout:250];
  (
    node["name"~"planowan"];
    way["name"~"planowan"];
    relation["name"~"planowan"];

    node["name"~"projektowan"]["name"!="Nowoprojektowana"];
    way["name"~"projektowan"]["name"!="Nowoprojektowana"];
    relation["name"~"projektowan"]["name"!="Nowoprojektowana"];

    node["name"~"w budowie"];
    way["name"~"w budowie"];
    relation["name"~"w budowie"];

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
http://www.openstreetmap.org/note/605791
'
  watchlist << { list: get_list_from_arbitrary_query(query), message: info_message }
  return watchlist
end

# wszystkie nawiasy http://overpass-turbo.eu/s/rpH
# watchlist for rare landuse, surfave values in Kraków
# more https://github.com/osmlab/name-suggestion-index/blob/master/filter.json https://lists.openstreetmap.org/pipermail/talk/2015-May/072923.html
#should be highway=path http://overpass-turbo.eu/s/khG 
#bicycle_road=yes w Krakowie http://overpass-turbo.eu/s/pcO
#site=parking elimination
#(planowany) w osm, (w budowie) nie jest lepsze
#building=bridge w Krakowie - http://overpass-turbo.eu/s/dGR 
#type=site relation http://overpass-turbo.eu/s/fwU 
#name=Ogródki działkowe http://overpass-turbo.eu/s/dr3 
#planowan* - tagowanie pod render http://overpass-turbo.eu/s/dtf 
#landuse=basin bez natural=water

#https://www.openstreetmap.org/way/33711547
#note=taśmociąg na filarach + highway=service
#to man_made=goods_conveyor

# TODO: bardzo stare highway=construction

#TODO - private public toilets https://www.openstreetmap.org/node/3058828370#map=19/-16.51863/35.17363&layers=N

#https://www.openstreetmap.org/changeset/49785062#map=8/46.945/18.215
#building=proposed/destroyed
#landuse=wood


#complicated to fix
#http://overpass-turbo.eu/s/rmN - just tourism=attraction

# Sleeping after big run (II) - next run 2017 X
# wyczyszczone w Polsce na początku 2017 IX
# access=public eliminator http://overpass-turbo.eu/s/rpF

# Sleeping after big run (I) - next run 2018 IV
# wyczyszczone is_in:province w jednym z województw na początku 2017 IX
# http://overpass-turbo.eu/s/r56
#
#is in province http://overpass-turbo.eu/s/rkf
#Eradicate is_in is_in:country
#is_in:county
#is_in:municipality
#is_in:province
#search for other is_in: tags on taginfo
#(punkt widokowy) w nazwie

#poprawiać za pomocą "confirm website" bazowaną na add wikidata
#błedne linki do parafii http://overpass-turbo.eu/s/rpy
