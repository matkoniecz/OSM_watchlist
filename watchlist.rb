=begin
https://wiki.openstreetmap.org/wiki/Default_speed_limits

quest for missing addr:street https://github.com/westnordost/StreetComplete/issues/213

https://www.openstreetmap.org/changeset/59363976 removal ready

next idea: http://overpass-turbo.eu/s/zvd





https://www.openstreetmap.org/changeset/34413443




-------
    While iD design may exclude flooding user with warnings - why its rendering suggests that for example [building=yes; demolished=yes] is a good idea?

I already told you why here:  https://github.com/openstreetmap/iD/issues/4501#issuecomment-393726776

Any feature with any kind of ephemeral tag gets drawn with dashes.

iD also have a special rendering for old style multipolygons, so people can clean them up if they want to. Rendering something with dashes doesn’t mean we are encouraging people to tag a certain way - it just means “hey mapper, pay attention to this thing, there is something interesting about it”.

Please start a separate discussion thread if you want to discuss lifecycle tagging. 


-----
> OK, so we should probably have a conversation about how a tag like this can continue to exist for years


Part of the issue is that currently only JOSM considers encouraging users to not use completely
broken tags as something important.


While iD design may exclude flooding user with warnings -
 why its rendering suggests that for example [building=yes; demolished=yes] is a good idea?



Current rendering suggests to editors that it is great idea to tag this way - see
https://upload.wikimedia.org/wikipedia/commons/5/51/Special_rendering_for_demolished%3Dyes_in_iD_editor_of_OSM_data.png <https://upload.wikimedia.org/wikipedia/commons/5/51/Special_rendering_for_demolished%3Dyes_in_iD_editor_of_OSM_data.png>



I think that editors needs to take responsibility for the tags encouraged not only
by the presets but also by the map style and automatically generated suggestions.

Removing rendering suggesting that this tag is a proper way to tag that was
refused in https://github.com/openstreetmap/iD/issues/4501

And there is a direct claim that removing this support for demolished=yes is not helpful
("Removing demolished from that array is not going to make iD better.").

It was even closed as a special wontfix-ISATIDL (popup after hovering on this label defines

it as "I saw a thing I don't like (but is valid in OpenStreetMap)") and closed to comments as

a bonus.

--------

highway=pedestrian definition na wiki

https://wiki.openstreetmap.org/wiki/OpenCycleMap - report bug

https://forum.openstreetmap.org/viewtopic.php?id=62477 fixme="Popraw kod pocztowy" z punktów

https://taginfo.openstreetmap.org/tags/wikipedia=en%3AMunicipalities_of_Albania

poprawić mojego bota i wyedytowac co już mogę (obsługa przekierowań następnym krokiem - pewnie mode "edytuj za potwierdzeniem" jest potrzebny)

https://wiki.openstreetmap.org/wiki/Mechanical_Edits/Mateusz_Konieczny_-_bot_account

download from taginfo, discard highway=*, waterway, rail=*
report offenders
https://taginfo.openstreetmap.org/api/4/key/values?key=wikipedia&filter=all&lang=en&sortname=count&sortorder=desc&page=1&rp=21&qtype=value&format=json_pretty

(historical) post offices - easy to check with Bing


Block deprecated unused tag values fetched from wiki
https://github.com/openstreetmap/iD/issues/4508
"The OSM community needs to take responsibility for the tags (...) if sport=football is indeed deprecated, then somebody should make a Maproulette challenge or something to clean them up. iD will stop suggesting the tag when it is no longer in widespread use."

    Since sport=gaelic_football has a wiki page, it gets returned.

So if gaelic_football goes down to zero uses, it will still be returned because it has a wiki page? Even if the wiki page is only there to tell people the tag is deprecated - probably like the rest in this category: 
=end


=begin
#Polskoliterkowe nazwy w Polsce - ekspresowe name:pl

instalujemy plugin todo w JOSMie

pobieramy
wybieramy duplicate
konwertujemy do GPX
filtr "type:node"
dodajemy wszystko do TODO listy (ctrl+a by zaznaczyc wszystko)
pobieramy automatycznie to co blisko

=end

=begin
https://www.openstreetmap.org/changeset/59434668

delete historic data. It is unlikely to be added to OSM by mistake so it is not worth keeping as protection against invalid edits. Also, this historic data should never be added to OSM - OSM is not place to map what existed in past


This object is still visible on some aerial images (for example Esri). It is kept to prevent mistaken remapping of this object. Delete it once aerial images are updated.

area=yes on inners



Provide autofix to remove completely useless area=yes (useless both as a tag and as indicator of real issues) from inner multipolygons ways

There is a repeated minor tagging issue - multipolygons with area=yes at inner ways that are not tagged with other tags. Such area=yes ag is utterly useless.

Unlike standalone ways without tags other than area=yes this areas are not indicating unfinished edit, in my experience (after processing hundrets cases of such ways) are not useful as indicators of further problems, and may be safely removed automatically.

