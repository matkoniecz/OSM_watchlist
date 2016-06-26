# encoding: UTF-8
# frozen_string_literal: true
# frozen_string_literal: true

# before_after_from_loaded_databases({'highway' => 'pedestrian', 'area'=>'yes', 'name' => :any_value}, 'pnorman/road_areas', 'v2.38.0', 16..18, 400, 2, 0)

# vienna_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/vienna-bratislava_austria.osm.pbf'
# load_remote_file_and_quit(vienna_url)

# url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/london_england.osm.pbf'
# load_remote_file_and_quit(url)

# test_pedestrian_pr('pale_imagico_blue', 'pale_imagico_blue', zlevels, faster)
# ['e6', 'e4', 'e2', 'e0'].each {|branch|
#  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/157403305#map=18/41.6974955/44.81631', zlevels, branch, branch, 'conflict with landuse=residential - church collision_with_residential')
# }

def test_viewpoint
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'tourism' => 'viewpoint', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'closed_way', false, 12..22, 'viewpoint', 'master')
  before_after_from_loaded_databases({ 'tourism' => 'viewpoint', 'name' => :any_value }, 'viewpoint', 'master', 18..18, 350, 5, 0)
  # missing label
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', '41714f1')

  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'tourism' => 'attraction', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', 'master')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', 'master')

  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'tourism' => 'attraction', 'name' => 'a' }, 'closed_way', false, 22..22, 'test1', 'master')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'test1', 'master')
end

def test_rail_pr
  # before_after_from_loaded_databases({'railway' => 'rail', 'tunnel' => 'yes', 'service' => :any_value}, 'rail', 'master', 17..20, 1100, n, skip)
  # final
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'railway' => 'rail', 'tunnel' => 'yes', 'service' => :any_value }, 'rail', 'master', 17..20, 'way', 5)
  before_after_from_loaded_databases({ 'railway' => 'rail' }, 'rail', 'master', 17..20, 1100, 3, 1)
  before_after_from_loaded_databases({ 'railway' => 'rail', 'tunnel' => 'yes' }, 'rail', 'master', 17..20, 1100, 3, 1)
end

def test_eternal_710_text_resize
  # CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({'amenity' => 'bicycle_parking'}.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}), 'closed_way', false, 22..22, 'eternal_710', 'master')
  # CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({'amenity' => 'parking'}.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}), 'closed_way', false, 22..22, 'eternal_710', 'master')
  # CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({'amenity' => 'motorcycle_parking'}.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}), 'closed_way', false, 22..22, 'eternal_710', 'master')
  # before_after_from_loaded_databases({'amenity'=>'hospital', 'name' => :any_value}, 'eternal_710', 'master', 18..18, 1000, 5, 0)
  # before_after_from_loaded_databases({'highway' => 'pedestrian', 'area'=>'yes', 'name' => :any_value}, 'eternal_710', 'master', 18..18, 1000, 5, 0)
  affected = [
    # was 11
    { 'leisure' => 'miniature_golf' },
    { 'leisure' => 'golf_course' },
    { 'leisure' => 'playground' },
    { 'leisure' => 'water_park' },
    # was 9
    { 'amenity' => 'car_rental' },
    { 'amenity' => 'bicycle_rental' },
    { 'leisure' => 'slipway' },
    { 'amenity' => 'parking' },
    { 'amenity' => 'bicycle_parking' },
    { 'amenity' => 'motorcycle_parking' },
    { 'historic' => 'memorial' },
    { 'historic' => 'monument' },
    { 'historic' => 'archaeological_site' },
    { 'amenity' => 'embassy' },
    { 'amenity' => 'taxi' },
    { 'highway' => 'bus_stop' },
    { 'amenity' => 'fuel' },
    { 'amenity' => 'bus_station' },
    { 'amenity' => 'fountain' },
    { 'man_made' => 'lighthouse' },
    { 'man_made' => 'windmill' },
    { 'amenity' => 'recycling' },
    { 'natural' => 'tree' },

    # was 8
    { 'aeroway' => 'helipad' },
    { 'aeroway' => 'aerodrome' },
    { 'amenity' => 'hospital' },
    { 'amenity' => 'clinic' },
    { 'amenity' => 'pharmacy' },
    { 'amenity' => 'doctors' },
    { 'amenity' => 'dentist' },
    { 'amenity' => 'veterinary' },

    # was 10, partial list
    { 'shop' => 'books' },
    { 'place' => 'island' },
    { 'amenity' => 'pub' },
    { 'amenity' => 'police' },
    { 'amenity' => 'car_wash' },
    { 'tourism' => 'museum' },
    { 'amenity' => 'place_of_worship' },
    { 'natural' => 'peak' },
    { 'historic' => 'wayside_cross' },
    { 'amenity' => 'bank' },
    { 'amenity' => 'atm' },
    { 'tourism' => 'alpine_hut' },
    { 'amenity' => 'prison' },
    { 'shop' => 'bakery' },
    { 'shop' => 'supermarket' },
    { 'amenity' => 'hunting_stand' },
  ]

  active = false
  affected.each do |_tag|
    # active =true if (tag == {'amenity' => 'car_wash'})
    # next unless active
    # CartoCSSHelper::VisualDiff.visualise_on_synthethic_data(tag.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}), 'node', false, 22..22, 'eternal_710', 'master')
  end
  affected.each do |tag|
    before_after_from_loaded_databases(tag.merge({ 'name' => :any_value }), 'eternal_710', 'master', 16..18, 300, 1, 5)
    # before_after_from_loaded_databases(tag, 'eternal_710', 'master', 16..18, 300, 1, 0)
  end
end

def test_decasing
  [11].each do |z|
    ['decased01', 'decased00', 'decasedz11'].each do |branch| # new-road-style
      # [frozen_trunk, master, 'decasedz11'].each {|branch| #new-road-style
      image_size = 780
      image_size = 300 if z <= 6
      get_single_image_from_database('world', branch, 50.8288, 4.3684, z, image_size, "Brussels #{branch}")
      get_single_image_from_database('world', branch, -36.84870, 174.76135, z, image_size, "Auckland #{branch}")
      get_single_image_from_database('world', branch, 39.9530, -75.1858, z, image_size, "New Jersey #{branch}")
      get_single_image_from_database('world', branch, 55.39276, 13.29790, z, image_size, "Malmo - fields #{branch}")
      get_single_image_from_database('world', branch, 50, 40, z, image_size, "Russia interior #{branch}")
      get_single_image_from_database('world', branch, 50, 20, z, image_size, "Krakow #{branch}")
      get_single_image_from_database('world', branch, 35.07851, 137.684848, z, image_size, "Japan #{branch}")
      if z < 10
        # nothing interesting on z11+
        get_single_image_from_database('world', branch, 50, 0, z, image_size, "London #{branch}")
        get_single_image_from_database('world', branch, -12.924, -67.841, z, image_size, "South America #{branch}")
      end
      get_single_image_from_database('world', branch, 16.820, 79.915, z, image_size, "India #{branch}")
      get_single_image_from_database('world', branch, 53.8656, -0.6659, z, image_size, "rural UK #{branch}")
      get_single_image_from_database('world', branch, 64.1173, -21.8688, z, image_size, "Iceland, Reykjavik #{branch}")
    end
  end
  end

