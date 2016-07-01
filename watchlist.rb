# frozen_string_literal: true
require 'json'

def suspicious_name_watchlist_entry(name, description=nil)
  return { list: get_list({ 'name' => name }), message: "name = '#{name}' #{description}" }
end

def watchlist_entries
  watchlist = []

  beton_variation = "Beton"
  tags = { 'surface' => beton_variation }
  beton_problem = "surface=#{beton_variation}? 'beton' is word for concrete in some languages but not in the English"
  overpass_code = 'gT2'
  message = beton_problem + "\n\n" + "See http://overpass-turbo.eu/s/#{overpass_code} for more problems of this type"
  watchlist << { list: get_list(tags), message: message }

  beton_variation = "beton"
  tags = { 'surface' => beton_variation }
  beton_problem = "surface=#{beton_variation}? 'beton' is word for concrete in some languages but not in the English"
  overpass_code = 'gT4'
  message = beton_problem + "\n\n" + "See http://overpass-turbo.eu/s/#{overpass_code} for more problems of this type"
  watchlist << { list: get_list(tags), message: message }

  watchlist << suspicious_name_watchlist_entry('Maszt telekomunikacyjny')
  watchlist << suspicious_name_watchlist_entry('wiatrak')
  watchlist << suspicious_name_watchlist_entry('Wiatrak')
  watchlist << suspicious_name_watchlist_entry('plac zabaw')
  watchlist << suspicious_name_watchlist_entry('Plac zabaw')
  watchlist << suspicious_name_watchlist_entry('Parking', 'Is it really parking named parking or is it just a parking?')
  watchlist << suspicious_name_watchlist_entry('parking', 'Is it really parking named parking or is it just a parking?')
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

  # bardzo stare highway=construction

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

  watchlist << { list: get_list({ 'bicycle' => 'official' }, 50, 20, 3), message: "bicycle=official" }
  watchlist << { list: get_list({ 'bicycle' => 'official' }, 50, 20, 6), message: "bicycle=official" }

  watchlist << { list: get_list({ 'horse' => 'designated' }, 50, 20, 2), message: "bicycle=official" }
  watchlist << { list: get_list({ 'horse' => 'designated' }, 50, 20, 3), message: "bicycle=official" }

  watchlist << { list: get_list({ 'highway' => 'bridleway' }, 50, 20, 3), message: "highway=bridleway Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?" }
  watchlist << { list: get_list({ 'highway' => 'bridleway' }, 50, 20, 6), message: "highway=bridleway Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?" }

  watchlist << { list: get_list({ 'highway' => 'bus_guideway' }, 50, 20, 100), message: "highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ?" }
  watchlist << { list: get_list({ 'highway' => 'bus_guideway' }, 50, 20, 200), message: "highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ?" }

  watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, 5), message: "natural=volcano" }
  watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, 250), message: "natural=volcano" }

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

  # wszystkie nawiasy; http://overpass-turbo.eu/s/gVo

  extended_project_mess_query = '[out:json][timeout:250];
  (
  );
  out body;
  >;
  out skel qt;'

  watchlist << { list: get_list_from_arbitrary_query(extended_project_mess_query), message: "planowane/projektowane ++" }
  # watchlist for rare landuse values in Kraków, ; w surface

  nonmilitary_military_danger = '/*
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
  watchlist << { list: get_list_from_arbitrary_query(nonmilitary_military_danger), message: 'military=danger_area without landuse=military If it is military landuse and landuse=military is missing and should be added.

If not then using **military**=danger_area just because it renders seems to be a poor idea. And either it should be changed or https://wiki.openstreetmap.org/wiki/Tag:military%3Ddanger_area with "landuse=military mandatory" should be changed. 

http://forum.openstreetmap.org/viewtopic.php?pid=598288#p598288 - de thread
' }

#type=site relation http://overpass-turbo.eu/s/fwU

  return watchlist
end

def run_watchlist
  empty = '<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
</osm>'

  puts "access=public eliminator http://overpass-turbo.eu/s/gTt"
  # more https://github.com/osmlab/name-suggestion-index/blob/master/filter.json https://lists.openstreetmap.org/pipermail/talk/2015-May/072923.html

  watchlist_entries.each do |entry|
    mentioned = false
    entry[:list].each do |data|
      range = 0.005
      if data[:lat] == nil or data[:lon] == nil
        raise "#{entry[:message]} has broken data"
      end
      notes = CartoCSSHelper::NotesDownloader.run_note_query(data[:lat], data[:lon], range)
      next if notes.strip != empty
      timestamp_in_h = (Time.now - CartoCSSHelper::NotesDownloader.cache_timestamp(data[:lat], data[:lon], range)).to_i / 60 / 60
      if timestamp_in_h > 1
        notes = CartoCSSHelper::NotesDownloader.run_note_query(data[:lat], data[:lon], range, invalidate_cache: true)
      end
      next if notes.strip != empty
      unless mentioned
        puts
        puts
        puts entry[:message]
        mentioned = true
      end
      timestamp_in_h = (Time.now - CartoCSSHelper::NotesDownloader.cache_timestamp(data[:lat], data[:lon], range)).to_i / 60 / 60
      puts "# #{data[:url]} #{timestamp_in_h}h ago"
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
  puts list
  return list
end

def get_list_from_arbitrary_query(query, required_tags = {})
  json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, "for watchlist #{required_tags}", true)
  obj = JSON.parse(json_string)

  list = []
  locations = get_node_database(obj)
  elements = obj["elements"]

  elements.each do |entry|
    next if not_fully_matching_tag_set(entry["tags"], required_tags)
    next unless entry["type"] == "way"
    lat, lon = locations[entry["nodes"][0]]
    url = "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']}#map=15/#{lat}/#{lon}layers=N"
    if lat == nil or lon == nil
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