- it would allow to split "missing tag - incomplete object: only area" warning into two categories - one requiring detailed investigation and one that may be quickly processed
- in this case this tag is utterly useless and may eb safely removed
- some people may become confused and start to think that area=yes tag is necessary in such cases
- people searching for ways with just area=yes (with http://overpass-turbo.eu/s/y6v or similar) to fix mistakes by newbies and finish their edits are spammed by useless area=yes on inners (yes - it is possible to make more complicated query filtering out area=yes on inners, but each person doing this wuld need to vcraft their own query or find it)

Examples:

https://www.openstreetmap.org/way/301002606
https://www.openstreetmap.org/way/311398712
https://www.openstreetmap.org/way/563806248
https://www.openstreetmap.org/way/434845918
https://www.openstreetmap.org/way/427315084

Such cases of area=yes may be found using http://overpass-turbo.eu/s/y6w

[out:xml][timeout:725];
rel({{bbox}})[type=multipolygon]->.relations;
(  way(r.relations:"inner")(if:count_tags() == 1)[area=yes];
);
(._;>;);
out meta;



mix of various fixes required:




[out:xml][timeout:725][bbox:{{bbox}}];
(
  node["area"="yes"][name](if:count_tags() == 2)({{bbox}});
  way["area"="yes"][name](if:count_tags() == 2)({{bbox}});
  relation["area"="yes"][name](if:count_tags() == 2)({{bbox}});

  node["area"="yes"](if:count_tags() == 1)({{bbox}});
  way["area"="yes"](if:count_tags() == 1)({{bbox}});
  relation["area"="yes"](if:count_tags() == 1)({{bbox}});
);
(._;>;);
out meta;

[out:xml][timeout:725][bbox:{{bbox}}];
(
  //names - useful if you know language used by typical mapper
  //not covered(?) by watchlist querries
  node["area"="yes"][name](if:count_tags() == 2)({{bbox}});
  way["area"="yes"][name](if:count_tags() == 2)({{bbox}});
  relation["area"="yes"][name](if:count_tags() == 2)({{bbox}});
  node[tourism=attraction][name](if:count_tags()==2)({{bbox}});
  way[tourism=attraction][name](if:count_tags()==2)({{bbox}});

  //not covered(?) by watchlist querries
  node["area"="yes"](if:count_tags() == 1)({{bbox}});
  way["area"="yes"](if:count_tags() == 1)({{bbox}});
  relation["area"="yes"](if:count_tags() == 1)({{bbox}});

  //covered by other watchlist querries
  node["leisure"="pitch"]["name"="boisko"]["sport"="soccer"];
  way["leisure"="pitch"]["name"="boisko"]["sport"="soccer"];
  relation["leisure"="pitch"]["name"="boisko"]["sport"="soccer"];
  node["leisure"="pitch"]["name"="Boisko"]["sport"="soccer"];
  way["leisure"="pitch"]["name"="Boisko"]["sport"="soccer"];
  relation["leisure"="pitch"]["name"="Boisko"]["sport"="soccer"];
  node["leisure"="pitch"]["name"="kort tenisowy"]["sport"="tennis"];
  way["leisure"="pitch"]["name"="kort tenisowy"]["sport"="tennis"];
  relation["leisure"="pitch"]["name"="kort tenisowy"]["sport"="tennis"];
  node["leisure"="pitch"]["name"="Kort tenisowy"]["sport"="tennis"];
  way["leisure"="pitch"]["name"="Kort tenisowy"]["sport"="tennis"];
  relation["leisure"="pitch"]["name"="Kort tenisowy"]["sport"="tennis"];

  //not covered(?) by watchlist querries
  node["boundary"="historic"];
  way["boundary"="historic"]["end_date"!~"2007"]["end_date"!~"2008"]["end_date"!~"2009"]["end_date"!~"2010"]["end_date"!~"2011"]["end_date"!~"2012"]["end_date"!~"2013"]["end_date"!~"2014"]["end_date"!~"2015"]["end_date"!~"2016"]["end_date"!~"2017"]["end_date"!~"2018"];
  relation["boundary"="historic"]["end_date"!~"2007"]["end_date"!~"2008"]["end_date"!~"2009"]["end_date"!~"2010"]["end_date"!~"2011"]["end_date"!~"2012"]["end_date"!~"2013"]["end_date"!~"2014"]["end_date"!~"2015"]["end_date"!~"2016"]["end_date"!~"2017"]["end_date"!~"2018"];

  //covered by other watchlist querries
  node[highway]["addr:housenumber"][website];
  way[highway]["addr:housenumber"][website];
  relation[highway]["addr:housenumber"][website];


  //not covered(?) by watchlist querries
  //skip explicitly tagged as public
  node["toilets:access"]["amenity"="toilets"]['toilets:access'!='public'];
  way["toilets:access"]["amenity"="toilets"]['toilets:access'!='public'];
  relation["toilets:access"]["amenity"="toilets"]['toilets:access'!='public'];
  //include ones explicitly tagged as public and tagged as not public at the same time
  node["toilets:access"][access]["amenity"="toilets"]['toilets:access'!='access'];
  way["toilets:access"][access]["amenity"="toilets"]['toilets:access'!='access'];
  relation["toilets:access"][access]["amenity"="toilets"]['toilets:access'!='access'];

  //certainly not covered by watchlist querries
  way[man_made=bridge][building]({{bbox}});
  way[opening_date](if:date(t[opening_date])<date("{{date:0 days}}"))({{bbox}});
  );
(._;>;);
out meta;

http://overpass-turbo.eu/s/yMm - vehicle=destination in Kraków, usually (always?) wrong

is an area=yes remaining from unfinished edit without obvious purpose. Is it representing something or is it an area for deletion?



untagged objects - memory intensive, use area smaller than małopolska:

[out:xml][timeout:525];
way({{bbox}})(if:count_tags()==0)->.w1;
rel(bw.w1);way(r)->.w2;
(.w1; - .w2;);
(._; >;);
out meta;


#https://wiki.openstreetmap.org/wiki/Key:teryt:simc - jest link walidujący, powtarzane kody - skopiowany poniżęj
[out:json][timeout:625];
// fetch area “Poland” to search in
{{geocodeArea:Poland}}->.searchArea;
// gather results
(
  // query part for: “"teryt:simc"=* and place!=city and place!=town and place!=suburb and place!=quarter and place!=neighbourhood and place!=village and place!=isolated_dwelling and place!=hamlet and place!=locality and boundary!=administrative”
  node["teryt:simc"]["place"!="city"]["place"!="town"]["place"!="suburb"]["place"!="quarter"]["place"!="neighbourhood"]["place"!="village"]["place"!="isolated_dwelling"]["place"!="hamlet"]["place"!="locality"]["boundary"!="administrative"](area.searchArea);
  way["teryt:simc"]["place"!="city"]["place"!="town"]["place"!="suburb"]["place"!="quarter"]["place"!="neighbourhood"]["place"!="village"]["place"!="isolated_dwelling"]["place"!="hamlet"]["place"!="locality"]["boundary"!="administrative"](area.searchArea);
  relation["teryt:simc"]["place"!="city"]["place"!="town"]["place"!="suburb"]["place"!="quarter"]["place"!="neighbourhood"]["place"!="village"]["place"!="isolated_dwelling"]["place"!="hamlet"]["place"!="locality"]["boundary"!="administrative"](area.searchArea);
);
// print results
out body;
>;
out skel qt;

# highway=* z name=żółty szlak rowerowy
https://github.com/osmlab/name-suggestion-index/issues/91


dodać to info na wiki:
Bar mleczny w nazwie z amenity=bar - scan
Dla baru mlecznego pasuje amenity=fast_food, ewentualnie amenity=restaurant

https://github.com/westnordost/StreetComplete/pull/1092#issuecomment-393595096
=end
# poprawić notki w terenie - potem zwiększyć zasięg w watch_valid_tags_unexpected_in_krakow

=begin
akwtyne
spam fixme rowersa
https://forum.openstreetmap.org/viewtopic.php?id=62477
=end

=begin
po 14 maja
usunięcie punktów o wysokości z przetworzonej bazy danych punktów z LIDARa, utrudniającą normalne edytowanie, która w tej formie nie powinna być wrzucona

[out:xml][timeout:725][date:"2018-01-12T06:55:00Z"];
(
  node["OBJECTID_height_lidar"]["height"]["source:height"](if:count_tags() == 3);
);
(._;>;);
out meta;
=end


# name without name:pl (dla map które pokazują name:pl, potem name:en, potem name:de, potem name - a chcemy by w polsce dalej pokazywały pl)
# comparative advantage
# mass edit

# http://www.openstreetmap.org/changeset/55169697
# https://taginfo.openstreetmap.org/tags/construction=yes#combinations
# noname=no
# mass scale damaging automatic edit - see http://www.openstreetmap.org/user/Khalil%20Laleh/history#map=6/32.898/52.976
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

=begin
po 1 lipca
amenity=fuel breaking wikipedia tag rules and copyright
DWG pinged, search Turkey
https://www.openstreetmap.org/changeset/46304500#map=6/39.132/35.350
=end

=begin
po 1 lipca
# visible=false cleaner - https://www.openstreetmap.org/changeset/40133120#map=9/42.2244/25.2403&layers=N
=end

=begin
w 2019
http://overpass-turbo.eu/s/zt1
int_name=Bicycle parking
Name=St.miejskie
https://www.openstreetmap.org/changeset/22664118#map=19/51.11001/17.03171
=end


=begin
https://www.openstreetmap.org/changeset/57918111#map=17/33.09098/-117.20817


# see comments in http://www.openstreetmap.org/changeset/43401704

Lighthouses with missing name, but with seamark:name - http://overpass-turbo.eu/s/u05 (it is likely that name tag is missing)

See http://overpass-turbo.eu/s/u0C listing light_minor objects with seamark:light:range > 10.

Is there really a major navigational light here? I see nothing on aerial images.
'seamark:light:1:range'=* and man_made != lighthouse and 'seamark:type' = light_major
seamark:type!=light_minor and seamark:type!='beacon_special_purpose' and seamark:type!=platform and 'seamark:type'!=beacon_lateral
=end

# http://www.openstreetmap.org/changeset/31009200#map=15/43.8895/-0.5003 fix remaining - see http://overpass-turbo.eu/s/uoy


# https://wiki.openstreetmap.org/wiki/SPARQL_examples#Find_.22Featured.22_wiki_articles_with_location.2C_but_without_OSM_connection
# https://wiki.openstreetmap.org/wiki/User_talk:Yurik - wait for answers
# https://www.openstreetmap.org/changeset/49958115
#https://www.openstreetmap.org/changeset/49785062#map=8/46.881/18.215
#
#"historic=battlefield to tag niezgodny z zasadami OSM, ale używany i wygląda na tolerowany."
#To pora przestać go tolerować zanim więcej osób zacznie do OSM wsadzać wydarzenia (lepiej by wykasować to zanim sie zrobi popularne, mniej osób straci wtedy czasu na ich dodawanie)
# https://www.openstreetmap.org/changeset/51522177#map=13/54.0944/21.6133&layers=N
# wszystkie nawiasy http://overpass-turbo.eu/s/rpH
# watchlist for rare landuse, surface values in Kraków
# more https://github.com/osmlab/name-suggestion-index/blob/master/filter.json https://lists.openstreetmap.org/pipermail/talk/2015-May/072923.html
#should be highway=path http://overpass-turbo.eu/s/khG 
#bicycle_road=yes w Krakowie http://overpass-turbo.eu/s/pcO
#site=parking elimination
#(planowany) w osm, (w budowie) nie jest lepsze
#building=bridge w Krakowie - http://overpass-turbo.eu/s/dGR 
#type=site relation http://overpass-turbo.eu/s/fwU 
#name=Ogródki działkowe http://overpass-turbo.eu/s/dr3 
#planowan* - tagowanie pod render http://overpass-turbo.eu/s/dtf 
# http://www.openstreetmap.org/changeset/39896451#map=7/51.986/19.100

# https://www.openstreetmap.org/way/201259297#map=19/50.08838/19.75612 cudzysłowy w nazwach

#https://www.openstreetmap.org/way/33711547
#note=taśmociąg na filarach + highway=service
#to man_made=goods_conveyor

#TODO - private public toilets
# search "toilet tagging problem" mail (17 I)
=begin
12 I - bump
https://github.com/westnordost/StreetComplete/pull/744#issuecomment-354818367

During reviewing https://github.com/westnordost/StreetComplete/pull/744
potential data problems were noticed.

It seems to originate from HOT tagging.

As recommended on https://www.hotosm.org/contact-us I send email to
info@hotosm.org to notify about data issues originating from HOT
mapping.

From looking at
https://www.openstreetmap.org/node/3058828370#map=19/-16.51863/35.17363&layers=N
http://www.openstreetmap.org/way/485854738/history
http://www.openstreetmap.org/way/485841628/history
http://www.openstreetmap.org/way/486064588/history it seems that some
people, as part of HOT OSM editing

- map private toilets as public toilets (using amenity=toilets tag)
- frequently tag private toilets again as public (toilets:access =
  permissive)
- use unusual tags instead of established ones (toilets:access key
  instead of access)

Is this correct interpretation of the situation?

I recommend to 

- stop mapping private toilets (at least I would consider invasion of
  my privacy to map my private toilet)
- if for some reason mapping private toilets is considered as a good
  idea, please stop misusing amenity=toilets tag and create a separate
  one that would include private toilets
- please use toilets:access instead of access key for amenity=toilets
  objects
- please amend edits made as part of HOT editing to fix mentioned
  issues:

- delete private toilets mapped as part of HOT mapping from OSM
- change toilets:access to access on amenity=toilets object
- ensure that in future people will not make this kind of mistakes or
  that such problems will be noticed and fixed

I have limited experience with Africa so I may have some false
assumptions. If my observations/recommendation/whatever is for some
reason wrong/incorrect - please explain what is wrong.

-- Mateusz Konieczny
=end

# search „undiscussed automatic edit (blindly adding maxspeed tags)” mail

# https://ent8r.github.io/NotesReview/expert/?query=StreetComplete&limit=3000&start=true
# Polacy:
# CivilEng

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
#Eradicate is_in
#search for other is_in: tags on taginfo
#(punkt widokowy) w nazwie

=begin
https://www.openstreetmap.org/node/2703989478 - are there toilets here? then toilets=yes should be added https://wiki.openstreetmap.org/wiki/Key:toilets
toilets:wheelchair

disused:boundary https://taginfo.openstreetmap.org/keys/disused%3Aboundary
disused:political_division https://taginfo.openstreetmap.org/keys/disused%3Apolitical_division
other from https://taginfo.openstreetmap.org/keys/end_date#combinations

https://wiki.openstreetmap.org/wiki/Tag:amenity%3Dwater
amenity=water? What is this?

If it is place with drinking water amenity=drinking_water is typically used.

man_made=water_tap may be added if it is a water tap.

man_made=water_tap with drinking_water=no is typically used to indicate tap without drinking water



covered=no, shelter=yes - it seems contradictory
So it this bus stop with a shelter providing cover or not?

http://overpass-turbo.eu/s/wT2

after solving that: analyse tactile for covered=no
floor = x -> add also level = x
=end

=begin
  watchlist += detect_tags_in_region(lat, lon, 5, { 'payment:bitcoin' => {operation: :not_equal_to, value: 'no'} })
  watchlist += detect_tags_in_region(lat, lon, 5, { 'is_in:country' => :any_value })

  watchlist << { list: get_list({ 'seasonal' => '*'}, include_history_of_tags: true), message: "What seasonal=* is supposed to mean?"}
  watchlist << { list: get_list({ 'seasonal' => '*'}), message: ""}
=end



#building=damaged

=begin
building=building
building=constructie
building=Residence
=end

# https://www.openstreetmap.org/changeset/49785062#map=8/46.945/18.215

#błędne linki do parafii http://overpass-turbo.eu/s/rpy
#toilets:wheelchair=yes bez toilets

#(name=Żabka or name=żabka) and shop!=convenience (if generally true submit normalization to https://github.com/osmlab/name-suggestion-index/issues )
#detect violations of nixed values in https://github.com/osmlab/name-suggestion-index/issues, consider submitting them to JOSM validator
#tactile_paving=unknown
#numbers in names (place=village name=1)
#TODO: hunt down also other seamarks?

#TODO detect that it is crashing with OOM - currently it crashes silently
#may affect also other queries
#watchlist += detect_tags_in_region(lat, lon, 475, {'highway' => 'proposed', 'source' => {operation: :not_equal_to, value: :any_value}})
#maxspeed on nodes
# https://www.openstreetmap.org/changeset/21669560#map=6/54.230/28.011 - seems like import. copyright violation?
# http://www.openstreetmap.org/changeset/52386848#map=6/34.490/51.919 - destruction
# http://www.openstreetmap.org/changeset/25327911#map=10/34.8206/33.3531 tagging mess
# http://www.h-renrew.de/h/osm/osmchecks/02_Relationstypen/empty_relations.html - notify, delete

# https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_API_by_Example#Multipolygons_with_inappropiate_member_roles
# http://www.openstreetmap.org/changeset/21669560 - suspicious import
# smoothness dla mojego sett/cobblestone
#https://www.openstreetmap.org/changeset/53689019?node_page=85
#https://www.openstreetmap.org/changeset/53843529?node_page=3&xhr=1#map=12/17.8731/104.5758

# https://lists.openstreetmap.org/pipermail/tagging/2018-January/034644.html - make edits to wiki
# TODO: bardzo stare highway=construction
# https://forum.openstreetmap.org/viewtopic.php?pid=679376#p679376 - wiki zmodyfikowana, poczekać do 20 I
#https://taginfo.openstreetmap.org/tags/dataset=buildings#map
# https://forum.openstreetmap.org/viewtopic.php?pid=679671#p679671
#building=yes + shop=supermarket (70k cases - make app?)
# document Wikidata copyright status on WIkidata https://www.wikidata.org/w/index.php?title=Wikidata:Project_chat&diff=576668866&oldid=576665752
# https://stevebennett.me/2017/08/23/openstreetmap-vector-tiles-mixing-and-matching-engines-schemas-and-styles/
# fixme:action fixme:requires_aerial_image fixme:use_better_tagging_scheme bez fixme
# https://www.openstreetmap.org/way/158245125 area:size:ha _SITE_CODE_
# wiki.openstreetmap.org/wiki/Relations/Proposed/Site switch to multipolygons
# openstreetmap-carto todo +{"power_source"=>"wind", "power"=>"generator"} + wiatrak w Polsce
#add to JOSM validator and this one http://keepright.ipax.at/report_map.php?zoom=15&lat=50.08336&lon=19.8917&layers=B0T&ch=0%2C30%2C40%2C50%2C70%2C90%2C100%2C110%2C120%2C130%2C150%2C160%2C170%2C180%2C191%2C192%2C193%2C194%2C195%2C196%2C197%2C198%2C201%2C202%2C203%2C204%2C205%2C206%2C207%2C208%2C210%2C220%2C231%2C232%2C270%2C281%2C282%2C283%2C284%2C285%2C291%2C292%2C293%2C294%2C311%2C312%2C313%2C320%2C350%2C370%2C380%2C401%2C402%2C411%2C412%2C413%2C20%2C60%2C300%2C360%2C390&show_ign=0&show_tmpign=0
#add to JOSM validator and this one http://mapa.abakus.net.pl/raporty/
#add to JOSM validator and this one http://tools.geofabrik.de/osmi/?view=routing&lon=19.88591&lat=50.07833&zoom=16&opacity=0.69
#add to JOSM validator and this one https://wiki.openstreetmap.org/wiki/Quality_assurance
#use_sidepath adding http://overpass-turbo.eu/s/khD 
#stationary fixme fun http://overpass-turbo.eu/s/fyg 
# https://wiki.openstreetmap.org/wiki/Key:seamark:fixme exterminate
# bother users of unclear undocumented tags from https://github.com/simonpoole/beautified-JOSM-preset/issues/35
# automatic edit for amenity=shop later process other from https://github.com/simonpoole/beautified-JOSM-preset/issues/35
# https://wiki.openstreetmap.org/wiki/Tag:motorcycle_friendly%3Dcustomary
# https://wiki.openstreetmap.org/w/index.php?title=Talk:Good_practice&diff=1610412&oldid=1610363
# http://resultmaps.neis-one.org/newestosmfeed.php?lon=19.91674&lat=50.11020&deg=0.15  - nowi edytujący w Krakowie

require 'json'
require_relative 'watchlist_infrastructure'
require 'overhelper.rb'
require_relative 'require.rb'
require_relative 'deferred.rb'

include CartoCSSHelper

def my_location
  return 50.069, 19.926
end

def my_username
  return "Mateusz Konieczny"
end

def requested_watchlist_entries
  return 50
end

def time_in_hours_that_protects_query_from_redoing
  24
end

def time_in_hours_that_forces_note_redoing
  24
end

def default_cache_timeout_age_in_hours
  return 24 * 30
end

def age_of_historical_data_allowed_in_years
  return 10
end

class MatcherForStilPresentTagsAddedBySpecificUser
  def initialize(required_tags, author_id)
    @required_tags = required_tags
    @author_id = author_id
  end
  def is_matching(entry)
    if not_fully_matching_tag_set(entry["tags"], @required_tags)
      return false
    end
    json_history = get_json_history_representation(entry['type'], entry['id'])
    changesets_that_caused_object_to_match = changesets_that_caused_tag_to_appear_in_history(json_history, @required_tags)
    for changeset_id in changesets_that_caused_object_to_match
      if get_full_changeset_json(changeset_id)[:author_id] == @author_id
        puts "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']}"
        return true
      end
    end
    return false
  end
end

class MatcherForTagRemovalBySpecificUser
  def initialize(required_tags, author_id)
    @required_tags = required_tags
    @author_id = author_id
  end
  def is_matching(entry)
    json_history = get_json_history_representation(entry['type'], entry['id'])
    changesets_that_caused_object_to_match = changesets_that_caused_tag_to_disappear_in_history(json_history, @required_tags)
    for changeset_id in changesets_that_caused_object_to_match
      if get_full_changeset_json(changeset_id)[:author_id] == @author_id
        puts "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']} removed in https://www.openstreetmap.org/changeset/#{changeset_id}"
        return true
      end
    end
    return false
  end
end

def geozeisig_mechanical_edit()
  query_deleted_in_2018_up_to_29_may = '[date:"2018-01-01T04:55:00Z"]
[out:json][timeout:250];
(
  node["aerodrome"];
  way["aerodrome"];
  relation["aerodrome"];
);
out body;
out skel qt;'
  geozeisig_mechanical_edit_with_assumed_data(query_deleted_in_2018_up_to_29_may)

  query_check_promoted_tag = "[out:json][timeout:250];
(
  node['aerodrome:type'];
  way['aerodrome:type'];
  relation['aerodrome:type'];
);
out body;
out skel qt;"
  geozeisig_mechanical_edit_with_assumed_data(query_check_promoted_tag)
end

def verify_useless_fixme()
  query_postcode_fixme_nodes = "[out:json][timeout:250];
(
  node['fixme'='Popraw kod pocztowy'];
);
out body;
out skel qt;"
  geozeisig_mechanical_edit_with_assumed_data(query_postcode_fixme_nodes)
end

def geozeisig_mechanical_edit_with_assumed_data(query_for_data_seeding)
  author_id = '66391'
  nick = get_full_user_data(author_id)[:current_username]
  puts "analysis of changes by #{nick}"
  required_tags = {'aerodrome' => :any_value}

  json_string = get_data_from_overpass(query_for_data_seeding, "#{nick} cleanup")
  affected_elements = list_affected_objects(MatcherForTagRemovalBySpecificUser.new(required_tags, author_id), json_string)
  puts affected_elements
  puts affected_elements.length
end


def list_affected_objects(matcher, osm_data_for_filtering_as_json_string)
  obj = JSON.parse(osm_data_for_filtering_as_json_string)
  elements = obj["elements"]
  matched = []
  elements.each do |entry|
    if matcher.is_matching(entry)
      matched_object_url = "https://www.openstreetmap.org/#{entry['type']}/#{entry['id']}"
      matched << matched_object_url
    end
  end
  return matched
end

def watchlist_entries
  watchlist = []
  watchlist += watch_is_in if count_entries(watchlist) < requested_watchlist_entries
  watchlist += watch_other if count_entries(watchlist) < requested_watchlist_entries
  watchlist += watch_invalid_wikipedia if count_entries(watchlist) < requested_watchlist_entries
  if local_notes_present
    puts "remember about processing local notes!"
  end
  #watchlist += watch_valid_tags_unexpected_in_krakow if count_entries(watchlist) < requested_watchlist_entries
  # adapt TODO list JOSM plugin to autoremove descriptive names
  #watchlist += watch_descriptive_names(requested_watchlist_entries - count_entries(watchlist))
  #watchlist += watch_tree_species_in_name if count_entries(watchlist) < requested_watchlist_entries
  #watchlist += watch_spam if count_entries(watchlist) < requested_watchlist_entries #TODO - reeenable it, it was causing overpass issues
  watchlist += watch_lifecycle if count_entries(watchlist) < requested_watchlist_entries
  #watchlist += watch_lifecycle_state_in_the_name if count_entries(watchlist) < requested_watchlist_entries
  watchlist += watch_low_priority if count_entries(watchlist) < requested_watchlist_entries
  watchlist += watch_useless_keys if count_entries(watchlist) < requested_watchlist_entries
  watchlist += watch_declared_historical_data if count_entries(watchlist) < requested_watchlist_entries #rely on dev overpass servers
  watchlist += proposed_without_source if count_entries(watchlist) < requested_watchlist_entries #rely on dev overpass servers
  watchlist += watch_generating_notes(requested_watchlist_entries) if count_entries(watchlist) < requested_watchlist_entries
  return watchlist
end

def blacklist_english_phrases
  #TODO - for more see shop=car with descriptions or any long descriptions (so long that got cut-off need fixing anyway)
  return ['Fortune 500', 'Our clients', 'I am confident', 'Family-owned',
    'experienced professionals', 'best quality', 'reach us', 'we come', ' boasts ', 'outstanding',
    'our team', 'we are', 'call us', 'we have', 'we offer', ' our ',
    'our products', ' loans ',
    'competitive price', 'We provide', 'will match any', '™', '®', '℗', '℠']
end

def blacklist_polish_phrases
  return ['naprawdę warto']
end

def watch_spam
  watchlist = []

  blacklist_with_false_positives = [
    'price', # appears also in reasonable, nonspammy descriptions
    'reasonable prices', # appears also in reasonable, nonspammy descriptions
    'luxury',  # appears also in reasonable descriptions - mostly negated
    'tradition ', # appears also in reasonable, nonspammy descriptions
    ' we ', #we - dwór we Franciszkowie
    ]
  blacklists = [blacklist_english_phrases, blacklist_polish_phrases, blacklist_with_false_positives]

  blacklists.each do |spam_indicators_phrases|
    watchlist += objects_using_this_tag_part('description', spam_indicators_phrases, 'spam detection query based on description tag - for level0: http://overpass-turbo.eu/s/z9P')
    watchlist += objects_using_this_tag_part('name', spam_indicators_phrases, 'spam detection query based on description tag - for level0: http://overpass-turbo.eu/s/z9P')
  end
  return watchlist
end

def local_notes_present
  lat, lon = my_location
  range = 0.025
  cache_timestamp = CartoCSSHelper::NotesDownloader.cache_timestamp(lat, lon, range)
  if cache_timestamp == nil or cache_timestamp + 24 * 60 * 60 < DateTime.now.to_time.to_i
    CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range, invalidate_cache: true)
  end
  return CartoCSSHelper::NotesDownloader.run_note_query(lat, lon, range) != empty_note_xml