def test7
  [750].each do |image_size|
    [7].each do |z|
      lat = 53.245
      lon = -2.274
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)

      lat = 48
      lon = 35
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)

      lat = 50
      lon = 20
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)

      lat = 50
      lon = 40
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)

      lat = 50
      lon = 60
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)

      lat = 50
      lon = 80
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)

      lat = 50
      lon = 100
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)

      lat = 16.820
      lon = 79.915
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)

      # lat = 53.8656
      # lon = -0.6659
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)

      lat = 64.1173
      lon = -21.8688
      # get_single_image_from_database('world', frozen_trunk, lat, lon, z, image_size)
      get_single_image_from_database('world', 'z7', lat, lon, z, image_size)
      get_single_image_from_database('world', 'rail', lat, lon, z, image_size)
    end
  end
  final
  zoom = 10..10
  # before_after_directly_from_database('vienna', 48.0918, 15.8807, 'glowlayer', 'glow', zoom, 300, 'minor roads')
  # before_after_directly_from_database('vienna', 48.0918, 15.8807, 'glowlayer', frozen_trunk, zoom, 300, 'minor roads')
  # before_after_directly_from_database('vienna', 48.0918, 15.8807, 'glow', frozen_trunk, zoom, 300, 'minor roads')
  # before_after_directly_from_database('vienna', 48.0918, 15.8807, 'joinround', frozen_trunk, zoom, 300, 'minor roads')
  # before_after_directly_from_database('vienna', 48.0918, 15.8807, 'joinround', 'glow', zoom, 300, 'minor roads')
  # before_after_directly_from_database('vienna', 48.0918, 15.8807, 'glowcap', 'glow', zoom, 300, 'minor roads')
  # final

  large_scale_diff('decasedz11', master, 780, 9..11)
  large_scale_diff('55c4b27', master, 780, 9..11)

  # test_low_invisible('band-aid', master)

  # large_scale_diff('new-road-style', master, 375, 12..14)
  [400].each do |image_size|
    [7, 8, 6].each do |z|
      get_single_image_from_database('world', 'vholten-1-dark', 48.07104, 17.07272, z, image_size)
      get_single_image_from_database('world', 'vholten-2-dark', 48.07104, 17.07272, z, image_size)
      get_single_image_from_database('world', frozen_trunk, 48.07104, 17.07272, z, image_size)
    end
  end
  final

  zlevels = 9..12
  before_after_directly_from_database('motorway_border_mess', 51.5754, -2.7068, frozen_trunk, master, zlevels, 500, 'motorway_border_mess')
  before_after_directly_from_database('motorway_border_mess', 51.5754, -2.7068, 'vholten-1', frozen_trunk, zlevels, 500, 'motorway_border_mess')
  before_after_directly_from_database('motorway_border_mess', 51.5754, -2.7068, 'vholten-2', frozen_trunk, zlevels, 500, 'motorway_border_mess')

  [400].each do |image_size|
    [7, 8, 6].each do |z|
      get_single_image_from_database('world', 'vholten-1', 48.07104, 17.07272, z, image_size)
      get_single_image_from_database('world', 'vholten-2', 48.07104, 17.07272, z, image_size)
      get_single_image_from_database('world', frozen_trunk, 48.07104, 17.07272, z, image_size)
    end
  end

  final
end

def test_farmland(to)
  from = 'master'
  zlevels = 10..16
  image_size = 800
  before_after_directly_from_database('london', 51.36395, -0.01508, to, from, zlevels, image_size, 'London')
  before_after_directly_from_database('krakow', 50.08007, 19.84756, to, from, zlevels, image_size, 'Mydlniki')
  before_after_directly_from_database('market', 53.8656, -0.6641, to, from, zlevels, image_size, 'Market Weighton')
  before_after_directly_from_database('kosice', 48.8156, 21.1003, to, from, zlevels, image_size, 'Kosice')
  before_after_directly_from_database('kosice', 49.0196, 21.1869, to, from, zlevels, image_size, 'Presov')
  edelta_run
end

