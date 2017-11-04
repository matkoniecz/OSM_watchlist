# frozen_string_literal: true

# man_made=pier bez highway=footway
#http://overpass-turbo.eu/s/qAX
# http://www.openstreetmap.org/relation/2222174



# boundary=historic http://overpass-turbo.eu/s/rEQ
require 'json'
require_relative 'watchlist_infrastructure'

def run_watchlist
  dump_descriptive_names_entries_to_stdout()
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

def watchlist_entries
  requested_total_entries = 20
  watchlist = []
  watchlist += watch_beton if count_entries(watchlist) < requested_total_entries
  watchlist += watch_other if count_entries(watchlist) < requested_total_entries
  watchlist += watch_invalid_wikipedia if count_entries(watchlist) < requested_total_entries
  watchlist += watch_valid_tags_unexpected_in_krakow if count_entries(watchlist) < requested_total_entries
  watchlist += watch_descriptive_names(requested_total_entries - count_entries(watchlist))
  watchlist += watch_tree_species_in_name if count_entries(watchlist) < requested_total_entries
  watchlist += watch_lifecycle_state_in_the_name if count_entries(watchlist) < requested_total_entries
  watchlist += objects_using_this_name_part('naprawdę warto', 'spam')
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

def watch_other
  watchlist = []
  watchlist << { list: get_list({'leisure' => 'park', 'landuse' => 'industrial'}), message: 'leisure=park is not for industrial park' }
  watchlist << { list: get_list({'steps' => 'yes', 'highway' => {operation: :not_equal_to, value: "steps"}}), message: 'Why this is not tagged as highway=steps? What is the meaning of steps=yes here? See http://overpass-turbo.eu/s/sLv for more cases.', overpass: 'http://overpass-turbo.eu/s/sLv' }
  return watchlist
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

def dump_descriptive_names_entries_to_stdout()
  descriptive_names_entries.each do |entry|
    query = entry[:overpass]
    if query == nil
      query = ""
    else
      query = " [overpass: #{query} ]"
    end
    puts "# name=#{entry[:name]}#{query}"
  end
end

