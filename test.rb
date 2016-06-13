# Encoding: utf-8
# frozen_string_literal: true
require_relative 'require.rb'

include CartoCSSHelper

def make_copy_of_repository
  true # true #false
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

def switch_to_krakow_database
  # switch_databases('gis_test', 'krakow')
  # switch_databases('gis_test', 'new_york')
  # final
end

def barrier_names(branch)
  barriers = ['chain', 'city_wall', 'embankment', 'ditch', 'fence', 'guard_rail', 'handrail', 'hedge', 'kerb', 'retaining_wall', 'wall']
  skip = 0
  barriers.each do |barrier|
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'barrier' => barrier })
    diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n, skip: skip)
    skip += 1
  end

  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value, 'landuse' => 'cemetery' }, branch, 'master', 19..19)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, branch, 'master', 19..19)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, branch, 'master', 8..8)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, branch, 'master')
  CartoCSSHelper.test({ 'barrier' => 'wall', 'name' => :any_value }, branch, 'master')

  n = 1
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'wall', 'name' => :any_value }, types: ['way'])
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 19..19, image_size: 1000, count: n)

  [branch].each do |branch|
    CartoCSSHelper.probe({ 'tourism' => 'attraction' }, branch, 'master')
    CartoCSSHelper.probe({ 'waterway' => 'dam' }, branch, 'master')
    CartoCSSHelper.probe({ 'waterway' => 'weir' }, branch, 'master')
    CartoCSSHelper.probe({ 'natural' => 'cliff' }, branch, 'master')
    CartoCSSHelper.probe({ 'natural' => 'hedge' }, branch, 'master')
    CartoCSSHelper.probe({ 'barrier' => 'aajaiaa' }, branch, 'master')
    CartoCSSHelper.probe({ 'tourism' => 'attraction' }, branch, 'master')
  end

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'barrier' => 'wall', 'name' => :any_value }, types: ['way'])
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 1000, count: n)

  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'barrier_way', 'master', branch, 0.1)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 15..22, 'barrier_way', 'master', branch, 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'tourism_way', 'master', 'tourism_way', 0.1)
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 13..22, 'tourism_way', 'master', 'tourism_way', 0.1)
end

module CartoCSSHelper
  def main
    begin
      barrier_names('new_barrier_name')
    rescue => e
      puts e
    end

    begin
      test_turning_circle('turning_circle_squashed', 1, 14..20)
      test_turning_circle('turning_circle_squashed', 5, 14..20)
    rescue => e
      puts e
    end

    # test_turning_circle('turning_with_service')
    # test_turning_circle('turning')

    begin
      test_office(15)
    rescue => e
      puts e
    end

    add_mapzen_extract('las_vegas' 'las-vegas_nevada')
    add_mapzen_extract('ateny' 'athens_greece')

    # https://github.com/gravitystorm/openstreetmap-carto/issues/2126
    # before_after_from_loaded_databases({ 'man_made' => 'obelisk' }, 'master', 'master', 14..18, 300, 10, 0)

    final

    CartoCSSHelper::VisualDiff.enable_job_pooling
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    CartoCSSHelper::VisualDiff.run_jobs
  end
end

def test_office(n)
  # https://github.com/gravitystorm/openstreetmap-carto/issues/1697 https://github.com/gravitystorm/openstreetmap-carto/issues/108

  # example of node http://www.openstreetmap.org/node/3042848835#map=19/50.02626/19.91366
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => :any_value })
  diff_on_loaded_database(location_provider: locator, to: 'office', from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'government' })
  diff_on_loaded_database(location_provider: locator, to: 'office', from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'company' })
  diff_on_loaded_database(location_provider: locator, to: 'office', from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'insurance' })
  diff_on_loaded_database(location_provider: locator, to: 'office', from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'administrative' })
  diff_on_loaded_database(location_provider: locator, to: 'office', from: 'master', zlevels: 15..19, image_size: 375, count: n)

  # https://github.com/gravitystorm/openstreetmap-carto/issues/1922
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'lawyer' })
  diff_on_loaded_database(location_provider: locator, to: 'office', from: 'master', zlevels: 15..19, image_size: 375, count: n)

  # ?
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'yes' })
  diff_on_loaded_database(location_provider: locator, to: 'office', from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'estate' })
  diff_on_loaded_database(location_provider: locator, to: 'office', from: 'master', zlevels: 15..19, image_size: 375, count: n)
end

def show_military_danger_areas
  # czarnobyl - www.openstreetmap.org/?mlat=51.5&mlon=30.1&zoom=12#map=12/51.5000/30.1000 (lat =-0.5, lon+-0.7)
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'military' => 'danger_area' }, types: ['way'])
  diff_on_loaded_database(location_provider: locator, to: 'master', from: 'master', zlevels: 9..19, image_size: 375, count: 10)

  # locator = CartoCSSHelper::LocateTags.new({ 'military' => 'danger_area' }, types: ['way'])
  # diff_on_overpass_data(location_provider: locator, to: 'master', from: 'master', zlevels: 9..19, image_size: 375, count: 10)
end