end


def run_watchlist
  puts "there are nearby notes" if local_notes_present
  #dump_descriptive_names_entries_to_stdout()
  
  entries = watchlist_entries

  puts
  puts
  puts "[out:xml][timeout:725];"
  puts "("

  displayed = 0
  entries.each do |entry|
    if entry[:list].length == 0
      next
    end
    puts "// #{entry[:message]}"
    puts "// #{entry[:list][0][:total_size]} elements in total"
    entry[:list].each do |object|
      if object[:lat].nil? || object[:lon].nil?
        raise "#{entry[:message]} has broken data"
      end
      puts object[:type]+'('+object[:id].to_s+')' + ';'
      puts "// #{object[:url]}"
      puts "// #{object[:history_string]}" if object[:history_string] != nil
      displayed += 1
      if displayed >= requested_watchlist_entries
        break
      end
    end
    puts "// #{entry[:message]}"
    puts "// #{entry[:list][0][:total_size]} elements in total"
    puts
    if displayed >= requested_watchlist_entries
      break
    end
  end
  puts ");"
  puts "(._;>;);"
  puts "out meta;"

  #geozeisig_mechanical_edit
  verify_useless_fixme
end

def watch_beton
  watchlist = []
  beton_variations = ["Beton", "beton"]

  beton_variations.each do |value|
    tags = { 'surface' => value }
    beton_problem = "surface=#{value}? 'beton' is word for concrete in some languages but not in the English"
    overpass_code = 'gT2'
    message = beton_problem + "\n\n" + "See http://overpass-turbo.eu/s/#{overpass_code} for more problems of this type"
    watchlist << { list: get_list(tags, include_history_of_tags: true), message: message }
  end

  return watchlist