def probe_forest(to, from = 'master', zlevels = 18..18)
  CartoCSSHelper.probe({ 'landuse' => 'forest', 'wetland' => 'saltmarsh' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wood', 'wetland' => 'saltmarsh' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'wetland' => 'saltmarsh' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'landuse' => 'forest' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'landuse' => 'forest', 'natural' => 'wetland' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wood' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'mud' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'marsh' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland', 'wetland' => 'saltmarsh' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland', 'wetland' => 'wet_meadow' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland', 'wetland' => 'fen' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland', 'wetland' => 'reedbet' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland', 'wetland' => 'mangrove' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland', 'wetland' => 'swamp' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland', 'wetland' => 'bog' }, to, from, zlevels, ['closed_way'])
  CartoCSSHelper.probe({ 'natural' => 'wetland', 'wetland' => 'string_bog' }, to, from, zlevels, ['closed_way'])
end

def test_heath(branch = 'heath')
  before_after_directly_from_database('london', 51.44040, -0.23186, branch, 'master', 17..17, 300, 'London')
  # before_after_directly_from_database('london', 51.44145, -0.23170, branch, 'master', 10..19, 450, 'London')
  test_tag_on_real_data_pair_for_this_type({ 'natural' => 'heath' }, { 'natural' => 'scrub' }, branch, 'master', 17..17, 'way')
end

def multicolider(fast = true)
  zlevels = 17..17
  test_pedestrian_pr('imagico_blue', 'imagico_blue', zlevels, fast)
  test_pedestrian_pr('new-road-style', 'new-road-style', zlevels, fast)
  test_pedestrian_pr('collision_with_residential', 'collision_with_residential', zlevels, fast)
  test_pedestrian_pr('red', 'red', zlevels, fast)
  # test_pedestrian_pr('master', 'master', zlevels, fast)

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/255795002#map=19/50.30822/19.06292', zlevels, 'red', 'red', 'test_pedestrian_on_industrial (1) red')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/157403305#map=18/41.54300/45.01203', zlevels, 'collision_with_residential', 'collision_with_residential', 'conflict with landuse=residential - Orchester collision_with_residential')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/157403305#map=18/41.6974955/44.81631', zlevels, 'collision_with_residential', 'collision_with_residential', 'conflict with landuse=residential - church collision_with_residential')
end

def various_from_gsoc
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=53.149497&mlon=-6.3292126', 16..16, branch, 'master', 'bog', 0.1)
  before_after_directly_from_database('world', 47.1045, -122.5882, branch, 'master', 9..10, 375)

  before_after_directly_from_database('rome', 41.92054, 12.48020, branch, 'master', 12..19, 375)
  before_after_directly_from_database('rome', 41.85321, 12.44090, branch, 'master', 12..19, 375)
  large_scale_diff(branch, 'master')
  before_after_directly_from_database('krakow', 50.08987, 19.89922, branch, 'master', 12..19, 375)
  generate_preview([branch])

  image_size = 780
  [6, 5, 7].each do |z|
    ['55c4b27', master].each do |branch|
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

  CartoCSSHelper::VisualDiff.enable_job_pooling
  gsoc_places(branch, branch, 7..17)
  CartoCSSHelper::VisualDiff.run_jobs

  gsoc_full(branch, branch, 7..17)
  CartoCSSHelper::VisualDiff.shuffle_jobs(4)
  CartoCSSHelper::VisualDiff.run_jobs

  test_all_road_types(branch)

  CartoCSSHelper::VisualDiff.run_jobs

  base_test(to)

  # test_ministop('mediumstop', 'ministop')
  # ['e6', 'e4', 'e2', 'e0'].each {|branch|
  #  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/157403305#map=18/41.6974955/44.81631', zlevels, branch, branch, 'conflict with landuse=residential - church collision_with_residential')
  # }

  # before_after_directly_from_database('rome', 41.90876, 12.44837, 'gsoc', 'master', 17..19, 350, 'Make road-casing stronger #1124')
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=50.09020&mlon=19.89328#map=19/50.09020/19.89328', 17..19, 'gsoc', 'master', 'service', 0.04, 350)
  # test_tag_on_real_data_pair_for_this_type({'highway' => 'tertiary'}, {'highway' => 'service', 'service' => :any_value}, 'gsoc', 'master', 17..19, 'way', 7, 0, 350)

  # test_pedestrian_pr('gsoc', 'master', 14..16, true)

  # before_after_directly_from_database('reykjavik', 64.1188, -21.8933, 'gsoc', 'master', 12..12, 1000)

  # no bridges CartoCSSHelper.test_tag_on_real_data ({'highway' => 'secondary', 'bridge' => 'yes'}), 'new-road-style', 'master', 12..12, ['way'], 4
  # test_ministop('mediumstop', 'master')
  # CartoCSSHelper.test_tag_on_real_data ({'highway' => 'secondary', 'bridge' => 'yes'}), 'trunk', 'master', 13..14, ['way'], 7
  # large_scale_diff('trunk', 'master', 375, 12..14)
  before_after_directly_from_database('london', 51.54384, -0.00054, 'published', 'master', 16..18, 375, 'Problem reported by Math')
  test_low_zoom('railmoto7low', 7..7)
  test_low_invisible('band-aid', 'master', 11..16)
  before_after_directly_from_database('kosice', 49.08921, 21.31254, 'gsoc', 'new-road-style', 11..11, 375, 'weird thingy')
  [7, 8].each do |z| # 11, 10, 9, 8
    puts z
    ['raillow', 'raillowlow', 'new-road-style'].each do |branch|
      get_single_image_from_database('world', branch, 50.8288, 4.3684, z, 750, "Brussels #{branch}")
      get_single_image_from_database('world', branch, -36.84870, 174.76135, z, 750, "Auckland #{branch}")
      get_single_image_from_database('world', branch, 39.9530, -75.1858, z, 750, "New Jersey #{branch}")
      get_single_image_from_database('world', branch, 55.39276, 13.29790, z, 750, "Malmo - fields #{branch}")
    end
  end
  # before_after_directly_from_database('krakow', 50.04069, 19.96767, 'longrail', 'master', 11..12, 500, 'węzeł kolejowy')
  # before_after_directly_from_database('kosice', 49.0196, 21.1869, 'longrail', 'master', 11..12, 500, 'London')
  # before_after_directly_from_database('krakow', 50.04069, 19.96767, 'rail', 'master', 9..20, 500, 'węzeł kolejowy')
  large_scale_diff('chroma', 'new-road-style', 450, 11..18)
  test_low_invisible('chroma', 'new-road-style', 11..18)

  before_after_directly_from_database('world', 49, 13.5, 'new-road-style', 'new-road-style', 14..14, 800, 'worldtest')
  before_after_directly_from_database('world', 49, 13.5, 'new-road-style', 'new-road-style', 13..13, 800, 'worldtest')
  before_after_directly_from_database('world', 49, 13.5, 'new-road-style', 'new-road-style', 12..12, 800, 'worldtest')
  before_after_directly_from_database('world', 49, 13.5, 'new-road-style', 'new-road-style', 11..11, 800, 'worldtest')
  before_after_directly_from_database('world', 49, 13.5, 'new-road-style', 'new-road-style', 10..10, 800, 'worldtest')
  before_after_directly_from_database('world', 49, 13.5, 'new-road-style', 'new-road-style', 9..9, 800, 'worldtest')
  before_after_directly_from_database('world', 49, 13.5, 'new-road-style', 'new-road-style', 8..8, 800, 'worldtest')

  # CartoCSSHelper.test_tag_on_real_data ({'railway' => 'tram', 'service' => 'yard'}), 'tram-service-bad', 'tram-service', 15..15, ['way'], 5, 24
  # CartoCSSHelper.test_tag_on_real_data ({'railway' => 'tram', 'service' => 'yard'}), 'tram-service', 'master', 15..15, ['way'], 5, 24

  # url = 'download.geofabrik.de/europe/poland-latest.osm.pbf'
  # load_remote_file_and_quit(url)
  # final

  before_after_directly_from_database('london', 51.50780, -0.12392, 'new-road-style', 'new-road-style', 7..10, 450, 'London')
  before_after_directly_from_database('london', 51.50780, -0.12392, 'stronglowrail', 'stronglowrail', 7..10, 450, 'London')
  before_after_directly_from_database('london', 51.50780, -0.12392, 'superrail', 'superrail', 7..10, 450, 'London')
  before_after_directly_from_database('london', 51.50780, -0.12392, 'superplusrail', 'superplusrail', 7..10, 450, 'London')

  [9, 8, 7, 6, 5].each do |z|
    before_after_directly_from_database('world', 35, -100, 'new-road-style', 'new-road-style', z..z, 800, 'worldtest USA (35, -100)')
    before_after_directly_from_database('world', 35, -100, 'superrail', 'superrail', z..z, 800, 'worldtest USA (35, -100)')
    before_after_directly_from_database('world', 35, -100, 'superplusrail', 'superplusrail', z..z, 800, 'worldtest USA (35, -100)')
    before_after_directly_from_database('world', 49, 13.5, 'new-road-style', 'new-road-style', z..z, 800, 'worldtest (49, 13.5)')
    before_after_directly_from_database('world', 50, 0, 'new-road-style', 'new-road-style', z..z, 800, 'worldtest (50, 0)')
    # before_after_directly_from_database('world', 50, 0, 'stronglowrail', 'stronglowrail', z..z, 800, 'worldtest (50, 0)')
    before_after_directly_from_database('world', 50, 0, 'superrail', 'superrail', z..z, 800, 'worldtest (50, 0)')
    before_after_directly_from_database('world', 50, 0, 'superplusrail', 'superplusrail', z..z, 800, 'worldtest (50, 0)')
    before_after_directly_from_database('world', 51, 7, 'new-road-style', 'new-road-style', z..z, 800, 'worldtest (51, 7)')
    # before_after_directly_from_database('world', 51, 7, 'stronglowrail', 'stronglowrail', z..z, 800, 'worldtest (51, 7)')
    before_after_directly_from_database('world', 51, 7, 'superrail', 'superrail', z..z, 800, 'worldtest (51, 7)')
    before_after_directly_from_database('world', 51, 7, 'superplusrail', 'superplusrail', z..z, 800, 'worldtest (51, 7)')
  end

  CartoCSSHelper::VisualDiff.enable_job_pooling
  test_tag_on_real_data_pair_for_this_type({ 'landuse' => 'orchard' }, { 'natural' => 'scrub' }, 'old_new_forest', 'new_forest', 10..18, 'way', 3, 1)
  CartoCSSHelper::VisualDiff.run_jobs

  zlevels = 13..16
  ender(true)
  ender(false)

  faster = true
  test_pedestrian_pr('titan_blue', 'titan_blue', zlevels, faster) # new

  faster = false
  test_pedestrian_pr('titan_blue', 'titan_blue', zlevels, faster) # new

  final

  latitude = 50
  longitude = 20
  size = 0.1
  latitude, longitude = find_nearby({ 'landuse' => 'orchard' }, { 'natural' => 'scrub' }, latitude, longitude, size)
  before_after_directly_from_database('krakow', latitude, longitude, 'new_forest', 'master', 10..18, 500, 'Krakow')
  before_after_directly_from_database('krakow', latitude, longitude, 'no_scrub', 'new_forest', 10..18, 500, 'Krakow')

  CartoCSSHelper.visualise_place_by_url('/53.31687/-1.54226', 10..19, 'master', 'master', 'Tootley - railway tunnel', 0.2)
  CartoCSSHelper.visualise_place_by_url('/53.31687/-1.54226', 10..19, 'new-road-style', 'new-road-style', 'Tootley - railway tunnel', 0.2)
  before_after_directly_from_database('london', 51.54478, 0.00074, 'master', 'master', 10..19, 400, 'London - railway tunnel')
  before_after_directly_from_database('london', 51.54478, 0.00074, 'new-road-style', 'new-road-style', 10..19, 400, 'London - railway tunnel')
  before_after_directly_from_database('krakow', 50.04052, 19.96857, 'master', 'master', 10..19, 400, 'Krakow - minor & major railways')
  before_after_directly_from_database('krakow', 50.04052, 19.96857, 'new-road-style', 'new-road-style', 10..19, 400, 'Krakow - minor & major railways')

  create_new_gis_database('new_gis')
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=33.32792&mlon=-112.08914#map=19/33.32792/-112.08914', 19..19, 'master', 'master', 'x3', 1, 10)
  switch_databases('something', 'new_gis')

  create_new_gis_database('new_gis')
  load_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/reykjavik_iceland.osm.pbf')
  switch_databases('reykjavik', 'new_gis')

  create_new_gis_database('new_gis')
  load_remote_file('https://s3.amazonaws.com/metro-extracts.mapzen.com/reykjavik_iceland.osm.pbf')
  switch_databases('reykjavik', 'new_gis')

  create_new_gis_database('new_gis')
  load_remote_file(url)
  switch_databases('german_forest', 'new_gis')

  edelta_run
  test_farmland('farmland')
  test_farmland('f1')
  test_farmland('f2')
  # test_farmland('f3')
  test_farmland('retry')
  test_farmland('filight')
  final

  from = 'master'
  zlevels = 13..19
  to = to1 = 'stepwidth'
  to2 = 'stepdash'
  to3 = 'stepdash_narrow'
  to4 = 'balanced_stepdash'
  stepspam = 'https://www.openstreetmap.org/#map=19/37.44651/24.94318'
  CartoCSSHelper.visualise_place_by_url(stepspam, zlevels, to1)
  # CartoCSSHelper.visualise_place_by_url(stepspam, zlevels, to2)
  # CartoCSSHelper.visualise_place_by_url(stepspam, zlevels, to3)
  # CartoCSSHelper.visualise_place_by_url(stepspam, zlevels, to4)
  # CartoCSSHelper.test_tag_on_real_data_for_this_type({'highway' => 'steps'}, to3, from, zlevels, 'way', 11, 0)
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'steps' }, to, from, zlevels, 'way', 21, 11)
  # CartoCSSHelper.test_tag_on_real_data_for_this_type({'highway' => 'steps'}, to2, from, zlevels, 'way', 11, 0)
  # CartoCSSHelper.test_tag_on_real_data_for_this_type({'highway' => 'steps'}, to4, from, zlevels, 'way', 11, 0)

  multicolider
  multicolider(false)
  # new shields
  # multicolider#(true)

  def test_pedestrian_pr(to, from, zlevels = 17..18, faster = false, fast = false)
    image_size = 350
    before_after_directly_from_database('vienna', 48.20826, 16.37358, to, from, zlevels, image_size, "Vienna - square around church in the cetrum #{from} -> #{to}")
    before_after_directly_from_database('rome', 41.90233, 12.45754, to, from, zlevels, image_size, "Vatican - square #{from} -> #{to}")
    before_after_directly_from_database('krakow', 50.06062, 19.9346, to, from, zlevels, image_size, "living street & pedestrian #{from} -> #{to}")
    CartoCSSHelper.visualise_place_by_url('/54.44675, /18.57930', zlevels, to, from, 'pedestrian near water')
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/255795002#map=19/50.30822/19.06292', zlevels, to, from, 'test_pedestrian_on_industrial (1) red')
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/157403305#map=18/41.6974955/44.81631', zlevels, to, from, 'conflict with landuse=residential - church collision_with_residential')

    return if faster

    before_after_directly_from_database('london', 51.50817, -0.12802, to, from, zlevels, image_size, "London - Trafalgar Square #{from} -> #{to}")
    before_after_directly_from_database('krakow', 50.06227, 19.94026, to, from, zlevels, image_size, 'Krakow')
    before_after_directly_from_database('vienna', 48.21070, 16.35932, to, from, zlevels, image_size, 'Vienna - big square')
    before_after_directly_from_database('vienna', 48.20458, 16.36103, to, from, zlevels, image_size, 'Vienna - fragmented square')
    before_after_directly_from_database('vienna', 48.21204, 16.37658, to, from, zlevels, image_size, 'Vienna - busy square')
    before_after_directly_from_database('vienna', 48.20826, 16.37358, to, from, zlevels, image_size, 'Vienna - square around church in the cetrum')
    before_after_directly_from_database('vienna', 48.23472, 16.41215, to, from, zlevels, image_size, 'Vienna - square next to UNO City (nearby residential)')
    before_after_directly_from_database('london', 51.50817, -0.12802, to, from, zlevels, image_size, 'London - Trafalgar Square')
    before_after_directly_from_database('london', 51.51320, -0.15145, to, from, zlevels, image_size, 'London - highway=pedestrian area near buildings (1)')
    before_after_directly_from_database('london', 51.49987, -0.16199, to, from, zlevels, image_size, 'London - highway=pedestrian area near buildings (2)')

    return if fast

    test_pedestrian_on_residential(zlevels, to, from)
    test_pedestrian_on_industrial(zlevels, to, from)

    CartoCSSHelper.probe({ 'highway' => 'pedestrian' }, to, from, zlevels, ['way'])
    CartoCSSHelper.probe({ 'highway' => 'living_street' }, to, from, zlevels, ['way'])

    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'living_street' }, to, from, zlevels, 'way', 3, 4)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'pedestrian' }, to, from, zlevels, 'way', 3, 4)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'living_street', 'area' => 'yes' }, to, from, zlevels, 'way', 1, 1)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'pedestrian', 'area' => 'yes' }, to, from, zlevels, 'way', 1, 1)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'living_street', 'bridge' => 'yes' }, to, from, zlevels, 'way', 1, 1)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'pedestrian', 'bridge' => 'yes' }, to, from, zlevels, 'way', 1, 1)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'living_street', 'tunnel' => 'yes' }, to, from, zlevels, 'way', 1, 1)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'pedestrian', 'tunnel' => 'yes' }, to, from, zlevels, 'way', 1, 1)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'path', 'area' => 'yes' }, to, from, zlevels, 'way', 1, 1)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'cycleway', 'area' => 'yes' }, to, from, zlevels, 'way', 1, 1)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'footway', 'area' => 'yes' }, to, from, zlevels, 'way', 1, 1)
  end

  def test_pedestrian_on_residential(zlevels, to, from)
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/157403305#map=18/41.54300/45.01203', zlevels, to, from, 'master', 'conflict with landuse=residential - Orchester')
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/206243424#map=19/41.70385/44.79016', zlevels, to, from, 'conflict with landuse=residential')
  end

  def test_pedestrian_on_industrial(zlevels, to, from)
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/255795002#map=19/50.30822/19.06292', zlevels, to, from, 'test_pedestrian_on_industrial (1)')
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/335561594#map=19/50.27200/18.77739', zlevels, to, from, 'test_pedestrian_on_industrial (2)')
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/182419154#map=19/50.32639/19.18370', zlevels, to, from, 'test_pedestrian_on_industrial (3)')
  end

  def test_8
    frozen_trunk = 'bcd2543'
    [8].each do |z|
      [frozen_trunk, '1', '0.9', '0.8'].each do |branch| # new-road-style
        image_size = 780
        image_size = 300 if z <= 6
        # get_single_image_from_database('world', branch, 50.8288, 4.3684, z, image_size, "Brussels #{branch}")
        # get_single_image_from_database('world', branch, -36.84870, 174.76135, z, image_size, "Auckland #{branch}")
        get_single_image_from_database('world', branch, 39.9530, -75.1858, z, image_size, "New Jersey #{branch}")
        # get_single_image_from_database('world', branch, 55.39276, 13.29790, z, image_size, "Malmo - fields #{branch}")
        get_single_image_from_database('world', branch, 50, 40, z, image_size, "interior #{branch}")
        get_single_image_from_database('world', branch, 50, 20, z, image_size, "Krakow #{branch}")
        get_single_image_from_database('world', branch, 50, 0, z, image_size, "London #{branch}")
        get_single_image_from_database('world', branch, 35.07851, 137.684848, z, image_size, "Japan #{branch}")
        get_single_image_from_database('world', branch, -12.924, -67.841, z, image_size, "South America #{branch}")
        get_single_image_from_database('world', branch, 16.820, 79.915, z, image_size, "India #{branch}")
        get_single_image_from_database('world', branch, 53.8656, -0.6659, z, image_size, "rural UK #{branch}")
        get_single_image_from_database('world', branch, 64.1173, -21.8688, z, image_size, "iceland #{branch}")
      end
    end
  end

  entries = []
  entries << { name: 'addis_abeba_ethiopia', lat: 9.01708, lon: 38.75242 }
  entries << { name: 'abidjan_ivory_coast', lat: 5.31886, lon: -4.01640 }
  entries << { name: 'abuja_nigeria', lat: 9.05271, lon: 7.49409 }
  entries << { name: 'accra_ghana', lat: 5.54767, lon: -0.21769 }
  entries.each do |entry|
    before_after_directly_from_database(entry[:name], entry[:lat], entry[:lon], 'trunk', master, 10..19, 325, entry[:name])
    before_after_directly_from_database('world', entry[:lat], entry[:lon], 'trunk', master, 5..9, 325, entry[:name])
  end
  final

  create_new_gis_database('new_gis')
  url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/abidjan_ivory-coast.osm.pbf'
  load_remote_file(url)
  switch_databases('abidjan_ivory_coast', 'new_gis')
  final

  # footwayify_pr('footwayify-show-surface', 'master')
  test_raceways('raceway', 'master', 12..30)

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=18/46.87061/13.53693', 12..18, 'test_forest', 'forest', 'German forest', 1)
  switch_databases('german_forest_protected_database', 'new_gis')

  large_scale_diff('test_forest', 'forest', 1000, 12..14)

  before_after_directly_from_database('krakow_protected_database', 50.06227, 19.94026, 'new-road-style', 'new-road-style', 6..22, 1000, 'Krakow')

  # https://github.com/gravitystorm/openstreetmap-carto/pull/1667#issuecomment-125508547
  CartoCSSHelper.probe({ 'amenity' => 'school' }, 'reorder_by_Holger_Jeronim', 'master')
  CartoCSSHelper.probe({ 'amenity' => 'hospital' }, 'reorder_by_Holger_Jeronim', 'master')

  # large_scale_diff('fix', 'master', 550, 13..13)
  # large_scale_diff('fix', 'master', 550, 4..20)

  # large_scale_diff('thin_residential_at_z12', 'master', 1000, 12..12)
  # large_scale_diff('thin_residential_at_z12', 'master', 550, 12..12)
  # large_scale_diff('unclassified_at_z11', 'master', 1000, 11..11)

  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'landuse' => 'residential' }, 'mismatch', 'master', 4..22, 'way', 4, 200)

  # code style improvement
  CartoCSSHelper.test_tag_on_real_data_for_this_type ({ 'oneway' => 'yes' }), 'variables', 'master', 4..20, ['way'], 1
  CartoCSSHelper.test_tag_on_real_data_for_this_type ({ 'oneway' => '-1' }), 'variables', 'master', 4..20, ['way'], 1
  CartoCSSHelper.test ({ 'highway' => 'motorway_junction' }), 'variables', 'master', 4..20, ['node']

  create_new_gis_database('new_gis')
  url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/nagoya_japan.osm.pbf'
  load_remote_file(url)
  switch_databases('nagoya_protected_database', 'new_gis')

  switch_databases('gis_test', 'london_protected_database')
  x('new-road-style', 51.50780, -0.12392)
  x('master', 51.50780, -0.12392)
  switch_databases('london_protected_database', 'gis_test')

  gsoc_places_unpaved('unpaved-light', 'master')
  gsoc_places_unpaved('unpaved-moderate', 'unpaved-light')
  gsoc_places_unpaved('unpaved-strong', 'unpaved-moderate')
  gsoc_places_unpaved('unpaved-ultra', 'unpaved-strong')

  additional_test_unpaved('unpaved-light', 'master')
  additional_test_unpaved('unpaved-moderate', 'unpaved-light')
  additional_test_unpaved('unpaved-strong', 'unpaved-moderate')
  additional_test_unpaved('unpaved-ultra', 'unpaved-strong')
  CartoCSSHelper::VisualDiff.run_jobs
  # CartoCSSHelper::VisualDiff.disable_job_pooling
  test_unpaved('unpaved-light', 'new-road-style')
  test_unpaved('unpaved-moderate', 'new-road-style')
  test_unpaved('unpaved-strong', 'new-road-style')
  test_unpaved('unpaved-ultra', 'new-road-style')
  test_unpaved('new-road-style')

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=15/41.1356/-73.9963', 14..14, 'z14rescas-to-0.6', 'gsoc', 'white on land', 0.4, 1000)
  large_scale_diff('z14rescas-to-0.6', 'gsoc', 1000, 14..14)

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=15/41.1356/-73.9963', 14..14, 'z14rescas', 'gsoc', 'white on land', 0.4, 1000)
  large_scale_diff('z14rescas', 'gsoc', 1000, 14..14)
  final

  before_after_from_loaded_databases({ 'highway' => 'motorway', 'access' => 'no' }, 'access', 'v2.33.0', 15..18, 375, 1, 0)
  before_after_from_loaded_databases({ 'highway' => 'steps', 'access' => 'no' }, 'access', 'v2.33.0', 15..18, 375, 1, 0)
  before_after_from_loaded_databases({ 'highway' => 'trunk', 'access' => 'no' }, 'access', 'v2.33.0', 15..18, 375, 1, 0)
  before_after_from_loaded_databases({ 'highway' => 'primary', 'access' => 'no' }, 'access', 'v2.33.0', 15..18, 375, 1, 0)
  before_after_from_loaded_databases({ 'highway' => 'service', 'access' => 'no' }, 'access', 'v2.33.0', 15..18, 375, 1, 0)
  before_after_from_loaded_databases({ 'highway' => 'service', 'service' => 'parking_aisle', 'access' => 'no' }, 'access', 'v2.33.0', 15..18, 375, 1, 0)
  final
  # before_after_from_loaded_databases({'man_made' => 'bridge', 'name' => :any_value}, 'bridge', 'master', 12..19, 375, 4, 0)

  [16..18].each do |zlevels| # 19..19, 15..15, 11..11,
    get_all_road_types.each do |tag|
      before_after_from_loaded_databases({ 'highway' => tag, 'oneway' => 'yes' }, 'gray-oneway', 'gsoc', zlevels, 375, 1, 1)
    end
  end

  [16..18].each do |zlevels| # 19..19, 15..15, 11..11,
    get_all_road_types.each do |tag|
      before_after_from_loaded_databases({ 'highway' => tag, 'oneway' => 'yes' }, 'pale-gray-oneway', 'gsoc', zlevels, 375, 1, 2)
    end
  end

  [15..18].each do |zlevels| # 19..19, 15..15, 11..11,
    get_all_road_types.each do |tag|
      before_after_from_loaded_databases({ 'highway' => tag, 'access' => 'private' }, 'access', master, zlevels, 375, 1, 0)
      before_after_from_loaded_databases({ 'highway' => tag, 'access' => 'no' }, 'access', master, zlevels, 375, 1, 1)
    end
  end

  [16..18].each do |zlevels| # 19..19, 15..15, 11..11,
    get_all_road_types.each do |tag|
      before_after_from_loaded_databases({ 'highway' => tag, 'oneway' => 'yes' }, 'gray-oneway', 'gsoc', zlevels, 375, 2, 1)
    end
  end

  [16..18].each do |zlevels| # 19..19, 15..15, 11..11,
    get_all_road_types.each do |tag|
      before_after_from_loaded_databases({ 'highway' => tag, 'oneway' => 'yes' }, 'pale-gray-oneway', 'gsoc', zlevels, 375, 1, 2)
    end
  end

  CartoCSSHelper.test_tag_on_real_data ({ 'highway' => 'motorway', 'access' => 'no' }), 'access', master, 10..16, ['way'], 3, 1

  zlevels = 15..20
  CartoCSSHelper.test_tag_on_real_data ({ 'highway' => 'motorway', 'access' => 'no' }), 'access', master, zlevels, ['way'], 1, 1
  CartoCSSHelper.test_tag_on_real_data ({ 'highway' => 'trunk', 'access' => 'no' }), 'access', master, zlevels, ['way'], 1
  # CartoCSSHelper.test_tag_on_real_data ({'highway' => 'motorway_link', 'access' => 'no'}), 'access', master, zlevels, ['way'], 1
  CartoCSSHelper.test_tag_on_real_data ({ 'highway' => 'trunk_link', 'access' => 'no' }), 'access', master, zlevels, ['way'], 1

  test_tag_on_real_data_pair_for_this_type({ 'natural' => 'bare_rock' }, { 'highway' => 'footway', 'surface' => :any_value }, 'dash', 'master', 13..19, 'way', 5, 93, 375)
  test_tag_on_real_data_pair_for_this_type({ 'natural' => 'bare_rock' }, { 'highway' => 'path', 'surface' => :any_value }, 'dash', 'master', 13..19, 'way', 2, 67, 375)
  before_after_from_loaded_databases({ 'highway' => 'cycleway' }, 'dash', 'master', 13..19, 375, 3, 1)
  before_after_from_loaded_databases({ 'highway' => 'path' }, 'dash', 'master', 13..19, 375, 3, 1)
  before_after_from_loaded_databases({ 'highway' => 'footway' }, 'dash', 'master', 13..19, 375, 3, 1)

  CartoCSSHelper.test_tag_on_real_data ({ 'highway' => 'secondary' }), 'glow', frozen_trunk, 9..10, ['way'], 8
  CartoCSSHelper.test_tag_on_real_data ({ 'highway' => 'tertiary' }), 'glow', frozen_trunk, 11..11, ['way'], 8

  final

  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=15/-24.4688/25.7925', 10..19, frozen_trunk, master, 'tertiary in Africa', 3)
  # test_tag_on_real_data_pair_for_this_type({'highway'=>'tertiary'}, {'highway' => 'unclassified'}, frozen_trunk, master, 10..19, 'way', 10, 6, 375)
  # final

  before_after_from_loaded_databases({ 'highway' => 'pedestrian', 'tunnel' => 'yes' }, frozen_trunk, frozen_trunk, 11..19, 375, 10)
  before_after_from_loaded_databases({ 'highway' => 'living_street', 'tunnel' => 'yes' }, frozen_trunk, frozen_trunk, 11..19, 375, 10)
  before_after_from_loaded_databases({ 'highway' => 'residential', 'tunnel' => 'yes' }, frozen_trunk, frozen_trunk, 11..19, 375, 10)
  edelta_run
  def show_dashes
    ['access', 'master'].each do |branch|
      [15, 18].each do |z|
        roads = road_set(true, true)
        roads.each do |tags|
          tags['access'] = 'private'
        end
        CartoCSSHelper::Grid.new(z, branch, roads, [], 'private')
        roads = road_set(true, true)
        CartoCSSHelper::Grid.new(z, branch, roads, [], 'normal')
        roads = road_set(true, true)
        roads.each do |tags|
          tags['access'] = 'destination'
        end
        CartoCSSHelper::Grid.new(z, branch, roads, [], 'destination')
      end
    end
  end

  def fucking_dashes
    to = 'dash'
    from = 'master'
    image_size = 1000
    zlevels = 13..19
    before_after_directly_from_database('rosenheim', 47.82989, 12.07764, to, from, zlevels, image_size, 'unpaved path through fields')
    before_after_directly_from_database('well_mapped_rocky_mountains', 47.56673, 12.32377, to, from, zlevels, image_size, 'footways on natural=bare_rock')
    before_after_directly_from_database('south_mountain', 33.32792, -112.08914, to, from, zlevels, image_size, 'footways on green')
    large_scale_diff('dash', 'master', 1000, 15..19)
    large_scale_diff('dash', 'master', 1000, 13..14)
  end

  # create_new_gis_database('new_gis')
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=51.5754&mlon=-2.7068#map=11/51.5754/-2.7068', 10..14, frozen_trunk, frozen_trunk, 'motorway_border_mess', 1, 1000)
  # switch_databases('motorway_border_mess', 'new_gis')
  # final
  CartoCSSHelper.test_tag_on_real_data ({ 'railway' => 'tram', 'service' => 'yard' }), 'tram-service', 'master', 12..19, ['way'], 10, 0
  CartoCSSHelper.test ({ 'railway' => 'tram', 'service' => 'yard' }), 'tram-service', 'master'

  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'service' }, 'way', false, z, 'gsoc', 'c9af9f7')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'road' }, 'way', false, z, 'gsoc', 'c9af9f7')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'service', 'service' => 'parking_aisle' }, 'way', false, z, 'gsoc', 'c9af9f7')

  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'service', 'access' => 'private' }, 'way', false, z, 'gsoc', 'c9af9f7')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'road', 'access' => 'private' }, 'way', false, z, 'gsoc', 'c9af9f7')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'service', 'service' => 'parking_aisle', 'access' => 'private' }, 'way', false, z, 'gsoc', 'c9af9f7')

  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'service', 'access' => 'destination' }, 'way', false, z, 'gsoc', 'c9af9f7')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'road', 'access' => 'destination' }, 'way', false, z, 'gsoc', 'c9af9f7')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'service', 'service' => 'parking_aisle', 'access' => 'destination' }, 'way', false, z, 'gsoc', 'c9af9f7')
  final

  CartoCSSHelper.probe ({ 'railway' => 'rail' }), 'sql-rail', 'master'
  CartoCSSHelper.probe ({ 'railway' => 'rail', 'service' => 'spur' }), 'sql-rail', 'master'
  generate_preview(['master', 'new-road-style', 'colours', 'legacy2'])
  (4..19).each do |zlevel|
    CartoCSSHelper::Grid.new(zlevel, 'master', road_set(true, true), [])
  end
  (4..19).each do |zlevel|
    CartoCSSHelper::Grid.new(zlevel, 'new-road-style', road_set(true, true), [])
  end

  gsoc_places_town_large_bb('new-road-style', 'master', 10..12, 0.04, 350)
  gsoc_places_town_large_bb('also-un', 'master', 10..12, 0.04, 350)

  gsoc_places_town_large_bb('hide-residential', 'new-road-style', 10..12, 0.04, 350)
  gsoc_places_town_large_bb('also-un', 'new-road-style', 10..10, 0.04, 350)

  # gsoc_places('narrow', 'new-road-style', 14..14)

  gsoc_places_town('narrow-subtle', 'new-road-style', 14..14)
