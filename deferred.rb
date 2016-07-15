# frozen_string_literal: true
=begin
http://wiki.openstreetmap.org/wiki/Tag%3Alanduse%3Ddepot - update
http://overpass-turbo.eu/s/aJA access=public eliminator
    #http://overpass-turbo.eu/s/aJm - reduce impact before rendering proposal
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'public'}, 'public', 'master', 13..19, 'way', 2)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'private'}, 'public', 'master', 13..19, 'way', 2)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'yes'}, 'public', 'master', 13..19, 'way', 2)
=end

# http://codereview.stackexchange.com/questions/tagged/ruby?page=2&sort=votes&pagesize=15

def show_military_danger_areas(branch)
  # czarnobyl - www.openstreetmap.org/?mlat=51.5&mlon=30.1&zoom=12#map=12/51.5000/30.1000 (lat =-0.5, lon+-0.7)
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'military' => 'danger_area' }, types: ['way'])
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 9..19, image_size: 375, count: 10)

  # locator = CartoCSSHelper::LocateTags.new({ 'military' => 'danger_area' }, types: ['way'])
  # diff_on_overpass_data(location_provider: locator, to: 'master', from: 'master', zlevels: 9..19, image_size: 375, count: 10)
end

def test_alpine_hut(branch = 'master', before_branch='master')
  # https://github.com/gravitystorm/openstreetmap-carto/issues/2115
  hut = { 'tourism' => 'alpine_hut', 'name' => :any_value }
  zlevels = 9..19
  count = 5
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(hut)
  diff_on_loaded_database(location_provider: locator, to: branch, from: before_branch, zlevels: zlevels, image_size: 375, count: count)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new(hut, { 'natural' => 'peak' }, 'way', 'node', skip: 0, distance_in_meters: 1000)
  diff_on_loaded_database(location_provider: locator, to: branch, from: before_branch, zlevels: zlevels, image_size: 375, count: count)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new(hut, hut, 'way', 'way', skip: 0, distance_in_meters: 1000)
  diff_on_loaded_database(location_provider: locator, to: branch, from: before_branch, zlevels: zlevels, image_size: 375, count: count)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new(hut, { 'natural' => 'volcano' }, 'way', 'node', skip: 0, distance_in_meters: 1000)
  diff_on_loaded_database(location_provider: locator, to: branch, from: before_branch, zlevels: zlevels, image_size: 375, count: count)
  # find alpine hut nearby alpine hut
end

def subway_service
  # write code
  # http://www.openstreetmap.org/way/129520909#map=19/41.83566/12.57786
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'railway' => 'subway', 'service' => :any_value })
  diff_on_loaded_database(location_provider: locator, to: 'master', from: 'master', zlevels: 15..19, image_size: 375, count: 10)

  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'railway' => 'subway', 'service' => 'yard' }, 'way', false, 22..22, 'master', 'master')
  CartoCSSHelper::VisualDiff.visualise_on_synthethic_data({ 'railway' => 'subway' }, 'way', false, 22..22, 'master', 'master')
end

def railway_station_areas_label(branch)
  # https://github.com/gravitystorm/openstreetmap-carto/issues/2097
  tags = { 'railway' => 'station' }
  CartoCSSHelper.probe(tags, branch, 'master', 22..22, ['closed_way'])
  CartoCSSHelper.probe(tags, branch, 'master', 12..22, ['closed_way'])
  CartoCSSHelper.probe(tags, branch, 'master')
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tags, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 14..19, image_size: 375, count: 10)
end

def wrpped
  test_office(15, 'office')
  rescue => e
    puts "=====\n" * 20
    puts e
    puts "=====\n" * 20
  end

def test_office(n, branch)
  # https://github.com/gravitystorm/openstreetmap-carto/issues/1697 https://github.com/gravitystorm/openstreetmap-carto/issues/108

  # example of node http://www.openstreetmap.org/node/3042848835#map=19/50.02626/19.91366
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => :any_value })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'government' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'company' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'insurance' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'administrative' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  # https://github.com/gravitystorm/openstreetmap-carto/issues/1922
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'lawyer' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  # ?
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'yes' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'estate' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)
end

def aeroway_is_not_road
  branch = 'master'

  count = 5
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'aeroway' => 'taxiway', 'bridge' => 'yes' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'aeroway' => 'runway', 'bridge' => 'yes' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  skip = 0
  seed_generator = land_locations(skip)
  locator = CartoCSSHelper::LocateTags.new({ 'aeroway' => 'taxiway', 'bridge' => 'yes' }, seed_generator: seed_generator)
  diff_on_overpass_data(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)
  locator = CartoCSSHelper::LocateTags.new({ 'aeroway' => 'runway', 'bridge' => 'yes' }, seed_generator: seed_generator)
  diff_on_overpass_data(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  CartoCSSHelper.probe({ 'aeroway' => 'taxiway', 'bridge' => 'yes' }, branch, 'master')
  CartoCSSHelper.probe({ 'aeroway' => 'runway', 'bridge' => 'yes' }, branch, 'master')
  CartoCSSHelper.probe({ 'aeroway' => 'taxiway' }, branch, 'master')
  CartoCSSHelper.probe({ 'aeroway' => 'runway' }, branch, 'master')

  return

  count = 5
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'aeroway' => 'taxiway' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'aeroway' => 'runway' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)
end

def test_ne_removal
  # lat, lon = 51.01155, 14.93786 #Poland
  lat = 46.2008
  lon = 33.6460 # Crimea
  # get_single_image_from_database('entire_world', 'd77af25', lat, lon, 3, 60)
  # get_single_image_from_database('entire_world', 'd5b4551', lat, lon, 3, 60)
  get_single_image_from_database('entire_world', 'ne', lat, lon, 3, 40)
  get_single_image_from_database('entire_world', 'master', lat, lon, 3, 40)
  return

  get_single_image_from_database('entire_world', 'd77af25', 51.66243, -0.58722, 2, 20)
  get_single_image_from_database('entire_world', 'ne', 51.66243, -0.58722, 2, 20)

  get_single_image_from_database('entire_world', 'd77af25', 51.66243, -0.58722, 1, 20)
  get_single_image_from_database('entire_world', 'ne', 51.66243, -0.58722, 1, 20)
end

def run_tests
  CartoCSSHelper::Validator.run_tests('v2.40.0')
end

def test_imagic_sport_color_pr
  before_after_from_loaded_databases({ 'amenity' => 'university' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'track' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'sports_centre' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'stadium' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
end

# do not return always center location of loaded database"
# post post about looking for a new test locations - prepare make post

# https://github.com/matkoniecz/CartoCSSHelper#automated-stuff

# https://github.com/gravitystorm/openstreetmap-carto/issues/1899 "cycleway bridges on z14 are too white"

# poszukać carto w efektywność