end

def is_discussion_empty_at(changeset_id)
  changeset_data = get_full_changeset_json(changeset_id, invalidate_cache: false)
  if changeset_data[:discussion] != []
    return false
  end
  changeset_data = get_full_changeset_json(changeset_id, invalidate_cache: true)
  if changeset_data[:discussion] != []
    return false
  end
  return true
end

def is_there_active_discussion_at(changeset_id)
  changeset_data = get_full_changeset_json(changeset_id, invalidate_cache: false)
  latest_timestamp = changeset_data[:discussion][0][:timestamp]
  changeset_data[:discussion].each do |comment|
    if latest_timestamp < comment[:timestamp]
      latest_timestamp = comment[:timestamp]
    end
  end
  latest_activity_age_in_seconds = Time.now.to_i - latest_timestamp
  latest_activity_age_in_months = latest_activity_age_in_seconds / 60 / 60 / 30
  return latest_activity_age_in_months <= 1
end

def are_there_comment_not_mine_at(changeset_id)
  changeset_data = get_full_changeset_json(changeset_id, invalidate_cache: false)
  changeset_data[:discussion].each do |comment|
    return true if comment[:user] != my_username
  end
  return false
end

def process_automatic_watchlist_object(object, message, already_notified)
  # makes action, return modified already_notified object
  if object[:lat].nil? || object[:lon].nil?
    raise "#{message} has broken data"
  end
  puts object[:type]+'('+object[:id].to_s+')' + ';'
  puts "// #{object[:url]}"
  puts "// #{object[:history_string]}" if object[:history_string] != nil
  if object[:history].length != 1
    puts "// manual mode enabled due to recurring change"
    return already_notified
  end
  changeset_id = object[:history][0]
  author = get_full_changeset_json(changeset_id)[:author_id]
  if already_notified[:authors].include?(author)
    puts "// skipped to avoid multiple notifications of the same person"
    return already_notified
  end
  if is_discussion_empty_at(changeset_id)
    puts "// empty discussion, comment in https://www.openstreetmap.org/changeset/#{changeset_id} by #{author}"
    days = (Time.now.to_i - get_full_changeset_json(changeset_id)[:timestamp]) / 3600 / 24
    comment = ""
    comment = "Sorry for bothering you about an old change, but " if days > 400
    comment = "Sorry for bothering you about a very old change, but " if days > 1400
    comment = "Sorry for bothering you about an ancient change, but " if days > 2400
    comment += "I have a question about #{object[:url]} - #{message}"
    puts comment
    already_notified[:authors] << author
    return already_notified
  elsif is_there_active_discussion_at(changeset_id)
    puts "// active discussion - skip (probably should be skipped by filtering stage)"
    return already_notified
  elsif are_there_comment_not_mine_at(changeset_id)
    puts "// discussion is not active but users other than me commented - switch to manual"
    return already_notified
  else
    puts "// changeset is not empty, not with comments by other and with old inactive discussion - create a note (after checking that it does not exists with flushed cache)"
    return already_notified
  end
