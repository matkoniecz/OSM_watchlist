# encoding: UTF-8
# frozen_string_literal: true
def test_on_low_zoom_levels
  [11, 10, 9, 8].each do |z|
    ['55c4b27', master].each do |branch| # new-road-style
      image_size = 780
      image_size = 300 if z <= 6
      # get_single_image_from_database('world', branch, 50.8288, 4.3684, z, 300, "Brussels #{branch}")
      # get_single_image_from_database('world', branch, -36.84870, 174.76135, z, 300, "Auckland #{branch}")
      # get_single_image_from_database('world', branch, 39.9530, -75.1858, z, 300, "New Jersey #{branch}")
      # get_single_image_from_database('world', branch, 55.39276, 13.29790, z, 300, "Malmo - fields #{branch}")
      get_single_image_from_database('world', branch, 50, 40, z, image_size, "Russia interior #{branch}")
      get_single_image_from_database('world', branch, 50, 20, z, image_size, "Krakow #{branch}")
      get_single_image_from_database('world', branch, 35.07851, 137.684848, z, image_size, "Japan #{branch}")
      if z < 10
        # nothing interesting on z11+
        get_single_image_from_database('world', branch, -12.924, -67.841, z, image_size, "South America #{branch}")
        get_single_image_from_database('world', branch, 50, 0, z, image_size, "UK, France #{branch}")
      end
      get_single_image_from_database('world', branch, 16.820, 79.915, z, image_size, "India #{branch}")
      before_after_directly_from_database('world', 53.8656, -0.6659, branch, branch, z..z, image_size, "rural UK #{branch}")
      before_after_directly_from_database('world', 64.1173, -21.8688, branch, branch, z..z, image_size, "Iceland, Reykjavik #{branch}")
    end
  end
end

def gsoc_places_unpaved(tested_branch, base_branch = 'master', zlevels = 16..16)
  CartoCSSHelper.visualise_place_by_file('test-clean.osm', 50.08690, 19.80704, zlevels, tested_branch, base_branch, 'testowy plik na bazie węzła balickiego')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=20/12.00254/8.52061&layers=H', zlevels, tested_branch, base_branch, 'large amount of unpaved roads')
  CartoCSSHelper.visualise_place_by_url('https://www.openstreetmap.org/#map=14/32.4695/14.5638', zlevels, tested_branch, base_branch, 'African city')
  CartoCSSHelper.visualise_place_by_url('https://www.openstreetmap.org/way/331381969#map=17/13.61762/13.26637', zlevels, tested_branch, base_branch, 'Major unpaved road')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/156691809#map=19/50.01290/20.04958', zlevels, tested_branch, base_branch, 'area that suffered from tagging for renderer - highway=track')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/41.43821/44.39127', zlevels, tested_branch, base_branch, 'with unpaved highway=tertiary - Potskhveriani')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/56.94206/24.05353', zlevels, tested_branch, base_branch, 'with unpaved and access=destination - Zasulauks')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/246695425#map=19/41.68142/44.76887', zlevels, tested_branch, base_branch, 'highway=raceway - unpaved & unset values')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/246695425#map=19/32.03150/35.57039', zlevels, tested_branch, base_branch, 'paved/unpaved with access=private', 2)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/180971580#map=17/54.85066/31.80019', zlevels, tested_branch, base_branch, 'unpaved village')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/51.46644/-0.23414', zlevels, tested_branch, base_branch, 'unpaved road in city')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.09367/19.83959', zlevels, tested_branch, base_branch, 'unpaved road in suburb')
end

def gsoc_places_major(tested_branch, base_branch = 'master', zlevels = 14..16)
  CartoCSSHelper.visualise_place_by_file('test-clean.osm', 50.08690, 19.80704, zlevels, tested_branch, base_branch, 'testowy plik na bazie węzła balickiego')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=15/41.8729/-87.6323', zlevels, tested_branch, base_branch, 'site of preview on repo - Chicago')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=52.5102&mlon=-1.8641#map=16/52.5102/-1.8641', zlevels, tested_branch, base_branch, 'spaghetti junction')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.07407/19.94527', zlevels, tested_branch, base_branch, 'junction of dual carriageways - 29 listopada')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=37.413889&mlon=126.566667&zoom=15#map=11/51.3413/6.9097', zlevels, tested_branch, base_branch, 'high density of motorways and primary roads')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/45.30670/11.69857', zlevels, tested_branch, base_branch, 'curvy roads', 0.1)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=16/51.6250/4.3842', zlevels, tested_branch, base_branch, 'nl test place', 0.15)