end

def testz12buildings
  CartoCSSHelper::VisualDiff.enable_job_pooling
  zlevels = 12..12
  ['no_b_12', 'no_b_pow_12'].each do |branch| # 0.2, 0.5, 1, 2, 5 - not aggressive enough, exception for major buildings is pointless, it is necessary to deal also with PoW
    # always handle also PoW

    # also, this PR achieved new record in ratio of effort to changed code
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/49.26214/-123.24533', zlevels, branch, 'new-road-style', 'UBC', 0.2)
    CartoCSSHelper.test_tag_on_real_data_for_this_type ({ 'building' => 'yes' }), branch, 'new-road-style', zlevels, 'closed_way', 5, 12
    CartoCSSHelper.test_tag_on_real_data_for_this_type ({ 'amenity' => 'place_of_worship' }), branch, 'new-road-style', zlevels, 'closed_way', 5, 0
  end
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/49.26214/-123.24533', zlevels, 'new-road-style', 'master', 'UBC', 0.2)
  CartoCSSHelper.test_tag_on_real_data_for_this_type ({ 'building' => 'yes' }), 'new-road-style', 'master', zlevels, 'closed_way', 5, 12
  CartoCSSHelper.test_tag_on_real_data_for_this_type ({ 'amenity' => 'place_of_worship' }), 'new-road-style', 'new-road-style', zlevels, 'closed_way', 5, 0
  CartoCSSHelper::VisualDiff.run_jobs