def descriptive_names_entries
  return [
    # in https://github.com/osmlab/name-suggestion-index
    {name: 'parking', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'plac zabaw', language: 'pl', matching_tags: [{'leisure' => 'playground'}], overpass: 'http://overpass-turbo.eu/s/qZ6'},
    {name: 'playground', language: 'en', matching_tags: [{'leisure' => 'playground'}], overpass: 'http://overpass-turbo.eu/s/qZ8'},
    {name: 'boisko', language: 'pl', matching_tags: [{'leisure' => 'pitch'}], overpass: 'http://overpass-turbo.eu/s/s6F'},
    {name: 'boisko sportowe', language: 'pl', matching_tags: [{'leisure' => 'pitch'}]},
    {name: 'Boisko Sportowe', language: 'pl', matching_tags: [{'leisure' => 'pitch'}]},
    {name: 'garaż', language: 'pl'},
    {name: 'garaże', language: 'pl'},
    {name: 'garage', language: 'en'},
    {name: 'garages', language: 'en'},
    {name: 'fontanna', language: 'pl', matching_tags: [{'amenity' => "fountain"}]},
    {name: 'fountain', language: 'en', matching_tags: [{'amenity' => "fountain"}]},
    #{name: 'apteka', language: 'pl', overpass: 'http://overpass-turbo.eu/s/qZa'},
    {name: 'restaurant', language: 'en', matching_tags: [{'amenity' => 'restaurant'}]},
    {name: 'las', language: 'pl', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},
    {name: 'forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}], overpass: 'http://overpass-turbo.eu/s/rpK'},
    {name: 'kiosk', language: 'pl', matching_tags: [{'shop' => 'kiosk'}], overpass: 'http://overpass-turbo.eu/s/qYg'},
    {name: 'sklep', language: 'pl', matching_tags: [{'shop' => :any_value}]},

    # proposed in PR for https://github.com/osmlab/name-suggestion-index

    # not in https://github.com/osmlab/name-suggestion-index
    {name: 'staw', language: 'pl', matching_tags: [{'natural' => 'water'}]},

    {name: 'water tap', language: 'en', complaint: "water tap - to copy: <\n  man_made = water_tap\n  description = Water tap\n> overpass query helper: http://overpass-turbo.eu/s/qZe", matching_tags: [{'man_made' => 'water_tap'}]},
    {name: 'park', language: 'en', matching_tags: [{'leisure' => 'park'}], overpass: 'http://overpass-turbo.eu/s/qZb'},
    {name: 'park', language: 'pl', matching_tags: [{'leisure' => 'park'}], overpass: 'http://overpass-turbo.eu/s/qZb'},
    {name: 'restauracja', language: 'pl', matching_tags: [{'amenity' => 'restaurant'}]},
    {name: 'lighthouse', language: 'en'},
    {name: 'scrub', language: 'en', matching_tags: [{'natural' => 'scrub'}]},
    {name: 'kamieniołom', language: 'pl'},
    {name: 'quarry', language: 'en'},
    {name: 'water', language: 'en', matching_tags: [{'amenity' => 'drinking_water'}]},
    {name: 'viewpoint', language: 'en', matching_tags: [{'tourism' => 'viewpoint'}]},
    {name: 'boisko do koszykówki', language: 'pl', matching_tags: [{'leisure' => 'pitch', 'sport' => 'basketball'}]},
    {name: 'koszykówka', language: 'pl', matching_tags: [{'leisure' => 'pitch', 'sport' => 'basketball'}]},
    {name: 'siatkówka plażowa', language: 'pl', matching_tags: [{'leisure' => 'pitch', 'sport' => 'beachvolleyball'}]},
    {name: 'boisko piłki nożnej', language: 'pl', matching_tags: [{'leisure' => 'pitch', 'sport' => 'soccer'}]},
    {name: 'boisko do siatkówki', language: 'pl', matching_tags: [{'leisure' => 'pitch', 'sport' => 'volleyball'}]},
    {name: 'boisko do piłki nożnej', language: 'pl', matching_tags: [{'leisure' => 'pitch', 'sport' => 'soccer'}]},
    {name: 'kort tenisowy', language: 'pl', matching_tags: [{'leisure' => 'pitch', 'sport' => 'tennis'}]},
    {name: 'maszt telekomunikacyjny', language: 'pl'},
    {name: 'wieża telekomunikacyjna', language: 'pl'},
    {name: 'wiatrak', language: 'pl', matching_tags: [{'building' => :any_value}]},
    {name: 'wiatrak', language: 'pl', matching_tags: [{'building' => :any_value}]},
    {name: 'building', language: 'en', matching_tags: [{'building' => :any_value}]},
    {name: 'plac zabaw dla dzieci', language: 'pl', matching_tags: [{'leisure' => 'playground'}]},
    {name: 'parking bezpłatny', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'parking strzeżony', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'Parking Strzeżony', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'Public Parking', language: 'en', matching_tags: [{'amenity' => 'parking'}], overpass: 'http://overpass-turbo.eu/s/qZf'},
    {name: 'free parking', language: 'en', complaint: 'free parking tagged using name rather than fee tag', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'supervised parking', language: 'en', complaint: 'supervised parking tagged using name rather than proper tag', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'śmietnik', language: 'pl', complaint: 'OSM data sometimes makes clear that <amenity = waste_disposal> is missing', matching_tags: [{'amenity' => 'waste_disposal'}], overpass: 'http://overpass-turbo.eu/s/qZh'},
    {name: 'dojazd do przedszkola', language: 'pl'},
    {name: 'tablica informacyjna', language: 'pl', matching_tags: [{'information' => "board"}]},
    {name: 'wieża kościelna', language: 'pl', complaint: 'wieża kościelna (zamienić na   description = Wieża kościelna?, dodać man_made = tower)', overpass: 'http://overpass-turbo.eu/s/qZo'},
    {name: 'mieszkanie', language: 'pl'},
    {name: 'dom', language: 'pl', matching_tags: [{'building' => :any_value}, {'historic' => 'ruins'}]},
    {name: 'obora', language: 'pl', matching_tags: [{'building' => :any_value}]},
    {name: 'barn', language: 'en', matching_tags: [{'building' => :any_value}]},
    {name: 'dom', language: 'en', matching_tags: [{'building' => :any_value}]},
    {name: 'studnia', language: 'en', matching_tags: [{'man_made' => 'water_well'}]},
    {name: 'droga lokalna', language: 'pl', matching_tags: [{'highway' => :any_value}]},
    {name: 'droga prywatna', language: 'pl', matching_tags: [{'highway' => :any_value}]},
    {name: 'open field', language: 'en', complaint: 'what kind of open field is here?'},
    {name: 'pole', language: 'pl', complaint: 'what kind of open field is here?'},
    {name: 'budynek gospodarczy', language: 'pl'},
    {name: 'drzewo', language: 'pl'},
    {name: 'torfowiska', language: 'pl', matching_tags: [{'natural' => 'wetland'}]},
    {name: 'shelter', language: 'en', matching_tags: [{'amenity' => 'shelter'}]},
    {name: 'picnic table', language: 'en', matching_tags: [{'leisure' => 'picnic_table'}]},
    {name: 'steps', language: 'en', matching_tags: [{'highway' => 'steps'}]},

    {name: 'big forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},
    {name: 'small forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},
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

  watchlist += detect_tags_in_region(lat, lon, 1000, { 'boundary' => 'historic', 'end_date': {operation: :not_equal_to, value: :any_value} }) #1 295 -> 1 280 (w tym 634 way) -> 1 274 (w tym 630 way) in 2017 IX  
  watchlist += detect_tags_in_region(lat, lon, 20, { 'bicycle' => 'official' })
  
  #after fixing revisit https://github.com/openstreetmap/iD/issues/4501
  watchlist += detect_tags_in_region(lat, lon, 20, { 'disused' => 'yes' })
  watchlist += detect_tags_in_region(lat, lon, 200, { 'demolished' => 'yes' })
  watchlist += detect_tags_in_region(lat, lon, 20, { 'abandoned' => 'yes' })
  
  watchlist += detect_tags_in_region(lat, lon, 200, { 'capacity:disabled' => 'unknown' })

  watchlist += detect_tags_in_region(lat, lon, 20, {'highway': 'proposed', 'source': {operation: :not_equal_to, value: :any_value}})
  watchlist += detect_tags_in_region(lat, lon, 100, { 'historic' => 'battlefield' }) #1 653 in 2017 IX
  watchlist += detect_tags_in_region(lat, lon, 200, { 'horse' => 'designated' }, "tu serio jest chodnik z wyznaczoną po nim trasą dla koni?")
  watchlist += detect_tags_in_region(lat, lon, 25, { 'highway' => 'bridleway' }, "Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?")
  watchlist += detect_tags_in_region(lat, lon, 2500, { 'highway' => 'bus_guideway' }, "#highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ? Czy po prostu zwykła droga po której tylko autobusy mogą jeździć?")
  #end_date - catch entries deep in past and in the far future
  #TODO: exclude volcano:status   extinct
  #range_in_km = 300
  #watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  #range_in_km = 400
  #watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  return watchlist
end

def detect_tags_in_region(lat, lon, range_in_km, tags, message="")
  watchlist = []
  range_in_km /= 2
  watchlist << { list: get_list(tags, lat, lon, range_in_km), message: "(#{range_in_km}km range) #{tags} #{message}" }
  range_in_km *= 2
  watchlist << { list: get_list(tags, lat, lon, range_in_km), message: "(#{range_in_km}km range) #{tags} #{message}" }
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

# name without name:pl (dla map które pokazują name:pl, potem name:en, potem name:de, potem name - a chcemy by w polsce dalej pokazywały pl)
# compartive advantage
# mass edit

# amenity=shop
# https://taginfo.openstreetmap.org/tags/construction=yes#combinations

=begin
/*
This has been generated by the overpass-turbo wizard.
The original search was:
“lnaduse!=industrial and industrial=* and building!=* in Poland”
*/
[out:json][timeout:625];
// fetch area “Poland” to search in
{{geocodeArea:Poland}}->.searchArea;
// gather results
(
  // query part for: “lnaduse!=industrial and industrial=* and building!=*”
  node["lnaduse"!="industrial"]["industrial"]["building"!~".*"](area.searchArea);
  way["lnaduse"!="industrial"]["industrial"]["building"!~".*"](area.searchArea);
  relation["lnaduse"!="industrial"]["industrial"]["building"!~".*"](area.searchArea);
);
// print results
out body;
>;
out skel qt; 
=end
# retag rare tags from https://github.com/simonpoole/beautified-JOSM-preset/issues/35

#print("https://osm.wikidata.link/candidates/relation/2768922 (Kraków)")
#print("https://osm.wikidata.link/candidates/relation/2654452 (powiat krakowski)")
#print("https://osm.wikidata.link/candidates/relation/2907540 (Warszawa)")
#print("https://osm.wikidata.link/filtered/Poland")
#https://osm.wikidata.link/candidates/relation/2675559 mazury
#https://osm.wikidata.link/candidates/relation/2675566 mazury
#https://osm.wikidata.link/candidates/relation/2675509 mazury
#https://osm.wikidata.link/candidates/relation/2675563 mazury


# https://wiki.openstreetmap.org/wiki/SPARQL_examples#Find_.22Featured.22_wiki_articles_with_location.2C_but_without_OSM_connection
# https://wiki.openstreetmap.org/wiki/User_talk:Yurik - wait for answers
# man_made=pier bez highway=footway
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

# missing military=bunker http://overpass-turbo.eu/s/sAw
# tourims=attraction + name http://overpass-turbo.eu/s/sAr
# https://forum.openstreetmap.org/viewtopic.php?pid=666735#p666735
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
#waterway=canal + area=yes
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
#["concentration_camp"="nazism"]["amenity"="prison"]
#(name=Żabka or name=żabka) and shop!=convenience (if generally true submit normalization to https://github.com/osmlab/name-suggestion-index/issues )
#detect violations of nixed values in https://github.com/osmlab/name-suggestion-index/issues, consider submitting them to JOSM validator

=begin


albo highway=track albo landuse=residential są błędne

highway=track to droga do obsługi pola/lasu, stan drogi oznacza się przy pomocy tagów smoothness i surface


/*
This has been generated by the overpass-turbo wizard.
The original search was:
“highway=track and name=*”
*/
[out:json][timeout:75];
// gather results
(
  // query part for: “highway=track and name=*”
  node["highway"="track"]["name"]({{bbox}});
  way["highway"="track"]["name"]({{bbox}});
  relation["highway"="track"]["name"]({{bbox}});
);
// print results
out body;
>;
out skel qt; 
=end