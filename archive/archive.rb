# frozen_string_literal: true

def missing_labels(branch='v2.31.0', old_branch='v2.30.0')
  # missing name - see https://github.com/gravitystorm/openstreetmap-carto/issues/1797
  tags = [
    { 'natural' => 'peak', 'ele' => '4' }, 
    { 'natural' => 'volcano', 'ele' => '4' }, 
    { 'natural' => 'saddle', 'ele' => '4' }, 
    { 'tourism' => 'alpine_hut', 'ele' => '4' }, 
    { 'aeroway' => 'gate', 'ref' => '4' },
  ]
  tags.each do |tag|
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test(tag, 'node', false, 22..22, branch, old_branch) # 20, 27, 29, 30 - 31 34
  end
  tags.each do |tag|
    CartoCSSHelper.probe(tag, branch, old_branch)
  end
end

def test_kocio_parking_pr
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'parking' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: 'kocio/parking-size', from: 'master', zlevels: 16..18, image_size: 375, count: 10)
end


def test_low
  lat = 51.01155
  lon = 14.93786 # Poland
  get_single_image_from_database('entire_world', 'faster_z3', lat, lon, 3, 140)
  get_single_image_from_database('entire_world', 'master', lat, lon, 3, 140)
end

def all_roads
  get_all_road_types.each do |tag|
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'highway' => tag, }, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'pnorman/road_reformat', from: 'v2.38.0', zlevels: 10..19, image_size: 375, count: 1)
  end
end

def bus_guideway_in_tunnel(branch)
  tags = {'highway' => 'bus_guideway', 'tunnel' => 'yes'}
  CartoCSSHelper.probe(tags, 'show_guideway_tunnel', 'master', 22..22, ['way'])
  tags = {'highway' => 'bus_guideway'}
  CartoCSSHelper.probe(tags, 'show_guideway_tunnel', 'master', 22..22, ['way'])
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tags, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 14..19, image_size: 375, count: 10)
end

def barrier_names(branch, n)
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'wall', 'name' => :any_value }, types: ['way'])
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 19..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'wall', 'name' => :any_value }, types: ['way'])
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  barriers = ['city_wall', 'chain', 'embankment', 'ditch', 'fence', 'guard_rail', 'handrail', 'hedge', 'kerb', 'retaining_wall', 'wall']
  skip = 0
  barriers.each do |barrier|
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'barrier' => barrier }, skip: skip)
    diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)
    skip += 1
  end

  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value, 'landuse' => 'cemetery' }, branch, 'master', 19..19)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, branch, 'master', 19..19)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, branch, 'master', 8..8)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, branch, 'master')
  CartoCSSHelper.test({ 'barrier' => 'wall', 'name' => :any_value }, branch, 'master')

  [branch].each do |branch|
    CartoCSSHelper.probe({ 'tourism' => 'attraction' }, branch, 'master')
    CartoCSSHelper.probe({ 'waterway' => 'dam' }, branch, 'master')
    CartoCSSHelper.probe({ 'waterway' => 'weir' }, branch, 'master')
    CartoCSSHelper.probe({ 'natural' => 'cliff' }, branch, 'master')
    CartoCSSHelper.probe({ 'natural' => 'hedge' }, branch, 'master')
    CartoCSSHelper.probe({ 'barrier' => 'aajaiaa' }, branch, 'master')
    CartoCSSHelper.probe({ 'tourism' => 'attraction' }, branch, 'master')
  end

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'barrier_way', 'master', branch, 0.1)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 15..22, 'barrier_way', 'master', branch, 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'tourism_way', 'master', 'tourism_way', 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 13..22, 'tourism_way', 'master', 'tourism_way', 0.1)
end

def obelisk(branch)
  #https://github.com/gravitystorm/openstreetmap-carto/issues/2126

  CartoCSSHelper.probe({ 'historic' => 'monument' }, branch, 'master')
  CartoCSSHelper.probe({ 'man_made' => 'obelisk' }, branch, 'master')

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'man_made' => 'obelisk' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 14..19, image_size: 375, count: 10)
end

def test_low_dot
  locator = CartoCSSHelper::RecordLocation.new(51.37245, -0.45807)
  diff_on_loaded_database(location_provider: locator, to: 'lowdot', from: 'master', zlevels: 16..19, image_size: 575, count: 1)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'shop' => :any_value }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: 'lowdot', from: 'master', zlevels: 16..19, image_size: 575, count: 10)
end

def test_turning_circle(branch, count, zlevels, location_finder_mode = false)
  # https://github.com/gravitystorm/openstreetmap-carto/issues/1931
  tags_a = { 'highway' => 'turning_circle' }
  tags = [
    { tags: { 'highway' => 'residential' }, skip: 0 },
    { tags: { 'highway' => 'living_street' }, skip: 0 },
    { tags: { 'highway' => 'service' }, skip: 2 },
    { tags: { 'highway' => 'service', 'service' => 'driveway' }, skip: 2 },
    { tags: { 'highway' => 'service', 'service' => 'parking_aisle' }, skip: 0 },
    { tags: { 'highway' => 'tertiary' }, skip: 0 }, # minor service on 0
  ]

  tags.each do |set|
    tags_b = set[:tags]
    puts tags_b
    locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new(tags_a, tags_b, 'node', 'way', skip: set[:skip], distance_in_meters: 0)
    if location_finder_mode
      next if tags_b == { 'highway' => 'residential' }
      next if tags_b == { 'highway' => 'living_street' }
    end
    diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: zlevels, image_size: 375, count: count)
  end
end