end

def validator_run
  CartoCSSHelper::Validator.run_tests('v2.31.0')
end

def test_junction_labels(to, from = 'master', zlevels = 11..19)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.08708/19.80613', zlevels, to, from, 'Węzeł Balicki', 0.5)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/node/26804505#map=16/55.5672/12.9951', zlevels, to, from, 'Malmo - secondary', 0.5)
end

def load_remote_file_and_quit(url)
  load_remote_file(url)
  final
end

def test_cross_pr
  to = 'cross'
  urls = [
    # Saarland
    'http://www.openstreetmap.org/relation/62372#map=10/49.4913/6.4778',
    'http://www.openstreetmap.org/relation/62372#map=10/49.4931/6.7168',
    'http://www.openstreetmap.org/relation/62372#map=10/49.5252/6.9777',
    'http://www.openstreetmap.org/relation/62372#map=10/49.4788/7.1658',
    'http://www.openstreetmap.org/relation/62372#map=10/49.3681/7.1796',
    'http://www.openstreetmap.org/relation/62372#map=10/49.3045/7.2551',
    'http://www.openstreetmap.org/relation/62372#map=10/49.2302/7.1782',
    'http://www.openstreetmap.org/relation/62372#map=10/49.2669/7.0340',
    'http://www.openstreetmap.org/relation/62372#map=10/49.3108/6.9008',
  ]
  urls.each do |url|
    latitude, longitude = CartoCSSHelper.get_latitude_longitude_from_url(url)
    CartoCSSHelper::VisualDiff.visualise_on_overpass_data({ 'historic' => 'wayside_cross' }, 'node', latitude, longitude, 10..19, to, 'master')
    CartoCSSHelper::VisualDiff.visualise_on_overpass_data({ 'man_made' => 'cross' }, 'node', latitude, longitude, 10..19, to, 'master')
  end
  megatest({ 'historic' => 'wayside_cross' }, to, 14..19, ['node'])
  megatest({ 'man_made' => 'cross' }, to, 14..19, ['node'])
