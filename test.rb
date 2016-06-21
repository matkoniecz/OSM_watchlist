# Encoding: utf-8
# frozen_string_literal: true
require_relative 'require.rb'
require_relative 'watchlist.rb'

include CartoCSSHelper

def make_copy_of_repository
  false # true #false
end

def iterate_over(branch, base_branch, z_levels)
  coords = [[50, 20, "KRK"], [53.245, -2.274, "UK"], [39.1205, -94.4913], [16.820, 79.915], [64.1173, -21.8688], [50, 80], [50, 100]]
  coords.each do |coord|
    lat, lon ,name = coord
    [750].each do |image_size|
      z_levels.reverse_each do |z|
        puts z
        get_single_image_from_database('entire_world', branch, lat, lon, z, image_size)
        get_single_image_from_database('entire_world', base_branch, lat, lon, z, image_size) if base_branch != branch
      end
      description = "#on entire_world [#{lat}, #{lon}]"
      before_after_directly_from_database('entire_world', lat, lon, branch, base_branch, z_levels, image_size, description)
    end
  end
end

def test_placename(branch, z_levels=4..11)
  iterate_over(branch, branch, z_levels)
  iterate_over(branch, 'master', z_levels)
end

def test_710_variants(count = 1)
  tags = [{ 'amenity' => 'pub', 'name' => :any_value }, { 'tourism' => 'museum', 'name' => :any_value }]
  zlevels = 17..17

  tags.each do |tag|
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tag, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'medium-halo', from: 'master', zlevels: zlevels, image_size: 700, count: count)

    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tag, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'small-halo', from: 'master', zlevels: zlevels, image_size: 700, count: count)

    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tag, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'halo', from: 'master', zlevels: zlevels, image_size: 700, count: count)

    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tag, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'bold_710', from: 'master', zlevels: zlevels, image_size: 700, count: count)

    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tag, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'book_710', from: 'master', zlevels: zlevels, image_size: 700, count: count)
  end
end

module CartoCSSHelper
  def main
    CartoCSSHelper::Configuration.set_renderer(:kosmtik)
    bus_guideway_in_tunnel('show_guideway_tunnel')
    CartoCSSHelper::Configuration.set_renderer(:tilemill)
    bus_guideway_in_tunnel('show_guideway_tunnel')

    run_watchlist
    test_placename('placename_large_way_area')

    test_placename('wat', 7..12)
    test_placename('gradual_forest', 6..12)


    test_placename('debug')

    test_placename('spurious')
    get_single_image_from_database('entire_world', 'spurious', 0, 0, 3, 300)
    get_single_image_from_database('entire_world', 'master', 0, 0, 3, 300)
    get_single_image_from_database('entire_world', 'spurious', 0, 0, 2, 300)
    get_single_image_from_database('entire_world', 'master', 0, 0, 2, 300)
    
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'pub', 'name' => :any_value }, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'noto_710', from: 'master', zlevels: 16..18, image_size: 700, count: 1)


    final

    puts "-----"
    test_alpine_hut
    test_710_variants(1)
    test_710_variants(10)
    test_710_variants(15)
    test_710_variants(5)


    #show_military_danger_areas('danger')
		#execute_command("echo \"layer, time, sample, branch\" > tested_file.txt", true)
  	#compare_time('master', 'speedtest', 5, 'new_data.txt')
    #test_office(15, 'master')
		#railway_station_areas_label('area_station')
    missing_labels
    #CartoCSSHelper.add_mapzen_extract('las_vegas', 'las-vegas_nevada')
    #CartoCSSHelper.add_mapzen_extract('ateny', 'athens_greece')


    final

    CartoCSSHelper::VisualDiff.enable_job_pooling
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    CartoCSSHelper::VisualDiff.run_jobs
  end
end

def switch_database
  #switch_databases('placenames', 'gis_test') #out
  
  #init(false) # frozen copy making
   #switch_databases('gis_test', 'entire_world')
   #final

  #switch_databases('gis_test', 'krakow')
  # switch_databases('gis_test', 'new_york')
  #final

  #create_new_gis_database('new_gis')
  #CartoCSSHelper::DataFileLoader.load_data_into_database("/home/mateusz/Downloads/export.osm", true)
  #switch_databases('placenames', 'new_gis')
end


# TODO:
# https://github.com/gravitystorm/openstreetmap-carto/issues/1899
# https://github.com/gravitystorm/openstreetmap-carto/issues/1661
# https://github.com/gravitystorm/openstreetmap-carto/issues/1285
# https://github.com/gravitystorm/openstreetmap-carto/issues/assigned/matkoniecz
# https://github.com/gravitystorm/openstreetmap-carto/pull/2171