end

def gsoc_places_special(tested_branch, base_branch = 'master', zlevels = 15..16)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=42.160833&mlon=12.369167&zoom=15#map=15/42.1608/12.3691', zlevels, tested_branch, base_branch, 'raceway', 0.5)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/41.90304/12.45402', zlevels, tested_branch, base_branch, 'big pedestrian area, large amount of private highways')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=60.971944&mlon=7.368333&zoom=15#map=19/60.96863/7.36781', zlevels, tested_branch, base_branch, 'long tunnel', 0.2)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=16/-26.8955/20.6919', zlevels, tested_branch, base_branch, 'road+border - Iceland', 0.5)
end

def gsoc_places_steps(tested_branch = 'r', base_branch = 'master', zlevels = 15..16)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=50.0559&mlon=19.8486#map=14/50.0559/19.8486', zlevels, tested_branch, base_branch, 'las wolski', 0.06)
  CartoCSSHelper.visualise_place_by_url('https://www.openstreetmap.org/#map=18/37.44711/24.94306', zlevels, tested_branch, base_branch, 'steps (#1307)')
end

def gsoc_places_footways(tested_branch = 'r', base_branch = 'master', zlevels = 15..16)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=14/53.2134/-1.7983', zlevels, tested_branch, base_branch, 'rural area where highway=footway are important (UK)')
  CartoCSSHelper.visualise_place_by_url('/48.14578/17.11537', zlevels, tested_branch, base_branch, 'pedestrian/living street (in Bratislava)')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=18/50.05800/19.94748', zlevels, tested_branch, base_branch, 'sidewalks')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/41.90304/12.45402', zlevels, tested_branch, base_branch, 'big pedestrian area, large amount of private highways')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/52.4590957/13.362961', zlevels, tested_branch, base_branch, 'Berlin')
  CartoCSSHelper.visualise_place_by_url('https://www.openstreetmap.org/#map=16/52.0913/5.0358', zlevels, tested_branch, base_branch, 'Area with many pedestrian roads, living streets, footways...')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=16/50.0773/20.0382', zlevels, tested_branch, base_branch, 'many living streets')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.07846/19.88440', zlevels, tested_branch, base_branch, 'Widok')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=50.0559&mlon=19.8486#map=14/50.0559/19.8486', zlevels, tested_branch, base_branch, 'las wolski', 0.06)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=14/53.2134/-1.7983', zlevels, tested_branch, base_branch, 'rural area where highway=footway are important')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=50.0631&mlon=19.9584#map=14/50.0631/19.9584', zlevels, tested_branch, base_branch, 'area with large amount of footways')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/29239542#map=16/49.2157/20.0453', zlevels, tested_branch, base_branch, 'rocky mountains with tourism routes', 0.5)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=14/49.5502/20.1640', zlevels, tested_branch, base_branch, 'forested mountains with tourism routes', 0.5)
  CartoCSSHelper.visualise_place_by_file('2c.osm', 50.08690, 19.80704, zlevels, tested_branch, base_branch, 'testowy plik na bazie węzła balickiego + foot/cycle')
  gsoc_places_steps(tested_branch, base_branch, zlevels)
end

def gsoc_places_rural(tested_branch, base_branch = 'master', zlevels = 15..16, bb = 0.4, image_size = 500)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/52.51330/20.52969', zlevels, tested_branch, base_branch, 'rural area - Załuski', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/53.19694/19.64614', zlevels, tested_branch, base_branch, 'rural area - Górzno', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/51.19864/18.67987', zlevels, tested_branch, base_branch, 'rural area - okolice Wielunia', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=18/49.87433/16.77617', zlevels, tested_branch, base_branch, 'rural area - Czech republic', 1, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/49.15249/21.07066', zlevels, tested_branch, base_branch, 'rural area - Slovakia', 1, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=18/52.93190/7.08075', zlevels, tested_branch, base_branch, 'rural area - Netherlands', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/39.95229/8.73006', zlevels, tested_branch, base_branch, 'rural area - Italy - tracks', bb, image_size)
end

