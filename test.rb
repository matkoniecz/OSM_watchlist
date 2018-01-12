# Encoding: utf-8
# frozen_string_literal: true
require_relative 'require.rb'
require_relative 'watchlist.rb'
require_relative 'tag_analysis_for_streetcomplete.rb'
require_relative 'deferred.rb'

include CartoCSSHelper

# sudo service postgresql restart
def make_copy_of_repository
  false # true #false
end

def test_placename(branch, z_levels = 4..11)
  coords = [[50, 20, "KRK"], [53.245, -2.274, "UK"],
            [60.6696, -139.2532, "Kluane National park"],
            [-22.3276, 23.8453, "Central Kalahari Game Reserve"],
            [-24.56237, 15.33238, "Namib National Park"],
            [37.43834, -111.58082, "Grand Staircase USA"],
            [34.56186, -115.21428, "Mojave"],
            [39.1205, -94.4913],
            [16.820, 79.915],
            [64.1173, -21.8688],
            [50, 80],
            [50, 100]]
  iterate_over(branch, branch, z_levels, coords)
  iterate_over(branch, 'master', z_levels, coords)
end

module CartoCSSHelper
  def main
    #tactile_paving_stats #TODO idea - make an actionable list (load what SC allows, compare to outputs, output diff)
    #bikeway_stats
    run_watchlist
    return
    final

    generate_preview('master')
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'pub', 'name' => :any_value }, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'noto_710', from: 'master', zlevels: 16..18, image_size: 700, count: 1)
    run_tests
    final

    CartoCSSHelper::Configuration.set_renderer(:kosmtik)
    location = [[49.91002, -122.78525, "pnorman example"], [49.0907, 22.5646, "Bieszczady"], [37.41499, -111.55294, "staircase"]]

    iterate_over('dissolve_national_parks_proof_of_concept', 'master', 7..14, location)
    # iterate_over('case_nightmare_green', 'master', 7..10, [[38.122, -110.237, "staircase"]])

    CartoCSSHelper::Configuration.set_renderer(:kosmtik)
    test_710_variants(1)

    final

    # wat(50, 20)
    # wat(51.5, 0)
    # wat(0, 0)

    test_placename('wat', 7..12)
    # test_placename('gradual_forest', 6..12)

    puts "-----"
    test_710_variants(10)
    test_710_variants(15)
    test_710_variants(5)

    # show_military_danger_areas('danger')
    # execute_command("echo \"layer, time, sample, branch\" > tested_file.txt", true)
    # compare_time('master', 'speedtest', 5, 'new_data.txt')
    # test_office(15, 'master')
    # railway_station_areas_label('area_station')
    # CartoCSSHelper.add_mapzen_extract('las_vegas', 'las-vegas_nevada')
    # CartoCSSHelper.add_mapzen_extract('ateny', 'athens_greece')

    final

    CartoCSSHelper::VisualDiff.enable_job_pooling
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    CartoCSSHelper::VisualDiff.run_jobs
  end
end

def wat(lat, lon)
  puts "master"
  get_single_image_from_database('entire_world', 'master', lat, lon, 6, 298)
  puts
  puts

  puts "layerless"
  get_single_image_from_database('entire_world', 'layerless', lat, lon, 6, 298)
  puts
  puts
end

def switch_to_database(name)
  init(false) # frozen copy making
  switch_databases('gis_test', name)
  final
end

# sudo service postgresql restart
def switch_database
  # switch_to_database('entire_world')
  # switch_to_database('krakow')

  # create_new_gis_database('new_gis')
  # CartoCSSHelper::DataFileLoader.load_data_into_database("/home/mateusz/Downloads/export.osm", true)
  # switch_databases('placenames', 'new_gis')
end

# TODO:
# https://github.com/gravitystorm/openstreetmap-carto/issues/assigned/matkoniecz

def waiting_pr
  obelisk('obelisk')
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

# see deferred.rb

run_and_report_the_end