end

def test_tram(zlevels = 8..19)
  krakow_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/krakow_poland.osm.pbf'
  CartoCSSHelper.visualise_place_by_remote_file(krakow_url, 50.06864, 19.94569, zlevels, 'tram', 'origin/master', 'tram infestation - Kraków', 1, 450)

  prague_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/prague_czech-republic.osm.pbf'
  CartoCSSHelper.visualise_place_by_remote_file(prague_url, 50.0853, 14.4320, zlevels, 'tram', 'origin/master', 'tram infestation - Prague', 1, 450)

  helsinki_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/helsinki_finland.osm.pbf'
  CartoCSSHelper.visualise_place_by_remote_file(helsinki_url, 60.16827, 24.93188, zlevels, 'tram', 'origin/master', 'tram infestation - Helsinki', 1, 450)

  vienna_url = 'https://s3.amazonaws.com/metro-extracts.mapzen.com/vienna-bratislava_austria.osm.pbf'
  CartoCSSHelper.visualise_place_by_remote_file(vienna_url, 48.20860, 16.36801, zlevels, 'tram', 'origin/master', 'tram infestation - Vienna', 1, 450)
end

def test_bridges(to = 'bridge', z = 13..18)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/51.54048/-0.14786', z, to, 'master', 'Oval Road', 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=18/50.08637/19.95572', z, to, 'master', 'mostN', 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.04552/19.94522', z, to, 'master', 'mostS', 0.1)

  megatest({ 'man_made' => 'bridge' }, to, z, ['closed_way'])
  megatest({ 'man_made' => 'bridge', 'building' => 'bridge' }, to, z, ['closed_way'])
  megatest({ 'building' => 'bridge' }, to, z, ['closed_way'])
