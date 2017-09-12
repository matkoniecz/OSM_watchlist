# frozen_string_literal: true
#http://overpass-turbo.eu/s/qAX
require 'json'

def watchlist_entries
  requested_total_entries = 20
  watchlist = []
  watchlist += watch_beton if count_entries(watchlist) < requested_total_entries
  watchlist += watch_invalid_wikipedia if count_entries(watchlist) < requested_total_entries
  watchlist += watch_valid_tags_unexpected_in_krakow if count_entries(watchlist) < requested_total_entries
  watchlist += watch_descriptive_names(requested_total_entries - count_entries(watchlist))
  watchlist += watch_tree_species_in_name if count_entries(watchlist) < requested_total_entries
  watchlist += watch_lifecycle_state_in_the_name if count_entries(watchlist) < requested_total_entries
  watchlist += objects_using_this_name_part('naprawdę warto', 'spam')
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

def count_entries(watchlist)
  count = 0
  watchlist.each do |entry|
    entry[:list].each do |data|
      if data[:lat].nil? || data[:lon].nil?
        raise "#{entry[:message]} has broken data"
      end
      if currently_present_note_at(data[:lat], data[:lon])
        next
      end
      count += 1
    end
  end
  return count
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
    url = "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']}#map=17/#{lat}/#{lon}layers=N"
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

def suspicious_name_watchlist_entry(name:, language_code_of_name:, description: nil, matching_tag_list: [{}], overpass_url: nil)
  # TODO rename to objects_using_this_name
  # TODO switch description and matching_tag_list
  # TODO add prefix to description with correct name tag value and name tag
  #TODO support nonacsii https://stackoverflow.com/a/38016153/4130619
  returned = []
  name_variants = [
    {key: 'name', value: name},
    {key: 'name', value: name.capitalize},
    {key: 'name:'+language_code_of_name, value: name},
    {key: 'name:'+language_code_of_name, value: name.capitalize},
  ]

  matching_tag_list.each do |required_tags|
    name_variants.each do |data|
      required_tags_info = ""
      required_tags_info = "with #{required_tags.to_s}" if required_tags != {}
      tags = { data[:key] => data[:value] }.merge(required_tags)
      returned << { list: get_list(tags), message: "#{data[:key]} = '#{data[:value]}' #{description} #{required_tags_info} (#{overpass_url})" }
    end
  end

  name_variants.each do |data|
    # exclude cases of locations where bizarre names may happen
    reverse_required_tags = {
        'place': {operation: :not_equal_to, value: :any_value},
        'amenity': {operation: :not_equal_to, value: "restaurant"},
        'natural': {operation: :not_equal_to, value: "peak"}
      }
    matching_tag_list.each.each do |key, value|
      if value.class == Hash
        if value[:operation] == :not_equal_to
          reverse_required_tags['key'] = value
        else
          raise "unexpected operation in #{value}"
        end
      else
        reverse_required_tags['key'] = {operation: :not_equal_to, value: value}
      end
    end
    required_tags_info = ""
    required_tags_info = "with #{reverse_required_tags.to_s}" if reverse_required_tags != {}
    tags = { data[:key] => data[:value] }.merge(reverse_required_tags)
    returned << { list: get_list(tags), message: "#{data[:key]} = '#{data[:value]}' #{description} #{required_tags_info} (#{overpass_url})" }
  end
  return returned
end

def objects_using_this_name_part(name_part, description)
  return [{ list: list_of_objects_with_this_name_part(name_part), message: description }]
end

def watch_descriptive_names(requested_entries)
  #https://wiki.openstreetmap.org/wiki/Naming_conventions#Don.27t_describe_things_using_name_tag
  #see also https://github.com/osmlab/name-suggestion-index - names should end here to discourage iD users from using them
  #user facing complaint: 
  # Czy tag name nie jest tu przypadkiem błędnie użyty jako opis obiektu? leisure=playground wystarcza by oznaczyć to jako plac zabaw.
  # Is it really parking named parking or is it just a parking and name tag is incorrectly used as a description?

  #name=parking zakomentowanee bo otworzyłem dużo notek i czekam na reakcje
  #name=apteka zakomentowane bo styl domyślny ma słabą ikonkę

  watchlist = []
  watchlist += objects_using_this_name_part('boisko do gry w', 'name used instead sport tags')
  descriptive_names_entries.each do |entry|
    return watchlist if count_entries(watchlist) >= requested_entries
    matching_tag_list = entry[:matching_tags]
    matching_tag_list ||= [{}]
    watchlist += suspicious_name_watchlist_entry(name: entry[:name], language_code_of_name: entry[:language], matching_tag_list: matching_tag_list, overpass_url: entry[:overpass])
  end
  return watchlist
end