def gsoc_places_town(tested_branch, base_branch = 'master', zlevels = 15..16, bb = 0.04, image_size = 350)
  CartoCSSHelper.visualise_place_by_url('http://tools.geofabrik.de/mc/#14/4.6211/-74.1845&num=2&mt0=mapnik&mt1=google-map', zlevels, tested_branch, base_branch, 'extreme road density', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/51.30234/11.43073', zlevels, tested_branch, base_branch, 'European style town - Rossleben. Fully mapped.', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=16/50.0614/19.9400', zlevels, tested_branch, base_branch, 'Kraków - Stare Miasto', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=14/51.2225/18.5594', zlevels, tested_branch, base_branch, 'European style town - Wieluń', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=15/52.2333/20.9976', zlevels, tested_branch, base_branch, 'European style city - Warszawa', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=51.5147&mlon=-0.1126#map=10/51.5147/-0.1126', zlevels, tested_branch, base_branch, 'large area with high road density of many types', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=51.5117&mlon=-0.0761#map=14/51.5117/-0.0761', zlevels, tested_branch, base_branch, 'city with high road density', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=50.0509&mlon=19.9503#map=15/50.0509/19.9503', zlevels, tested_branch, base_branch, 'roads with tram lines', [0.5, bb].max, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=50.0296&mlon=19.9189#map=16/50.0296/19.9189', zlevels, tested_branch, base_branch, 'fully mapped residential area', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/68.95992/33.08489', zlevels, tested_branch, base_branch, 'city at high latitude', bb, image_size)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/relation/3369536#map=17/51.01461/4.43591', zlevels, tested_branch, base_branch, 'town in rural area', bb, image_size)
  gsoc_places_town_large_bb(tested_branch, base_branch, zlevels, bb, image_size)
end

def gsoc_places_town_large_bb(tested_branch, base_branch = 'master', zlevels = 15..16, bb = 0.4, image_size = 700)
  CartoCSSHelper.visualise_place_by_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/reykjavik_iceland.osm.pbf', 64.1013, -21.8877, zlevels, tested_branch, base_branch, 'Reykjavik, centered on amenity=parking spam', bb, image_size)
  CartoCSSHelper.visualise_place_by_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/mexico-city_mexico.osm.pbf', 19.4216, -99.0817, zlevels, tested_branch, base_branch, 'Ciudad de México', bb, image_size)
  CartoCSSHelper.visualise_place_by_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/tunis_tunisia.osm.pbf', 36.8481, 10.2289, zlevels, tested_branch, base_branch, 'Tunis, Tunisia', bb, image_size)
  CartoCSSHelper.visualise_place_by_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/chennai_india.osm.pbf', 13.07886, 80.27261, zlevels, tested_branch, base_branch, 'Chennai, India', bb, image_size)
  CartoCSSHelper.visualise_place_by_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/bangkok_thailand.osm.pbf', 13.7529438, 100.4941219, zlevels, tested_branch, base_branch, 'Bangkok, Thailand', bb, image_size)

  # TODO: - load by database switching
  # krakow_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/krakow_poland.osm.pbf'
  # CartoCSSHelper.visualise_place_by_remote_file(krakow_url, 50.06864, 19.94569, zlevels, 'tram', 'origin/master', 'tram infestation - Kraków', bb, image_size)

  prague_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/prague_czech-republic.osm.pbf'
  CartoCSSHelper.visualise_place_by_remote_file(prague_url, 50.0853, 14.4320, zlevels, tested_branch, base_branch, 'Prague, Czech Republic', bb, image_size)

  helsinki_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/helsinki_finland.osm.pbf'
  CartoCSSHelper.visualise_place_by_remote_file(helsinki_url, 60.16827, 24.93188, zlevels, tested_branch, base_branch, 'Helsinki, Finland', bb, image_size)

  # TODO: - load by database switching
  # vienna_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/vienna-bratislava_austria.osm.pbf'
  # CartoCSSHelper.visualise_place_by_remote_file(vienna_url, 48.20860, 16.36801, zlevels, 'tram', 'origin/master', 'tram infestation - Vienna', bb, image_size)
end

def test_low_invisible(to, from = 'master', zlevels = 11..19, bb = 0.1)
  # CartoCSSHelper.visualise_place_by_file('test-clean.osm', 50.08690, 19.80704, zlevels, to, from, 'testowy plik na bazie węzła balickiego')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.08708/19.80613', zlevels, to, from, 'Węzeł Balicki', bb)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/51.51433/-0.10396', 4..19, to, from, 'London', bb)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/node/26804505#map=16/55.5672/12.9951', zlevels, to, from, 'Malmo - secondary', bb)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/46.49862/11.27512', zlevels, to, from, 'Bolzano - trunk', bb)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=13/49.7907/10.1122', 6..6, to, from, 'low motorway', 1)
  CartoCSSHelper.visualise_place_by_url('https://www.openstreetmap.org/#map=16/40.0401/39.8565', zlevels, to, from, 'tertiary vs secondary - see #631', bb)
  CartoCSSHelper.visualise_place_by_url('https://www.openstreetmap.org/#map=16/40.0401/39.8565', 10..12, to, from, 'tertiary vs secondary - see #631', bb, 300)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/41.01076/28.96781', zlevels, to, from, 'Instanbul - high density', bb)
end

def test_regressions(to, _from = 'master', _zlevels = 11..19, _bb = 0.1, _full = false)
  # "access=no" rendering can hardly been seen on "highway=primary" ways #831
  test_linear_tag_set({ 'highway' => 'primary', 'access' => 'private' }, to, 16..16)
  test_linear_tag_set({ 'highway' => 'trunk', 'access' => 'private' }, to, 16..16)
  test_linear_tag_set({ 'highway' => 'motorway', 'access' => 'private' }, to, 16..16)
end

def test_linear_tag_set(tags, tested_branch, zlevels = 11..19)
  base_branch = 'master'
  CartoCSSHelper.probe tags, tested_branch, base_branch, zlevels, ['way']
  CartoCSSHelper.test_tag_on_real_data_for_this_type(tags, tested_branch, base_branch, zlevels, 'way')
end

def test_road_type(tested_branch, tag = 'footway')
  tags = { 'highway' => tag }
  test_linear_tag_set(tags, tested_branch)
  tags = { 'highway' => tag, 'tunnel' => 'yes' }
  test_linear_tag_set(tags, tested_branch)
  tags = { 'highway' => tag, 'bridge' => 'yes' }
  test_linear_tag_set(tags, tested_branch)
end

def gsoc_full(tested_branch, base_branch = 'master', zlevels = 9..18) # CartoCSSHelper::Configuration.get_min_z..CartoCSSHelper::Configuration.get_max_z
  gsoc_places_unpaved(tested_branch, base_branch, zlevels)
  test_regressions(tested_branch, base_branch, zlevels, 0.1, true)
  gsoc_places(tested_branch, base_branch = 'master', zlevels)
  CartoCSSHelper.visualise_place_by_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/grenoble_france.osm.pbf', 45.19594, 5.71654, zlevels, tested_branch, base_branch, 'European style city - Grenoble. Well mapped.') # missing landuses, service=* on rails
  CartoCSSHelper.visualise_place_by_url('http://bestofosm.org/?zoom=16&lat=37.00562&lon=-121.57058&layers=B0000000FFFFTTTTT', zlevels, tested_branch, base_branch, 'European style town - Gillroy. Fully mapped.') # missing service tags on railway tracks
  # CartoCSSHelper.visualise_place_by_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/sao-paulo_brazil.osm.pbf', -23.5910, -46.5642, zlevels, tested_branch, base_branch, 'São Paulo', bb, image_size) #terrible, terrible road classification

  # obsolete by withdrawing new footways
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.08303/19.89063', zlevels, tested_branch, base_branch, 'footway through landuse=railway - AK')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=18/50.06716/19.94821', zlevels, tested_branch, base_branch, 'footway through landuse=railway - Kraków Główny')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=18/50.10452/20.01297', zlevels, tested_branch, base_branch, 'footway near industrial')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/98199328#map=18/50.26827/18.99975', zlevels, tested_branch, base_branch, 'footway in industrial')
end