end

def test_bridge_pr
  to = 'bridge'

  # CartoCSSHelper.test_tag_on_real_data_for_this_type ({'man_made' => 'bridge', 'building' => 'bridge'}), to, 'master', 13..18, 'closed_way', 5
  # CartoCSSHelper.test_tag_on_real_data_for_this_type ({'building' => 'bridge'}), to, 'master', 13..18, 'closed_way', 5

  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/199258374#map=19/45.43813/12.33612', z, to, 'master', 'bridge with building on it - Rialto', 0.5)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/43.76814/11.25337', z, to, 'master', 'bridge with building on it - Veccino', 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/51.54048/-0.14786', z, to, 'master', 'Oval Road', 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=18/50.08637/19.95572', z, to, 'master', 'mostN', 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.04552/19.94522', z, to, 'master', 'mostS', 0.1)

  # test_bridges(to)
end

def test_uni_pr
  CartoCSSHelper::VisualDiff.enable_job_pooling
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/49.26214/-123.24533', 10..13, 'edu', 'master', 'UBC', 0.2)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=17/49.26214/-123.24533', 10..13, 'new-road-style-edu', 'new-road-style', 'UBC', 0.2)
  CartoCSSHelper::VisualDiff.run_jobs

  CartoCSSHelper.test ({ 'amenity' => 'university' }), 'edu', 'master', 10..13, ['closed_way']
  CartoCSSHelper.test ({ 'amenity' => 'university' }), 'new-road-style-edu', 'new-road-style', 10..13, ['closed_way']
end

def old
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'living_street' }, 'closed_way', false, 16..16, 'new-road-style', 'new-road-style')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'highway' => 'living_street', 'area' => 'yes' }, 'closed_way', false, 16..16, 'new-road-style', 'new-road-style')
  to = from = branch = 'new-road-style-z16' # 'wat'

  bridge = { 'highway' => 'trunk', 'bridge' => 'yes' }
  CartoCSSHelper.probe bridge, to, from, 12..12, ['way']
  CartoCSSHelper.probe({ 'highway' => 'trunk' }, to, from, 12..12, ['way'])
  CartoCSSHelper.probe bridge, to, from, 13..13, ['way']
  CartoCSSHelper.probe({ 'highway' => 'trunk' }, to, from, 13..13, ['way'])

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.10045/19.83039', 12..12, branch, branch, 'emergency testing', 0.1)
  final
  to = 'cross'
  megatest({ 'historic' => 'wayside_cross' }, to, 14..19, ['node'])
  megatest({ 'man_made' => 'cross' }, to, 14..19, ['node'])

  VisualDiff.run_jobs

  megatest({ 'tourism' => 'zoo' }, 'zoo', 10..16, ['closed_way'])
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/51.53569/-0.15551', 10..13, 'zoo', 'master', 'zoo - London', 0.5)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/50.05341/19.85036', 10..13, 'zoo', 'master', 'zoo - Wolski', 0.5)

  VisualDiff.run_jobs
  final

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/#map=19/55.78718/37.64938', 10..13, 'minor', 'master', 'Moscow - minor rail', 0.5)
  test_linear_tag_set({ 'railway' => 'rail', 'service' => 'yard' }, 'minor', 10..13)
  test_linear_tag_set({ 'railway' => 'rail', 'service' => 'siding' }, 'minor', 10..13)
  test_linear_tag_set({ 'railway' => 'rail', 'service' => 'spur' }, 'minor', 10..13)
end

def test_blob_eliminator_pr
  # large_scale_diff('blob_eliminator', 'master', 550)
  large_scale_diff('unclassified_at_z11', 'master', 550, 11..11)
  # large_scale_diff('residential_0.5', 'blob_eliminator', 550)
  # large_scale_diff('residential_0.6', 'blob_eliminator', 550)
  # large_scale_diff('residential_0.4', 'blob_eliminator', 550)
end