def missing_labels
  # missing name - see https://github.com/gravitystorm/openstreetmap-carto/issues/1797
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'peak', 'ele' => '4' }, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 24, 29 - 34
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'peak', 'ele' => '4', 'name' => 'name' }, 'node', false, 22..22, 'v2.34.0', 'v2.34.0')

  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'aeroway' => 'gate', 'ref' => '4' }, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 20, 27, 29, 30 - 31 34
  #before_after_from_loaded_databases({ 'aeroway' => 'gate', 'ref' => :any_value }, 'v2.31.0', 'v2.30.0', 22..22, 100, 2)
  #CartoCSSHelper.test_tag_on_real_data({ 'aeroway' => 'gate', 'ref' => :any_value }, 'v2.31.0', 'v2.30.0', 22..22, ['way'], 2)
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

def show_military_danger_areas(branch)
  # czarnobyl - www.openstreetmap.org/?mlat=51.5&mlon=30.1&zoom=12#map=12/51.5000/30.1000 (lat =-0.5, lon+-0.7)
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'military' => 'danger_area' }, types: ['way'])
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 9..19, image_size: 375, count: 10)

  # locator = CartoCSSHelper::LocateTags.new({ 'military' => 'danger_area' }, types: ['way'])
  # diff_on_overpass_data(location_provider: locator, to: 'master', from: 'master', zlevels: 9..19, image_size: 375, count: 10)
end

def test_alpine_hut
  # https://github.com/gravitystorm/openstreetmap-carto/issues/2115
  branch = 'master'
  hut = { 'tourism' => 'alpine_hut', 'name' => :any_value}
  zlevels = 9..19
  count = 5
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(hut)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: zlevels, image_size: 375, count: count)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new(hut, {'natural' => 'peak'}, 'way', 'node', skip: 0, distance_in_meters: 1000)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: zlevels, image_size: 375, count: count)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new(hut, hut, 'way', 'way', skip: 0, distance_in_meters: 1000)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: zlevels, image_size: 375, count: count)

  locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new(hut, {'natural' => 'volcano'}, 'way', 'node', skip: 0, distance_in_meters: 1000)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: zlevels, image_size: 375, count: count)
  # find alpine hut nearby alpine hut
end

# do not return always center location of loaded database"
# post post about looking for a new test locations - prepare make post

# https://github.com/matkoniecz/CartoCSSHelper#automated-stuff

# TODO: w renderowaniu miejsc przeskocz nad tymi gdzie miejsce jest znane a plik jest nadal do pobrania - oznacza to iż jest on wileki, został skasowany przy czyszczeniu nadmiaru a będzie się

def waiting_pr
  	obelisk('obelisk')
    test_eternal_710_on_real_data("book_710")
    test_eternal_710_on_real_data("bold_710")
    test_eternal_710_dy("book_710")
    test_eternal_710_dy("bold_710")
    buildinglessz12
end

def subway_service
  # write code
  # http://www.openstreetmap.org/way/129520909#map=19/41.83566/12.57786
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'railway' => 'subway', 'service' => :any_value })
  diff_on_loaded_database(location_provider: locator, to: 'master', from: 'master', zlevels: 15..19, image_size: 375, count: 10)

  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'railway' => 'subway', 'service' => 'yard' }, 'way', false, 22..22, 'master', 'master')
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'railway' => 'subway' }, 'way', false, 22..22, 'master', 'master')
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


def railway_station_areas_label(branch)
  # https://github.com/gravitystorm/openstreetmap-carto/issues/2097
  tags = { 'railway' => 'station' }
  CartoCSSHelper.probe(tags, branch, 'master', 22..22, ['closed_way'])
  CartoCSSHelper.probe(tags, branch, 'master', 12..22, ['closed_way'])
  CartoCSSHelper.probe(tags, branch, 'master')
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tags, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 14..19, image_size: 375, count: 10)
end

def database_cleaning
  create_databases
  reload_databases
end

def bus_guideway_in_tunnel(branch)
  tags = {'highway' => 'bus_guideway', 'tunnel' => 'yes'}
  CartoCSSHelper.probe(tags, 'show_guideway_tunnel', 'master', 22..22, ['way'])
  tags = {'highway' => 'bus_guideway'}
  CartoCSSHelper.probe(tags, 'show_guideway_tunnel', 'master', 22..22, ['way'])
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new(tags, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 14..19, image_size: 375, count: 10)
end

#
=begin
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

def get_minutes_spend_on(start, finish)
  return nil if finish.nil?
  return nil if start.nil?
  return (finish - start).to_i / 60
end

def encoutered_exception(e, start_time, load_end, end_time)
  puts e.class
  puts e
  puts
  puts e.backtrace
  min_of_loading = get_minutes_spend_on(start_time, load_end)
  min_of_work = get_minutes_spend_on(load_end, end_time)
  min_of_errors = get_minutes_spend_on(end_time, Time.now)
  notify "Crash during map generation! (after #{min_of_work} min of work and #{min_of_errors} min of errors with #{min_of_loading} min of loading before)"
  sleep 10
end

start_time = Time.now
begin
  # verify
  switch_database
  init(make_copy_of_repository) # frozen copy making
  # CartoCSSHelper::Configuration.set_known_alternative_overpass_url
  load_end = Time.now
  main
rescue => e
  end_time = Time.now
  encoutered_exception(e, start_time, load_end, end_time) while true
end

# poszukać carto w efektywność