end

def process_automatic_watchlist_entries(watchlist)
  # for new edits check changeset discussion:
  # if more than 1 changeset introduced changes - switch to manual
  # if empty comment - check again with flushing cache and if empty again comment in changeset
  # if nonempty and with recent comments wait
  # if nonempty and only with my old comment create note
  # if nonempty and only with my old comments and some are not mine - request manual handling
  already_notified = {authors: [], locations: []}
  watchlist.each do |entry|
    if entry[:list].length == 0
      next
    end
    puts entry[:message]
    entry[:list].each do |object|
      already_notified = process_automatic_watchlist_object(object, entry[:message], already_notified)
      return if already_notified[:authors].length >= 3
    end
  end
end

def watch_automatic_entries
  watchlist = []
  watchlist = watchlist + watch_beton
  not_present = {operation: :not_equal_to, value: :any_value}
  tags = { 'access' => 'private', 'amenity' => 'toilets', 'note' => not_present, 'fixme' => not_present }
  #watchlist << { list: get_list(tags), message: 'amenity=toilets is supposed to be used only for public toilets, amenity=toilets with access=private makes no sense. Is it place with a public toilets or not? If it is a public toilet but withh access limited to workers/students/clients - then likely access=customers is a better description' }
  #TODO reconsider

  message = 'Why this is not tagged as highway=steps? What is the meaning of steps=yes here? See http://overpass-turbo.eu/s/tPd for more cases (I considered armchair mapping it to highway=steps but I think that verification from local mappers is preferable)'
  modifiers = ['footway', 'path']
  for modifier in modifiers
    watchlist << { list: get_list({'steps' => 'yes', 'highway' => modifier, 'area' => {operation: :not_equal_to, value: "yes"}}, include_history_of_tags: true), message: message, overpass: 'http://overpass-turbo.eu/s/tPd' }
  end

  process_automatic_watchlist_entries(watchlist)
end

def watch_lifecycle
  watchlist = []
  #after fixing revisit https://github.com/openstreetmap/iD/issues/4501
  message = "is this object gone or not? If gone, it should be deleted (if still present at least on some aerial images it should be tagged in a better way - for example object with note='demolished on 2017-10' ), if not demolished then it is wrong to tag it as "
  watchlist << { list: get_list({ 'demolished' => 'yes' }), message: message + "demolished=yes"}
  watchlist << { list: get_list({ 'destroyed' => 'yes' }), message: message + "destroyed=yes"}
  watchlist << { list: get_list({ 'dismantled' => 'yes' }), message: message + "dismantled=yes"}
  watchlist << { list: get_list({ 'razed' => 'yes' }), message: message + "razed=yes"}
  watchlist << { list: get_list({ 'obliterated' => 'yes' }), message: message + "obliterated=yes"}
  #more at https://taginfo.openstreetmap.org/search?q=demolished%3Dyes

  # - building=collapsed? Is this building really gone? In that case it should be deleted or rategged to demolished:building=yes.
  # Note that building tag describes purpose of the building - see https://wiki.openstreetmap.org/wiki/Key:building and remains of buildings must not be mapped as buildings
  # http://overpass-turbo.eu/s/zrE
  watchlist << { list: get_list({ 'building' => 'collapsed' }), message: message + "building=collapsed"}
  return watchlist
end


def watch_railway_lifecycle
  watchlist = []
  watchlist << { list: get_list({ 'railway' => 'razed', 'highway' => {operation: :not_equal_to, value: :any_value}}), message: message + "railway=razed"}
  watchlist << { list: get_list({ 'railway' => 'historic' }), message: message + "railway=historic"}
  watchlist << { list: get_list({ 'railway' => 'dismantled' }), message: message + "railway=dismantled"}
  watchlist << { list: get_list({ 'railway' => 'obliterated' }), message: message + "railway=obliterated"}
  watchlist << { list: get_list({ 'razed' => 'yes', 'railway' => 'disused' }), message: "is it only disused and railway tracks remain or is it completely razed?"}
  watchlist << { list: get_list({ 'razed' => 'yes', 'railway' => {operation: :not_equal_to, value: "disused"} }), message: message + "razed=yes"}
  return watchlist
end

def watch_wetland_tag
  watchlist = []
  message = "Is it a wetland or a water? If it is not wetland then wetland tag should be deleted, if it is a wetland than natural=wetland rather than natural=water should be used"
  watchlist << { list: get_list({'wetland' => :any_value,  'natural' => 'water'}), message: message, include_history_of_tags: true}
  watchlist << { list: get_list({ 'seasonal' => '*'}), message: "What seasonal=* is supposed to mean?", include_history_of_tags: true}

  watchlist << { list: get_list([
    ['wetland', :any_value],
    ['natural', {operation: :not_equal_to, value: 'wetland'}],
    ['natural', {operation: :not_equal_to, value: 'coastline'}]
    ]), message: "missing natural=wetland"}
  return watchlist
end