def old_check_delta
  check_color('#f7ecdf', 'naive')
  check_color('#e8ded1', 'lch(89, 8, 82) f1') #####
  check_color('#e7dfd0', 'lch(89, 8, 87) f2') #####
  # check_color('#ebddd1', 'lch(89, 8, 70) f3') ####
  return

  check_color('#edddc9', 'lch(89, 12, 80)')
  check_color('#e9ded1', 'lch(89, 8, 80)')
  check_color('#e8ded0', 'lch(89, 8, 84)')

  check_color('#eaded1', 'lch(89, 8, 76)')
  return

  check_new_color(13, 236, 222, 187, 'farmland lch(89.0, 19.0, 87.0) = #ecdebb[verify conversion]')
  check_new_color(13, 238, 221, 188, 'farmland lch(89.0, 19.0, 84.0) = #eeddbc[verify conversion]')
  check_new_color(13, 240, 221, 188, 'farmland lch(89.0, 19.0, 81.0) = #f0ddbc[verify conversion]')
  check_new_color(13, 242, 220, 188, 'farmland lch(89.0, 19.0, 78.0) = #f2dcbc[verify conversion]')
  check_new_color(13, 243, 220, 189, 'farmland lch(89.0, 19.0, 75.0) = #f3dcbd[verify conversion]')
  check_new_color(13, 235, 222, 193, 'farmland lch(89.0, 16.0, 87.0) = #ebdec1[verify conversion]')
  check_new_color(13, 236, 222, 193, 'farmland lch(89.0, 16.0, 84.0) = #ecdec1[verify conversion]')
  check_new_color(13, 238, 221, 193, 'farmland lch(89.0, 16.0, 81.0) = #eeddc1[verify conversion]')
  check_new_color(13, 239, 221, 194, 'farmland lch(89.0, 16.0, 78.0) = #efddc2[verify conversion]')
  check_new_color(13, 240, 220, 194, 'farmland lch(89.0, 16.0, 75.0) = #f0dcc2[verify conversion]')
  check_new_color(13, 233, 223, 199, 'farmland lch(89.0, 13.0, 87.0) = #e9dfc7[verify conversion]')
  check_new_color(13, 234, 222, 199, 'farmland lch(89.0, 13.0, 84.0) = #eadec7[verify conversion]')
  check_new_color(13, 235, 222, 199, 'farmland lch(89.0, 13.0, 81.0) = #ebdec7[verify conversion]')
  check_new_color(13, 236, 221, 199, 'farmland lch(89.0, 13.0, 78.0) = #ecddc7[verify conversion]')
  check_new_color(13, 237, 221, 200, 'farmland lch(89.0, 13.0, 75.0) = #edddc8[verify conversion]')
  check_new_color(13, 231, 223, 204, 'farmland lch(89.0, 10.0, 87.0) = #e7dfcc[verify conversion]')
  check_new_color(13, 232, 222, 205, 'farmland lch(89.0, 10.0, 84.0) = #e8decd[verify conversion]')
  check_new_color(13, 233, 222, 205, 'farmland lch(89.0, 10.0, 81.0) = #e9decd[verify conversion]')
  check_new_color(13, 234, 222, 205, 'farmland lch(89.0, 10.0, 78.0) = #eadecd[verify conversion]')
  check_new_color(13, 234, 221, 205, 'farmland lch(89.0, 10.0, 75.0) = #eaddcd[verify conversion]')
  check_new_color(13, 229, 223, 210, 'farmland lch(89.0, 7.0, 87.0) = #e5dfd2[verify conversion]')
  check_new_color(13, 229, 223, 210, 'farmland lch(89.0, 7.0, 84.0) = #e5dfd2[verify conversion]')
  check_new_color(13, 230, 223, 210, 'farmland lch(89.0, 7.0, 81.0) = #e6dfd2[verify conversion]')
  check_new_color(13, 231, 222, 211, 'farmland lch(89.0, 7.0, 78.0) = #e7ded3[verify conversion]')
  check_new_color(13, 231, 222, 211, 'farmland lch(89.0, 7.0, 75.0) = #e7ded3[verify conversion]')

  zlevel = Configuration.get_max_z
  zlevel = 10
  generate_images_about_neighbours(areas, zlevel)

  generate_image_of_close_landcovers(areas, zlevel)
  zlevel = 10
  generate_image_of_close_landcovers(areas, zlevel)

  on_water = false
  zlevel = Configuration.get_max_z
  search_for_missing_areas(areas, zlevel, on_water)
  zlevel = 10
  search_for_missing_areas(areas, zlevel, on_water)

  # areas.push({'landuse' => 'meadow'})
  # areas.push({'landuse' => 'orchard'})
  areas.push({ 'landuse' => 'vineyard' })
  # areas.push({'landuse' => 'village_green'})
  # areas.push({'landuse' => 'grass'})
  areas.push({ 'landuse' => 'forest' })
  areas.push({ 'natural' => 'scrub' })
  areas.push({ 'natural' => 'scree' })
  areas.push({ 'leisure' => 'golf_course' })

  [16, 20].each do |zlevel| # 10, 13
    generate_image_of_close_landcovers(branch, areas, zlevel)
    generate_image_of_close_landcovers(branch, areas_set, zlevel)
    # generate_image_of_close_landcovers('old_new_forest', areas, zlevel)
    # generate_image_of_close_landcovers('no_scrub', areas, zlevel)
    # generate_image_of_close_landcovers('older_master_but_after_last_landcover_change', areas, zlevel)
  end

  return

  areas = areas_set
  [13, 20, 10].each do |zlevel|
    generate_image_of_close_landcovers('old_new_forest', areas, zlevel)
    generate_image_of_close_landcovers('no_scrub', areas, zlevel)
    generate_image_of_close_landcovers('older_master_but_after_last_landcover_change', areas, zlevel)
  end
end

# CartoCSSHelper.test_tag_on_real_data_for_this_type({'landuse' => 'quarry'}, 'kocio/quarry-icon', 'master', 10..17, 'way', 10)
# https://github.com/gravitystorm/openstreetmap-carto/pull/1633
# CartoCSSHelper.test_tag_on_real_data_for_this_type ({'man_made' => 'bridge'}), 'bridge', 'master', 12..18, 'closed_way', 10, 10
# test_power_pr
def test_power_pr
  branch = 'power'
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=51.5746&mlon=13.7358#map=18/51.56971/13.74168', 10..18, branch, 'master', 'solar farm', 0.1)
  # CartoCSSHelper.test_tag_on_real_data ({'power' => 'plant'}), branch, 'master', 10..18, ['closed_way'], 3 - not rendered specially in @power
  CartoCSSHelper.test_tag_on_real_data ({ 'power' => 'station' }), branch, 'master', 10..18, ['closed_way'], 3
  CartoCSSHelper.test_tag_on_real_data ({ 'power' => 'generator' }), branch, 'master', 10..18, ['closed_way'], 3
  CartoCSSHelper.test_tag_on_real_data ({ 'power' => 'sub_station' }), branch, 'master', 10..18, ['closed_way'], 3
  CartoCSSHelper.test_tag_on_real_data ({ 'power' => 'substation' }), branch, 'master', 10..18, ['closed_way'], 3
end

def test_raceways(to, from, zlevels = 12..17)
  # raceways: bridges & tunnels are missing
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'raceway' }, to, from, zlevels, 'way', 50, 15)
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'raceway', 'tunnel' => 'yes' }, to, from, zlevels, 'way', 5)
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'raceway', 'bridge' => 'yes' }, to, from, zlevels, 'way', 5)
  test_road_type to, 'raceway'
  CartoCSSHelper::VisualDiff.run_jobs
end

def a
  before_after_directly_from_database('vineyards', 48.08499, 7.64856, 'track', 'v2.35.0', 13..14, 1000)
  zlevels = 4..8
  size = 1000
  from = 'citylabel' # 'v2.34.0'
  to = 'sommerluk/lowzoomcities10'
  # before_after_directly_from_database('world', 50, 20, to, 'v2.34.0', 6..6, 1000, 'sommerluk/lowzoomcities10 [50,20]')
  # before_after_directly_from_database('world', 40.7302, -73.9867, to, 'master', zlevels, 150, 'sommerluk/lowzoomcities10 New York')
  before_after_directly_from_database('world', 50, 20, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [50,20]')
  before_after_directly_from_database('world', 50, 40, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [50,40]')
  before_after_directly_from_database('world', 40, -75, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [40,-75]')
  before_after_directly_from_database('world', -26, 135, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [-26,135]')
  before_after_directly_from_database('world', 16, 77, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [16,77]')
  before_after_directly_from_database('world', 1, 103, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [1,103]')
  before_after_directly_from_database('world', 0, 20, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [0,20]')
  before_after_directly_from_database('world', 36, 140, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [36,140] Japan')
  before_after_directly_from_database('world', 36, 112, to, from, zlevels, size, 'sommerluk/lowzoomcities10 [36,112] China')
  # PR ready
  # before_after_from_loaded_databases({'name' => :any_value, 'shop' => 'bakery'}, 'shop', 'master', 13..19)
  # before_after_from_loaded_databases({'name' => :any_value, 'shop' => 'supermarket'}, 'shop', 'master', 13..19)

  # PR
  # before_after_from_loaded_databases({'name' => :any_value, 'man_made' => 'lighthouse'}, '710_returns', 'v2.34.0', 15..19)
  # before_after_from_loaded_databases({'name' => :any_value, 'amenity' => 'hospital'}, '710_returns', 'v2.34.0', 15..19)
  # before_after_from_loaded_databases({'name' => :any_value, 'tourism' => 'attraction'}, '710_returns', 'v2.34.0', 16..19, 375, 3, 3)
end