def gsoc_places(tested_branch, base_branch = 'master', zlevels = 9..18)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/28.06349/34.42851', zlevels, tested_branch, base_branch, 'road through sand')

  gsoc_places_major(tested_branch, base_branch, zlevels)
  gsoc_places_rural(tested_branch, base_branch, zlevels)
  gsoc_places_footways(tested_branch, base_branch, zlevels)
  gsoc_places_town(tested_branch, base_branch, zlevels)
  test_low_invisible(tested_branch, base_branch, zlevels)
  gsoc_places_special(tested_branch, base_branch, zlevels)
  test_regressions(tested_branch, base_branch, zlevels)
end

def get_all_road_types
  return ['motorway', 'motorway_link', 'trunk', 'trunk_link', 'primary', 'primary_link', 'secondary', 'secondary_link', 'tertiary', 'tertiary_link', 'unclassified', 'residential', 'living_street', 'pedestrian', 'path', 'service', 'track', 'raceway', 'bridleway', 'bus_guideway', 'cycleway', 'footway', 'road', 'steps', 'construction']
end

def get_all_road_types_that_may_be_unpaved
  return ['raceway', 'primary', 'secondary', 'tertiary', 'tertiary_link', 'unclassified', 'residential', 'living_street', 'pedestrian', 'path', 'service', 'track', 'raceway', 'bridleway', 'cycleway', 'footway', 'road']