def watch_useless_keys
  watchlist = []
  useless_keys = ['hashtag', 'ERROR_FLAG', 'BMP', 'SYMBOL', 'TRAIL_STAT', 'ADMIN_ORG']
  useless_keys.each do |key|
    watchlist << { list: get_list({key => :any_value}), message: "#{key} key?" }
  end

  message = 'delete from tags data that is included in geometry'
  useless_keys = ['Lgth_Miles', 'Lgth_Mtrs']
  useless_keys.each do |key|
    watchlist << { list: get_list({key => :any_value}), message: "#{key} key? - #{message}" }
  end

  message = "what is the meaning of acres tag? If it is about area taken by object - note that marking something as closed way is enough to provide information about an area"
  watchlist << { list: get_list({'acres' => :any_value}), message: message, include_history_of_tags: true }
  return watchlist
end

def watch_steps_on_unusual_highway
  watchlist = []
  watchlist << { list: get_list([
    ['steps', 'yes'],
    ['highway', :any_value],
    ['highway', {operation: :not_equal_to, value: "steps"}],
    ['highway', {operation: :not_equal_to, value: "path"}],
    ['highway', {operation: :not_equal_to, value: "track"}],
    ['highway', {operation: :not_equal_to, value: "footway"}],
    ['area', {operation: :not_equal_to, value: "yes"}],
    ], include_history_of_tags: true), message: 'steps=yes on unusual highway=* What is the meaning of steps=yes here? ', overpass: 'http://overpass-turbo.eu/s/tPd'}
  message = 'steps=yes on highway=track What is the meaning of steps=yes here? Is it possible that it is not really road but path/footway? Maybe highway=steps should be used here?'
  watchlist << { list: get_list({'steps' => 'yes', 'highway' => 'track', 'area' => {operation: :not_equal_to, value: "yes"}}, include_history_of_tags: true), message: message, overpass: 'http://overpass-turbo.eu/s/tPd' }
  return watchlist
end

def watch_generating_notes(requested_watchlist_entries)
  watchlist = []
  watchlist += watch_wetland_tag if count_entries(watchlist) < requested_watchlist_entries
  watchlist += watch_imports_failing_to_use_name if count_entries(watchlist) < requested_watchlist_entries
  watchlist << { list: get_list({ 'waterway' => 'canal', 'area' => 'yes'}), message: "waterway=canal with area=yes"}
  watchlist += watch_steps_on_unusual_highway
  watchlist << { list: get_list({ 'seasonal' => '*'}, include_history_of_tags: true), message: "What seasonal=* is supposed to mean?"}
  watchlist += watch_unusual_seasonal_for_waterway

  message = 'is it really both landuse=industrial and leisure=park? leisure=park is for https://en.wikipedia.org/wiki/Park, not for industrial park https://en.wikipedia.org/wiki/Industrial_park'
  watchlist << { list: get_list({'leisure' => 'park', 'landuse' => 'industrial'}), message: message }

  watchlist += watch_railway_lifecycle if count_entries(watchlist) < requested_watchlist_entries

  return watchlist
end

def watch_other
  watchlist = []

  message = 'access=private on what is supposed to be mapped only if public (mapping phones not accessible to public may sometimes make sense but one should use a different tag)...'
  #watchlist << { list: get_list({ 'access' => 'private', 'amenity' => 'telephone' }), message: message } #what about military bases?
  watchlist << { list: get_list({ 'concentration_camp' => 'nazism', 'amenity' => 'prison'}, include_history_of_tags: true), message: "Suspected tagging for renderer"}

  return watchlist
end

def whitelist_tag_filter(key, valid_values)
  tags = [[key , :any_value]]
  for valid in valid_values
    tags << [key, {operation: :not_equal_to, value: valid}] 
  end
  return tags
end

def watch_unusual_seasonal_for_waterway
  #see https://github.com/gravitystorm/openstreetmap-carto/pull/2982
  # seasonal=* is detected by a separate rule
  tags = whitelist_tag_filter('seasonal', ['yes', 'no', 'wet_season', 'dry_season', 'winter', 'summer', 'spring', 'autumn', '*'])
  tags << ['waterway', :any_value]
  return [{ list: get_list(tags), message: 'unexpected seasonal tag on a waterway' }]
end

def watch_unusual_seasonal_not_for_waterway
  #all months: January;February;March;April;May;June;July;August;September;October;November;December
  #OSM uses British English, thus autumn not fall.
  # seasonal=* is detected by a separate rule
  tags = whitelist_tag_filter('seasonal', ['yes', 'no', 'wet_season',
    'dry_season', 'winter', 'summer', 'spring', 'autumn', '*',
    'spring;summer;autumn', 'spring;winter;autumn', 'summer;autumn', 'spring;summer',
    'christmas', 'March to September', 'May-Oct',
    'dry weather only', 'No winter maintenance', 'dry_weather', 'no_snow',
    'low water', 'low flow',
    # bizzare, I am not going to fix them:
    '224: spring-autumn'])
  # waits for osm wiki edit
  # spring;winter;autumn - for ice rink
  # summer;autumn - for roads
  # dry weather only
  tags << ['waterway', {operation: :not_equal_to, value: :any_value}]
  return [{ list: get_list(tags), message: 'unexpected seasonal tag (not on a waterway)' }]
end

def watch_low_priority
  watchlist = []
  watchlist << { list: get_list({ 'name' => '.' }), message: 'name=.' }

  watchlist += watch_unusual_seasonal_not_for_waterway

  watchlist << { list: get_list({ 'demolished:building' => 'yes', 'note' => {operation: :not_equal_to, value: :any_value} }), message: 'still visible in some aerial images, avoid deleting for now to avoid people tagging no longer existing objects' }

  # waits for responses
  watchlist << { list: get_list({ 'access' => 'private', 'amenity' => 'toilets', 'note' => :any_value }), message: 'amenity=toilets access=private, note=*' }
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
    {key: 'name', value: name.downcase},
    {key: 'name', value: name.upcase},
    {key: 'name', value: name.capitalize},
    {key: 'name:'+language_code_of_name, value: name},
    {key: 'name:'+language_code_of_name, value: name.downcase},
    {key: 'name:'+language_code_of_name, value: name.upcase},
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
        'place' => {operation: :not_equal_to, value: :any_value},
        'amenity' => {operation: :not_equal_to, value: "restaurant"},
        'natural' => {operation: :not_equal_to, value: "peak"}
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

def objects_using_this_tag_part(tag, partial_match_wanted_list, description, notes_block_report=true)
  return [{ list: list_of_objects_with_this_tag_part(tag, partial_match_wanted_list), message: description, notes_block_report: true }]
end

