# frozen_string_literal: true

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

def debris
  get_all_road_types.each do |highway|
    puts highway
    before_after_from_loaded_databases({ 'highway' => highway, 'ref' => :any_value }, 'nebulon/road-shields', 'master', 13..22, 1000, 5)
  end
end