end

def get_all_road_types_that_are_likely_to_be_unpaved_with_expected_rendering_change
  return ['raceway', 'primary', 'secondary', 'tertiary', 'residential', 'unclassified', 'living_street', 'pedestrian', 'service', 'road']
end

def get_all_road_types_that_are_highly_unlikely_to_be_unpaved
  return ['primary_link', 'secondary_link', 'tertiary_link']
end

def test_unpaved(tested_branch, base_branch = 'master', zlevels = 16..16)
  gsoc_places_unpaved(tested_branch, base_branch)
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'surface' => 'unpaved', 'highway' => 'primary', 'access' => 'destination' }, 'way', false, zlevels, tested_branch, base_branch)

  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'surface' => 'unpaved' }, tested_branch, base_branch, zlevels, 'way')
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'surface' => 'unpaved', 'highway' => 'residential' }, tested_branch, base_branch, zlevels, 'way')
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'surface' => 'unpaved', 'access' => 'private' }, tested_branch, base_branch, zlevels, 'way')
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'surface' => 'unpaved', 'access' => 'no' }, tested_branch, base_branch, zlevels, 'way')
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'surface' => 'unpaved', 'access' => 'destination' }, tested_branch, base_branch, zlevels, 'way')

  get_all_road_types_that_are_likely_to_be_unpaved_with_expected_rendering_change.each do |highway_value|
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'surface' => 'unpaved', 'highway' => highway_value }, tested_branch, base_branch, zlevels, 'way')
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'surface' => 'unpaved', 'highway' => highway_value, 'access' => 'destination' }, tested_branch, base_branch, zlevels, 'way')
    # CartoCSSHelper.test_tag_on_real_data_for_this_type({'surface' => 'unpaved', 'highway'=> highway_value, 'access'=> 'no'}, tested_branch, base_branch, zlevels, 'way')
  end
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'surface' => 'unpaved', 'highway' => 'primary' }, 'way', false, zlevels, tested_branch, base_branch)
  CartoCSSHelper.visualise_place_by_file('test-clean.osm', 50.08690, 19.80704, zlevels, tested_branch, base_branch, 'testowy plik na bazie węzła balickiego')
end

def additional_test_unpaved(tested_branch, base_branch = 'master', zlevels = 16..16)
  get_all_road_types_that_are_highly_unlikely_to_be_unpaved.each do |highway_value|
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'surface' => 'unpaved', 'highway' => highway_value }, tested_branch, base_branch, zlevels, 'way')
    # CartoCSSHelper.test_tag_on_real_data_for_this_type({'surface' => 'unpaved', 'highway'=> highway_value, 'access'=> 'destination'}, tested_branch, base_branch, zlevels, 'way')
    # CartoCSSHelper.test_tag_on_real_data_for_this_type({'surface' => 'unpaved', 'highway'=> highway_value, 'access'=> 'no'}, tested_branch, base_branch, zlevels, 'way')
  end
end