def watch_descriptive_names(requested_entries)
  #https://wiki.openstreetmap.org/wiki/Naming_conventions#Don.27t_describe_things_using_name_tag
  #see also https://github.com/osmlab/name-suggestion-index - names should end here to discourage iD users from using them
  #user facing complaint: 
  # Czy tag name nie jest tu przypadkiem błędnie użyty jako opis obiektu? leisure=playground wystarcza by oznaczyć to jako plac zabaw.
  # Is it really parking named parking or is it just a parking and name tag is incorrectly used as a description?

  watchlist = []
  watchlist += objects_using_this_tag_part('name', ['boisko do gry w'], 'name used instead sport tags')
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
    #{name: 'parking', language: 'pl', matching_tags: [{'amenity' => 'parking'}]},
    #{name: 'parking', language: 'en', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'parking lot', language: 'en', matching_tags: [{'amenity' => 'parking'}]},
    {name: 'Car park', language: 'en', matching_tags: [{'amenity' => 'parking'}]},
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
    #{name: 'apteka', language: 'pl', overpass: 'http://overpass-turbo.eu/s/qZa'}, #default style has poor icon
    {name: 'restaurant', language: 'en', matching_tags: [{'amenity' => 'restaurant'}]},
    {name: 'las', language: 'pl', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},
    {name: 'forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}], overpass: 'http://overpass-turbo.eu/s/rpK'},
    {name: 'kiosk', language: 'pl', matching_tags: [{'shop' => 'kiosk'}], overpass: 'http://overpass-turbo.eu/s/qYg'},
    {name: 'sklep', language: 'pl', matching_tags: [{'shop' => :any_value}]},

    # proposed in PR for https://github.com/osmlab/name-suggestion-index

    # not in https://github.com/osmlab/name-suggestion-index
    {name: 'staw', language: 'pl', matching_tags: [{'natural' => 'water'}]},
    {name: 'pond', language: 'en', matching_tags: [{'natural' => 'water'}]},

    {name: 'Camp Greenery(Trees)', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]}, #yes, without space
    {name: 'trash can', language: 'en', matching_tags: [{'amenity' => 'waste_basket'}]},
    {name: 'bench', language: 'en', matching_tags: [{'amenity' => 'bench'}]},
    {name: 'bike rack', language: 'en', matching_tags: [{'amenity' => 'bicycle_parking'}]},
    {name: 'paddy field', language: 'en'},
    {name: 'Boat Ramp', language: 'en', matching_tags: [{'leisure' => 'slipway'}]},
    {name: 'rondo', language: 'pl'},
    {name: 'strzelnica', language: 'pl'},
    {name: 'water tap', language: 'en', complaint: "water tap - to copy: <\n  man_made = water_tap\n  description = Water tap\n> overpass query helper: http://overpass-turbo.eu/s/qZe", matching_tags: [{'man_made' => 'water_tap'}]},
    {name: 'park', language: 'en', matching_tags: [{'leisure' => 'park'}], overpass: 'http://overpass-turbo.eu/s/qZb'},
    {name: 'park', language: 'pl', matching_tags: [{'leisure' => 'park'}], overpass: 'http://overpass-turbo.eu/s/qZb'},
    {name: 'restauracja', language: 'pl', matching_tags: [{'amenity' => 'restaurant'}]},
    {name: 'lighthouse', language: 'en'},
    {name: 'scrub', language: 'en', matching_tags: [{'natural' => 'scrub'}]},
    {name: 'kamieniołom', language: 'pl', matching_tags: [{'landuse' => 'quarry'}]},
    {name: 'krzyż', language: 'pl', matching_tags: [{'historic' => 'wayside_cross'}, {'man_made' => 'cross'}]},
    {name: 'quarry', language: 'en'},
    {name: 'beach', language: 'en', matching_tags: [{'natural' => 'beach'}]},
    {name: 'plaża', language: 'pl', matching_tags: [{'natural' => 'beach'}]},
    {name: 'strand', language: 'de', matching_tags: [{'natural' => 'beach'}]},
    {name: 'water', language: 'en', matching_tags: [{'amenity' => 'drinking_water'}]},
    {name: 'viewpoint', language: 'en', matching_tags: [{'tourism' => 'viewpoint'}]},
    {name: 'cricket pitch', language: 'en', matching_tags: [{'leisure' => 'pitch', 'sport' => 'cricket'}]},
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
    {name: 'droga poboczna', language: 'pl'},
    {name: 'ścieżka', language: 'pl'},
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
    {name: 'gazebo', language: 'en', matching_tags: [{'amenity' => 'shelter'}]},
    {name: 'altana', language: 'pl', matching_tags: [{'amenity' => 'shelter'}]},
    {name: 'altanka', language: 'pl', matching_tags: [{'amenity' => 'shelter'}]},
    {name: 'picnic shelter', language: 'en', matching_tags: [{'amenity' => 'shelter'}], complaint: "shelter_type=picnic_shelter may be added"},
    {name: 'Picnic shelter', language: 'en', matching_tags: [{'amenity' => 'shelter'}], complaint: "shelter_type=picnic_shelter may be added"},
    {name: 'picnic table', language: 'en', matching_tags: [{'leisure' => 'picnic_table'}]},
    {name: 'steps', language: 'en', matching_tags: [{'highway' => 'steps'}]},
    {name: 'light', language: 'en', matching_tags: [{'highway' => 'street_lamp'}]},
    {name: 'pool', language: 'en', matching_tags: [{'leisure' => 'swimming_pool'}]},
    {name: 'swimming pool', language: 'en', matching_tags: [{'leisure' => 'swimming_pool'}]},
    {name: 'toilets', language: 'en', matching_tags: [{'amenity' => 'toilets'}]},
    {name: 'toalety', language: 'pl', matching_tags: [{'amenity' => 'toilets'}]},
    {name: 'theatre', language: 'en', matching_tags: [{'amenity' => 'theatre'}]},
    {name: 'rock formation', language: 'en', matching_tags: [{'natural' => 'bare_rock'}]},

    {name: 'big forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},
    {name: 'small forest', language: 'en', matching_tags: [{'natural' => 'wood'}, {'landuse' => 'forest'}]},

    {name: 'Zbiornik ppoż.', language: 'pl', matching_tags: [{'landuse' => 'reservoir'}]},
  ]
end

def watch_tree_species_in_name
  watchlist = []
  watchlist << { list: get_list({ 'name' => 'jarząb pospolity (jarząb zwyczajny)', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'jarząb pospolity', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'jarząb zwyczajny', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'tree', 'natural' => 'tree' }), message: "name=tree ( http://overpass-turbo.eu/s/qAX dla level0)" }
  watchlist << { list: get_list({ 'name' => 'drzewo', 'natural' => 'tree' }), message: "name=drzewo ( http://overpass-turbo.eu/s/qZq )" }
  watchlist << { list: get_list({ 'name' => 'Platan klonolistny', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'choinka', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'brzoza', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'dąb', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'dąb szypułkowy', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'Dąb szypułkowy', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'sosna', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'klon', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'buk', 'natural' => 'tree' }), message: "opis drzewa w nazwie" }
  watchlist << { list: get_list({ 'name' => 'pomnik przyrody', 'natural' => 'tree' }), message: "opis drzewa w nazwie, use denotation=natural_monument" }
  return watchlist
end

def watch_valid_tags_unexpected_in_krakow
  watchlist = []
  lat, lon = my_location

  watchlist += detect_tags_in_region(lat, lon, 8, { 'surface' => 'sett', 'smoothness' => {operation: :not_equal_to, value: :any_value} })
  watchlist += detect_tags_in_region(lat, lon, 8, { 'surface' => 'cobblestone', 'smoothness' => {operation: :not_equal_to, value: :any_value} })

  watchlist += detect_tags_in_region(lat, lon, 50, { 'amenity' => 'shop' })

  watchlist += detect_tags_in_region(lat, lon, 25, { 'landuse' => 'basin', 'natural' => {operation: :not_equal_to, value: 'water'}, 'fixme' => {operation: :not_equal_to, value: :any_value} }, message: "natural=water may be missing")


  watchlist += detect_tags_in_region(lat, lon, 15, { 'man_made' => 'pier', 'highway' => {operation: :not_equal_to, value: :any_value} })
  
  watchlist += detect_tags_in_region(lat, lon, 2500, { 'highway' => :any_value, "addr:housenumber" => :any_value, 'website' => :any_value })


  watchlist += detect_tags_in_region(lat, lon, 5, { 'fixme' => :any_value }, 'fixmes')

  watchlist = watchlist + watch_for_tags_not_present_in_krakow(lat, lon)
  watchlist = watchlist + watch_for_disliked_tags(lat, lon)
  watchlist = watchlist + watch_for_useless_unknown(lat, lon)
  watchlist = watchlist + watch_trolltags_in_krakow(lat, lon)
  watchlist = watchlist + watch_oneway_in_krakow(lat, lon)
  watchlist = watchlist + watch_track_misuse_in_krakow(lat, lon)
  watchlist = watchlist + watch_is_in_in_krakow(lat, lon)
  return watchlist
end

def watch_for_tags_not_present_in_krakow(lat, lon)
  watchlist = []
  #TODO: exclude volcano:status   extinct
  #range_in_km = 300
  #watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  #range_in_km = 400
  #watchlist << { list: get_list({ 'natural' => 'volcano' }, 50, 20, range_in_km), message: "(#{range_in_km}km range) Is it really a good idea to tag something as natural=volcano where it was last active about X 000 years ago? In that case natural=peak is probably better..." }
  watchlist += detect_tags_in_region(lat, lon, 5, whitelist_tag_filter('cycleway', ['no', 'lane', 'opposite_lane', 'opposite']))
  watchlist += detect_tags_in_region(lat, lon, 25, { 'shop' => :any_value, 'wikipedia' => :any_value }) #extend to banks etc?
  watchlist += detect_tags_in_region(lat, lon, 80, { 'horse' => 'designated' }, "to naprawdę jest specjalnie przeznaczone dla koni?") #130 - too far
  watchlist += detect_tags_in_region(lat, lon, 30, { 'highway' => 'bridleway' }, "Czy naprawdę tu w Krakowie jest urwany kawałek szlaku dla koni?")
  watchlist += detect_tags_in_region(lat, lon, 3500, { 'highway' => 'bus_guideway' }, "#highway=bus_guideway Czy tu naprawdę jest coś takiego jak opisane na http://wiki.openstreetmap.org/wiki/Tag:highway=bus%20guideway?uselang=pl ? Czy po prostu zwykła droga po której tylko autobusy mogą jeździć?")
  return watchlist