def buildinglessz12
    puts "bbb"
    before_after_directly_from_database('entire_world', 50, 20, 'master', 'master', 12..12, 1534, "description")
    puts

    puts "aaaa"
    before_after_directly_from_database('entire_world', 50, 20, 'buildingless_z12', 'buildingless_z12', 12..12, 1534, "description")
    puts

    puts "cccc"
    before_after_directly_from_database('entire_world', 50, 20, 'buildingless_z12', 'master', 11..13, 661, "description")
    puts
end

def test_eternal_710_on_real_data(branch)
  #tourism_theme_park tourism_zoo are special
  werebold_710.each do |tag|
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tag.merge({ 'name' => :any_value }), skip: 0)
    diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..18, image_size: 700, count: 1)
  end
  tags_for_710.each do |tag|
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tag.merge({ 'name' => :any_value }), skip: 0)
    diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..18, image_size: 700, count: 1)
  end
end

def test_eternal_710_dy(branch)
  tags_for_710.each do |tag|
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test(tag.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}), 'node', false, 22..22, branch, branch)
  end
end

def werebold_710
  [
    { 'amenity' => 'pub' },
    { 'amenity' => 'restaurant'},
    { 'amenity' => 'food_court'},
    { 'amenity' => 'cafe'},
    { 'amenity' => 'fast_food'},
    { 'amenity' => 'biergarten'},
    { 'amenity' => 'bar'},
    { 'amenity' => 'ice_cream'},
    { 'amenity' => 'nightclub'},
    { 'amenity' => 'library'},
    { 'tourism' => 'museum'},
    { 'amenity' => 'theatre'},
    { 'amenity' => 'courthouse'},
    { 'amenity' => 'townhall'},
    { 'amenity' => 'cinema'},
 ]
end

def tags_for_710 ()
  [
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
end

def test_power(branch, n)
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'power' => 'tower' }, types: ['node'])
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 13..19, image_size: 1000, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'power' => 'pole' }, types: ['node'])
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 1000, count: n)

  n = 1

  branch = 'master'
  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new({ 'power' => 'tower' }, { 'natural' => 'bare_rock' }, 'node', 'way', 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new({ 'power' => 'tower' }, { 'natural' => 'wetland' }, 'node', 'way', 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new({ 'power' => 'tower' }, { 'landuse' => 'cemetery' }, 'node', 'way', 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new({ 'power' => 'pole' }, { 'natural' => 'bare_rock' }, 'node', 'way', 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new({ 'power' => 'pole' }, { 'natural' => 'wetland' }, 'node', 'way', 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new({ 'power' => 'pole' }, { 'landuse' => 'cemetery' }, 'node', 'way', 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: 6)
end

def test_rail
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'railway' => 'rail' }, types: ['way'])
  diff_on_loaded_database(location_provider: locator, to: 'rail', from: 'master', zlevels: 12..19, image_size: 1000, count: 12)
end

# alive PRs above
#=============

def test_library_book_shop_prs
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'shop' => 'books', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'node', false, 22..22, 'also_shop', 'master')
  n = 6
  skip = 3
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'shop' => 'books' }, skip: skip)
  diff_on_loaded_database(location_provider: locator, to: 'also_shop', from: 'master', zlevels: 16..19, image_size: 375, count: n)
end

def show_road_grid
  # TODO: code is broken, requires updates
  (5..19).each do |zlevel|
    CartoCSSHelper::Grid.new(zlevel, branch, road_set(true, true), areas_set)
  end
end

def test_fishmonger
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'shop' => 'fishmonger', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'node', false, 22..22, 'fishmonger', 'master')
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'shop' => 'seafood', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'node', false, 22..22, 'fishmonger', 'master')
  before_after_from_loaded_databases({ 'shop' => 'fishmonger' }, 'fishmonger', 'master', 17..18, 300, 1, 8)
  # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'shop' => 'seafood', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}, 'node', false, 22..22, 'drop-fishmonger', 'master')
  # before_after_from_loaded_databases({'shop' => 'seafood'}, 'drop-fishmonger', 'master', 17..18, 300, 2, 8)

  # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'shop' => 'fishmonger', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}, 'node', false, 22..22, 'fishmonger', 'master')

  # before_after_from_loaded_databases({'shop' => 'fishmonger'}, 'fishmonger', 'master', 17..18, 300, 2, 8)
end

def test_forest
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'valley', 'landuse' => 'forest' }, 'closed_way', false, 22..22, 'forest', 'master')

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'natural' => :any_value, 'landuse' => 'forest' })
  diff_on_loaded_database(location_provider: locator, to: 'forest', from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocateTags.new({ 'natural' => :any_value, 'landuse' => 'forest' })
  diff_on_loaded_database(location_provider: locator, to: 'forest', from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'natural' => 'wood' })
  diff_on_loaded_database(location_provider: locator, to: 'forest', from: 'master', zlevels: 15..19, image_size: 375, count: 6)
end

def test_xml_low
  branch = 'xml_low'
  count = 10
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'parking' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'bicycle_parking' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'motorcycle_parking' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'bench' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'waste_basket' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  count = 1
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'railway' => 'crossing' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'man_made' => 'cross' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'historic' => 'wayside_cross' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'highway' => 'mini_roundabout' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'bollard' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'gate' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'lift_gate' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'swing_gate' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'block' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)
end

def debris
  get_all_road_types.each do |highway|
    puts highway
    before_after_from_loaded_databases({ 'highway' => highway, 'ref' => :any_value }, 'nebulon/road-shields', 'master', 13..22, 1000, 5)
  end
end