def generate_preview(branches, download_bbox_size = 0.05)
  top_lat = 41.8788
  lef_lon = -87.6515
  bottom_lat = 41.8693
  right_lon = -87.6150
  xmin = lef_lon
  ymin = bottom_lat
  xmax = right_lon
  ymax = top_lat

  #--bbox=[xmin,ymin,xmax,ymax]
  bbox = "#{xmin},#{ymin},#{xmax},#{ymax}"
  width = 852
  height = 300
  zlevel = 15
  params = "--format=png --width=#{width} --height=#{height} --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
  project_name = CartoCSSHelper::Configuration.get_tilemill_project_name

  filename = "preview for readme #{download_bbox_size}.png"
  branches.each do |branch|
    Git.checkout branch
    export_filename = Configuration.get_path_to_folder_for_branch_specific_cache + filename
    next if File.exist?(export_filename)
    latitude = (ymin + ymax) / 2
    longitude = (xmin + xmax) / 2
    osm_data_filename = OverpassQueryGenerator.get_file_with_downloaded_osm_data_for_location(latitude, longitude, download_bbox_size)
    DataFileLoader.load_data_into_database(osm_data_filename)

    command = "node /usr/share/tilemill/index.js export #{project_name} '#{export_filename}' #{params}"
    puts command
    system command
  end

  branches.each do |branch|
    Git.checkout branch
    source = Configuration.get_path_to_folder_for_branch_specific_cache + filename
    destination = Configuration.get_path_to_folder_for_output + "preview #{branch} #{download_bbox_size}.png"
    puts source
    puts destination
    if File.exist?(source)
      FileUtils.copy_entry source, destination, false, false, true
    else
      raise 'file that should be created is not present'
    end
  end
end

def test_all_road_types(to)
  get_all_road_types.each do |tag|
    test_road_type to, tag
  end
end

def test_current_road_style(to, from = 'master')
  test_low_invisible(to, from, 0.5)
  gsoc_places_major(to, from)
  gsoc_places(to, from)
  test_regressions(to, from)
  test_all_road_types(to)
end

def base_test(to, from = 'master')
  CartoCSSHelper::VisualDiff.enable_job_pooling
  gsoc_places(to, from)

  CartoCSSHelper::VisualDiff.run_jobs
  test_current_road_style(to)
  CartoCSSHelper::VisualDiff.run_jobs
  CartoCSSHelper::VisualDiff.disable_job_pooling
end

def show_fixed_bugs(to, from = 'master')
  image_size = 250
  CartoCSSHelper.visualise_place_by_url('https://www.openstreetmap.org/#map=16/40.0401/39.8565', 10..12, to, from, 'Tertiary roads more dominant than secondary on z10 #631', 1, image_size)

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=13/49.6328/5.9589', 14..15, to, from, 'junction=motorway_junction names are hard to read (#1272)', 0.04, image_size) # full: 13..15

  # Motorways on low zoom levels are very hard to notice and look like rivers #319
  before_after_directly_from_database('world', 53.357, -6.416, 'gsoc', 'master', 6..7, 200)

  # 102 - Secondary and trunk color too similar to landuse colors
  before_after_directly_from_database('world', 55.39276, 13.29790, to, from, 10..11, image_size, "Malmo - fields #{from} -> #{to}")
  before_after_directly_from_database('world', 50.8288, 4.3684, to, from, 10..10, image_size, "Brussels - forest #{from} -> #{to}") # full: 8..11
  before_after_directly_from_database('world', 34.8858, 135.4276, to, from, 10..10, image_size, "Japan #{from} -> #{to}") # full: 8..11

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=-27.4111&mlon=153.0442#map=13/-27.4110/153.0442', 13..15, to, from, 'motorway tunnels are nearly invisible on z13 and lower #914', 0.04, image_size)

  before_after_directly_from_database('rome', 41.90876, 12.44837, to, from, 15..19, image_size, "Make road-casing stronger #1124 #{from} -> #{to}")

  joining = 'Some streets that are not joining may on zoom out misleadingly appear to be joining #286'
  # before_after_directly_from_database('krakow', 50.06873, 19.91165, to, from, 16..16, image_size, joining)
  before_after_directly_from_database('krakow', 50.05540, 19.95885, to, from, 16..16, image_size, joining)
  # before_after_directly_from_database('krakow', 50.0638, 19.9241, to, from, 16..16, image_size, joining)
end