end

def watch_for_disliked_tags(lat, lon)
  watchlist = []

  # historic boundaries
  #1 295
  #1 280 (w tym 634 way)
  #1 274 (w tym 630 way) in 2017 IX
  #1 231 (w tym 612 way) w 2017 XII
  #1 096 (w tym 538 way) w 2018 IV
  watchlist += detect_tags_in_region(lat, lon, 1500, { 'boundary' => 'historic', 'end_date' => {operation: :not_equal_to, value: :any_value} })
  #end_date - catch entries deep in past and in the far future

  watchlist += detect_tags_in_region(lat, lon, 100, { 'building' => 'no' })
  watchlist += detect_tags_in_region(lat, lon, 15, [['payment:bitcoin', :any_value], ['payment:bitcoin', {operation: :not_equal_to, value: 'no'}]])
  watchlist += detect_tags_in_region(lat, lon, 5, { 'access' => 'public' })
  watchlist += detect_tags_in_region(lat, lon, 20, { 'bicycle' => 'official' })
  watchlist += detect_tags_in_region(lat, lon, 25, { 'seamark:name' => :any_value })
  watchlist += detect_tags_in_region(lat, lon, 100, { 'historic' => 'battlefield' }, 'Czy są tu jakieś pozostałości po bitwie? Jeśli tak to powiny zostać zmapowane, jeśli nie to jest to do skasowania.') #1 653 in 2017 IX #200 - too far (reaches Slovakia)
  return watchlist
end

def watch_for_useless_unknown(lat, lon)
  watchlist = []
  watchlist += detect_tags_in_region(lat, lon, 1500, { 'capacity:disabled' => 'unknown' })
  watchlist += detect_tags_in_region(lat, lon, 1500, { 'capacity:parent' => 'unknown' })
  watchlist += detect_tags_in_region(lat, lon, 1500, { 'capacity:woman' => 'unknown' })
  return watchlist
end

def watch_trolltags_in_krakow(lat, lon)
  watchlist = []
  #after fixing revisit https://github.com/openstreetmap/iD/issues/4501
  not_trolltag_filters = [
    ['man_made', {operation: :not_equal_to, value: 'mineshaft'}],
    ['building', {operation: :not_equal_to, value: :any_value}],
    ['landuse', {operation: :not_equal_to, value: 'quarry'}],
  ]
  watchlist += detect_tags_in_region(lat, lon, 50, [['disused', 'yes']] + not_trolltag_filters)
  watchlist += detect_tags_in_region(lat, lon, 50, [['abandoned', 'yes']] + not_trolltag_filters)

  watchlist += detect_tags_in_region(lat, lon, 5, { 'building' => 'proposed' })
  watchlist += detect_tags_in_region(lat, lon, 5, { 'building' => 'destroyed' })
  return watchlist
end

def watch_oneway_in_krakow(lat, lon)
  watchlist = []
  valid_oneway_values = ['yes', 'no']
  filter = [['oneway', :any_value]]
  for valid in valid_oneway_values
    filter << ['oneway', {operation: :not_equal_to, value: valid}]
  end
  watchlist += detect_tags_in_region(lat, lon, 20, filter)
  return watchlist
end

def watch_track_misuse_in_krakow(lat, lon)
  watchlist = []
  message = 'highway=track to droga do obsługi pola/lasu, stan drogi oznacza się przy pomocy tagów smoothness i surface'
  proper_track_names = ['Chodnik Malczewskiego', 'Astronomów', 'Tuchowska',
    'Piotra Gaszowca', 'Słona Woda', 'Do Luboni', 'Stefana Starzyńskiego',
    'Świętego Floriana', 'Słoneczna', 'Wrzosowa', 'Spacerowa', 'Topolowa',
    'Czerwony Most']
  tags = [['highway', 'track'], ['name', :any_value]]
  proper_track_names.each do |name|
    tags << ['name', {operation: :not_equal_to, value: name}]
  end
  watchlist += detect_tags_in_region(lat, lon, 7, tags, message)
  # TODO - consider detecting rather highway=track without nearby field/forest, it will find also nameless ones
  return watchlist
end

def watch_is_in_in_krakow(lat, lon)
  watchlist = []
  watchlist += detect_tags_in_region(lat, lon, 15, { 'is_in:country' => :any_value })
  watchlist += detect_tags_in_region(lat, lon, 15, { 'is_in:county' => :any_value })
  watchlist += detect_tags_in_region(lat, lon, 15, { 'is_in:municipality' => :any_value })
  watchlist += detect_tags_in_region(lat, lon, 15, { 'is_in:province' => :any_value })
  watchlist += detect_tags_in_region(lat, lon, 15, { 'is_in' => :any_value })
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
  query = '[out:json][timeout:250];
  (
    node["name"~"planowan"];
    way["name"~"planowan"];
    relation["name"~"planowan"];

    node["name"~"planned"];
    way["name"~"planned"];
    relation["name"~"planned"];

    node["name"~"projektowan"]["name"!="Nowoprojektowana"];
    way["name"~"projektowan"]["name"!="Nowoprojektowana"];
    relation["name"~"projektowan"]["name"!="Nowoprojektowana"];

    node["name"~"w budowie"];
    way["name"~"w budowie"];
    relation["name"~"w budowie"];

    node["name"~"koncepcja"];
    way["name"~"koncepcja"];
    relation["name"~"koncepcja"];

    // for usa see https://lists.openstreetmap.org/pipermail/talk-us/2017-September/017883.html
    node["name"~"(historical)"];
    way["name"~"(historical)"];
    relation["name"~"(historical)"];
  );
  out body;
  >;
  out skel qt;'

  watchlist << { list: get_list_from_arbitrary_query(query, reason: "lifecycle state in name", include_history_of_tags: true), message: "planowane/projektowane" }
  return watchlist
end

def watch_is_in
  watchlist = []
  query = ComplexQueryBuilder.filter_across_named_region('[is_in=Rybnik]', 'Rybnik')
  watchlist << { list: get_list_from_arbitrary_query(query, {}, reason: "useless is_in=Rybnik", include_history_of_tags: true), message: "useless is_in=Rybnik" }
  return watchlist
end

def watch_imports_failing_to_use_name
  watchlist = []
  query = '[out:json][timeout:25];
(
  node["massgis:SITE_NAME"]["massgis:SITE_NAME"!="name"];
  way["massgis:SITE_NAME"]["massgis:SITE_NAME"!="name"];
  relation["massgis:SITE_NAME"]["massgis:SITE_NAME"!="name"];
);
out body;
>;
out skel qt;'
  watchlist << { list: get_list_from_arbitrary_query(query, reason: "import cleanup", include_history_of_tags: true), message: "name and massgiss:SITE_NAME mismatch"}
  return watchlist
end

def proposed_without_source
  watchlist = []
  reason = "proposed without source"
  query = ComplexQueryBuilder.two_pass_filter_across_named_region("[highway=proposed]", "[highway=proposed]['source']", "Kraków")
  watchlist << { list: get_list_from_arbitrary_query(query, {}, reason: reason, include_history_of_tags: true), message: reason }
  query = ComplexQueryBuilder.two_pass_filter_across_named_region("[highway=proposed]", "[highway=proposed]['source']", "powiat legionowski")
  watchlist << { list: get_list_from_arbitrary_query(query, {}, reason: reason, include_history_of_tags: true), message: reason }
  query = ComplexQueryBuilder.two_pass_filter_across_named_region("[highway=proposed]", "[highway=proposed]['source']", "województwo małopolskie")
  watchlist << { list: get_list_from_arbitrary_query(query, {}, reason: reason, include_history_of_tags: true), message: reason }
  return watchlist
end

def watch_declared_historical_data
  watchlist = []
  latest_allowed_end_date = Time.now.year - age_of_historical_data_allowed_in_years
  query = "[out:json][timeout:2500];
(
node[end_date](if:date(t[end_date])<date(#{latest_allowed_end_date}));
way[end_date](if:date(t[end_date])<date(#{latest_allowed_end_date}));
relation[end_date](if:date(t[end_date])<date(#{latest_allowed_end_date}));
);
out meta;
>;
out meta qt;"

  watchlist << { list: get_list_from_arbitrary_query(query, reason: "end_date revealing historical data", include_history_of_tags: true), message: "planowane/projektowane" }
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

CartoCSSHelper::Configuration.set_path_to_folder_for_cache('/media/mateusz/5bfa9dfc-ed86-4d19-ac36-78df1060707c/OSM-cache')
run_watchlist