def descriptive_names_entries
  return [
    {name: 'boisko', language: 'pl', matching_tags: [{'leisure' => 'pitch'}]},
    {name: 'maszt telekomunikacyjny', language: 'pl'},
    {name: 'wieża telekomunikacyjna', language: 'pl'},
    {name: 'wiatrak', language: 'pl', matching_tags: [{'building' => :any_value}]},
    {name: 'plac zabaw', language: 'pl', matching_tags: [{'leisure' => 'playground'}], overpass: 'http://overpass-turbo.eu/s/qZ6'},
    {name: 'plac zabaw dla dzieci', language: 'pl', matching_tags: [{'leisure' => 'playground'}]},
    {name: 'playground', language: 'en', matching_tags: [{'leisure' => 'playground'}], overpass: 'http://overpass-turbo.eu/s/qZ8'},
    {name: 'parking', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'parking bezpłatny', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'parking strzeżony', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'Parking Strzeżony', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'Public Parking', language: 'en', matching_tags: [{'amenity' => 'parking'}], overpass: 'http://overpass-turbo.eu/s/qZf'},
    {name: 'free parking', language: 'en', complaint: 'free parking tagged using name rather than fee tag', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'supervised parking', language: 'en', complaint: 'supervised parking tagged using name rather than proper tag', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'śmietnik', language: 'pl', complaint: 'OSM data sometimes makes clear that <amenity = waste_disposal> is missing', matching_tags: [{'amenity' => 'waste_disposal'}], overpass: 'http://overpass-turbo.eu/s/qZh'},
    {name: 'kiosk', language: 'pl', matching_tags: [{'shop' => 'kiosk'}], overpass: 'http://overpass-turbo.eu/s/qYg'},
    {name: 'dojazd do przedszkola', language: 'pl'},
    {name: 'apteka', language: 'pl', overpass: 'http://overpass-turbo.eu/s/qZa'},
    {name: 'kamieniołom', language: 'pl'},
    {name: 'quarry', language: 'en'},
    {name: 'garaż', language: 'pl'},
    {name: 'garaże', language: 'pl'},
    {name: 'garage', language: 'en'},
    {name: 'garages', language: 'en'},
    {name: 'fontanna', language: 'pl', matching_tags: [{'amenity' => "fountain"}]},
    {name: 'fountain', language: 'en'},
    {name: 'tablica informacyjna', language: 'pl', matching_tags: [{'information' => "board"}]},
    {name: 'las', language: 'pl', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},
    {name: 'forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}], overpass: 'http://overpass-turbo.eu/s/rpK'},
    {name: 'big forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},
    {name: 'small forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},
    {name: 'wieża kościelna', language: 'pl', complaint: 'wieża kościelna (zamienić na   description = Wieża kościelna?, dodać man_made = tower)', overpass: 'http://overpass-turbo.eu/s/qZo'},
    {name: 'mieszkanie', language: 'pl'},
    {name: 'dom', language: 'pl', matching_tags: [{'building' => :any_value}, {'historic' => 'ruins'}]},
    {name: 'obora', language: 'pl', matching_tags: [{'building' => :any_value}]},
    {name: 'barn', language: 'en', matching_tags: [{'building' => :any_value}]},
    {name: 'dom', language: 'en', matching_tags: [{'building' => :any_value}]},
    {name: 'restauracja', language: 'pl', matching_tags: [{'amenity' => 'restaurant'}]},
    {name: 'restaurant', language: 'en', matching_tags: [{'amenity' => 'restaurant'}]},
    {name: 'sklep', language: 'en', matching_tags: [{'shop' => :any_value}]},
    {name: 'open field', language: 'en', complaint: 'what kind of open field is here?'},
    {name: 'water tap', language: 'en', complaint: "water tap - to copy: <\n  man_made = water_tap\n  description = Water tap\n> overpass query helper: http://overpass-turbo.eu/s/qZe", matching_tags: [{'man_made' => 'water_tap'}]},
    {name: 'park', language: 'en', matching_tags: [{'leisure' => 'park'}], overpass: 'http://overpass-turbo.eu/s/qZb'},
    {name: 'park', language: 'pl', matching_tags: [{'leisure' => 'park'}], overpass: 'http://overpass-turbo.eu/s/qZb'},
    {name: 'budynek gospodarczy', language: 'pl'},
    {name: 'drzewo', language: 'pl'},
    {name: 'lighthouse', language: 'en'},
  ]
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
  lat = 50
  lon = 20
  watchlist += detect_tags_in_region(lat, lon, 1000, 'boundary', 'historic') #1 295 -> 1 280 (w tym 634 way) in 2017 IX
  watchlist += detect_tags_in_region(lat, lon, 100, 'historic', 'battlefield') #1 653 in 2017 IX
  watchlist += detect_tags_in_region(lat, lon, 100, 'horse', 'designated')
  watchlist += detect_tags_in_region(lat, lon, 25, 'highway', 'bridleway', "Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?")
  watchlist += detect_tags_in_region(lat, lon, 2500, 'highway', 'bus_guideway', "#highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ? Czy po prostu zwykła droga po której tylko autobusy mogą jeździć?")

  #TODO: exclude volcano:status   extinct
  #range_in_km = 300
  #watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  #range_in_km = 400
  #watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  return watchlist
end

def detect_tags_in_region(lat, lon, range_in_km, key, value, message="")
  watchlist = []
  range_in_km /= 2
  watchlist << { list: get_list({ key => value }, lat, lon, range_in_km), message: "(#{range_in_km}km range) #{key}=#{value} #{message}" }
  range_in_km *= 2
  watchlist << { list: get_list({ key => value }, lat, lon, range_in_km), message: "(#{range_in_km}km range) #{key}=#{value} #{message}" }
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

  watchlist << { list: get_list_from_arbitrary_query(project_mess_query), message: "planowane/projektowane" }
  return watchlist
end

# shop, bank etc with wikipedia tag
# https://www.openstreetmap.org/changeset/49958115
#https://www.openstreetmap.org/changeset/49785062#map=8/46.881/18.215
#Czy są tu jakieś pozostałości po bitwie? Jeśli tak to powiny zostać zmapowane, jeśli nie to jest to do skasowania.
#"historic=battlefield to tag niezgodny z zasadami OSM, ale używany i wygląda na tolerowany."
#To pora przestać go tolerować zanim więcej osób zacznie do OSM wsadzać wydarzenia (lepiej by wykasować to zanim sie zrobi popularne, mniej osób straci wtedy czasu na ich dodawanie)
# https://www.openstreetmap.org/changeset/51522177#map=13/54.0944/21.6133&layers=N
#name   Zbiornik ppoż.
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
# http://www.openstreetmap.org/changeset/39896451#map=7/51.986/19.100

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

=begin
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
=end