# TODO:
# https://github.com/gravitystorm/openstreetmap-carto/issues/2097
# https://github.com/gravitystorm/openstreetmap-carto/issues/1899
# https://github.com/gravitystorm/openstreetmap-carto/issues/1661
# https://github.com/gravitystorm/openstreetmap-carto/issues/1285
# https://github.com/gravitystorm/openstreetmap-carto/issues/assigned/matkoniecz

def missing_labels
  # missing name - see https://github.com/gravitystorm/openstreetmap-carto/issues/1797
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'peak', 'ele' => '4' }, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 24, 29 - 34
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'peak', 'ele' => '4', 'name' => 'name' }, 'node', false, 22..22, 'v2.34.0', 'v2.34.0')

  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'aeroway' => 'gate', 'ref' => '4' }, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 20, 27, 29, 30 - 31 34
  before_after_from_loaded_databases({ 'aeroway' => 'gate', 'ref' => :any_value }, 'v2.31.0', 'v2.30.0', 22..22, 100, 2)
  CartoCSSHelper.test_tag_on_real_data({ 'aeroway' => 'gate', 'ref' => :any_value }, 'v2.31.0', 'v2.30.0', 22..22, ['way'], 2)
end

def test_alpine_hut
  # https://github.com/gravitystorm/openstreetmap-carto/issues/2115
  # before_after_from_loaded_databases({ 'tourism' => 'alpine_hut' }, 'master', 'master', 12..15, 500, 10)
  # find alpine hut nearby alpine hut
end

# do not return always center location of loaded database"
# post post about looking for a new test locations - prepare make post

# https://github.com/matkoniecz/CartoCSSHelper#automated-stuff

# TODO: w renderowaniu miejsc przeskocz nad tymi gdzie miejsce jest znane a plik jest nadal do pobrania - oznacza to iż jest on wileki, został skasowany przy czyszczeniu nadmiaru a będzie się

def waiting_pr
  test_library_book_shop_prs
  test_power(branch, n)
  test_fishmonger
  test_rail
end

def subway_service
  # write code
  # http://www.openstreetmap.org/way/129520909#map=19/41.83566/12.57786
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'railway' => 'subway', 'service' => 'yard' }, 'way', false, 22..22, 'master', 'master')
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'railway' => 'subway' }, 'way', false, 22..22, 'master', 'master')
end

def run_tests
  CartoCSSHelper::Validator.run_tests('v2.32.0')
end

def test_imagic_sport_color_pr
  before_after_from_loaded_databases({ 'amenity' => 'university' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'track' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'sports_centre' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'stadium' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
end

def generate_preview
  generate_preview(['master'])
end

def test_water_color
  # https://github.com/gravitystorm/openstreetmap-carto/issues/1781 - tweaking water colour
  # TODO - from world database
  before_after_from_loaded_databases({ 'waterway' => 'river' }, 'water', 'master', 9..19, 1000)
  before_after_from_loaded_databases({ 'waterway' => 'stream' }, 'water', 'master', 9..19, 1000)
  before_after_from_loaded_databases({ 'waterway' => 'ditch' }, 'water', 'master', 9..19, 1000)
  before_after_from_loaded_databases({ 'waterway' => 'riverbank' }, 'water', 'master', 9..19, 1000)

  before_after_from_loaded_databases({ 'natural' => 'coastline' }, 'water', 'master', 9..19, 1000)
end

def database_cleaning
  create_databases
  reload_databases
end

# TODO: watchlist
=begin
rescue todo - watchlist for rare landuse values in Kraków, ; w surface
http://wiki.openstreetmap.org/wiki/Tag%3Alanduse%3Ddepot - update
http://overpass-turbo.eu/s/aJA access=public eliminator
    #http://overpass-turbo.eu/s/aJm - reduce impact before rendering proposal
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'public'}, 'public', 'master', 13..19, 'way', 2)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'private'}, 'public', 'master', 13..19, 'way', 2)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'yes'}, 'public', 'master', 13..19, 'way', 2)
=end

# http://codereview.stackexchange.com/questions/tagged/ruby?page=2&sort=votes&pagesize=15

def final
  CartoCSSHelper::VisualDiff.run_jobs
  notify_spam 'Everything computed!'
  exit
end

def encoutered_exception(e, start_time, load_end, end_time)
  puts e.class
  puts e
  puts
  puts e.backtrace
  min_of_loading = (load_end - start_time).to_i / 60
  min_of_work = (end_time - load_end).to_i / 60
  min_of_errors = (Time.now - end_time).to_i / 60
  notify "Crash during map generation! (after #{min_of_work} min of work and #{min_of_errors} min of errors with #{min_of_loading} min of loading before)"
  sleep 10
end

start_time = Time.now
begin
  # init(false) # frozen copy making
  # switch_databases('gis_test', 'world')
  # final
  # verify
  init(make_copy_of_repository) # frozen copy making
  # CartoCSSHelper::Configuration.set_known_alternative_overpass_url
  load_end = Time.now
  main
rescue => e
  end_time = Time.now
  encoutered_exception(e, start_time, load_end, end_time) while true
end

# poszukać carto w efektywność
