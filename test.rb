# Encoding: utf-8
# frozen_string_literal: true
require_relative '../CartoCSSHelper/lib/cartocss_helper'
require_relative '../CartoCSSHelper/lib/cartocss_helper/configuration'
require_relative '../CartoCSSHelper/lib/cartocss_helper/visualise_changes_image_generation'
require_relative '../CartoCSSHelper/lib/cartocss_helper/util/filehelper'
require_relative 'gsoc'
require_relative 'archive'
require_relative 'road_grid'
require_relative 'startup'
require_relative 'precartocssshelper'

include CartoCSSHelper

require 'fileutils'

# TODO: w renderowaniu miejsc przeskocz nad tymi gdzie miejsce jest znane a plik jest nadal do pobrania - oznacza to iż jest on wileki, został skasowany przy czyszczeniu nadmiaru a będzie się

def make_copy_of_repository
  false # true #false
end

module CartoCSSHelper
  def main
    test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'residential' }, 'turning_circle', 'master', 17..19, 'node', 'way', 2, 0, 375)
    test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'living_street' }, 'turning_circle', 'master', 17..19, 'node', 'way', 2, 0, 375)
    test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'service' }, 'turning_circle', 'master', 17..19, 'node', 'way', 2, 0, 375)
    test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'service', 'service' => 'driveway' }, 'turning_circle', 'master', 17..19, 'node', 'way', 2, 0, 375)
    test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'service', 'service' => 'parking_aisle' }, 'turning_circle', 'master', 17..19, 'node', 'way', 2, 0, 375)

    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'viewpoint', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'closed_way', false, 12..22, 'viewpoint', 'master')
    before_after_from_loaded_databases({ 'tourism' => 'viewpoint', 'name' => :any_value }, 'viewpoint', 'master', 18..18, 350, 5, 0)

    # missing label
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', '41714f1')

    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'attraction', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', 'master')
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', 'master')

    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'attraction', 'name' => 'a' }, 'closed_way', false, 22..22, 'test1', 'master')
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'test1', 'master')

    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'shop' => 'fishmonger', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'node', false, 22..22, 'fishmonger', 'master')
    before_after_from_loaded_databases({ 'shop' => 'fishmonger' }, 'fishmonger', 'master', 17..18, 300, 2, 8)

    # before_after_from_loaded_databases({'highway' => 'pedestrian', 'area'=>'yes', 'name' => :any_value}, 'pnorman/road_areas', 'v2.38.0', 16..18, 400, 2, 0)

    # before_after_from_loaded_databases({'highway' => :any_value, 'name' => :any_value}, 'pnorman/road_areas', 'v2.38.0', 16..18, 1000, 2, 0)

    # switch_databases('gis_test', 'krakow')

    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'shop' => 'seafood', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}, 'node', false, 22..22, 'drop-fishmonger', 'master')
    # before_after_from_loaded_databases({'shop' => 'seafood'}, 'drop-fishmonger', 'master', 17..18, 300, 2, 8)

    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'shop' => 'fishmonger', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}, 'node', false, 22..22, 'fishmonger', 'master')

    # before_after_from_loaded_databases({'shop' => 'fishmonger'}, 'fishmonger', 'master', 17..18, 300, 2, 8)

    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'amenity' => 'bicycle_parking'}.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}), 'closed_way', false, 22..22, 'eternal_710', 'master')
    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'amenity' => 'parking'}.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}), 'closed_way', false, 22..22, 'eternal_710', 'master')
    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'amenity' => 'motorcycle_parking'}.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ'}), 'closed_way', false, 22..22, 'eternal_710', 'master')
    test_eternal_710_text_resize

    before_after_from_loaded_databases({ 'man_made' => 'obelisk' }, 'master', 'master', 14..18, 300, 10, 0)

    # before_after_from_loaded_databases({'railway' => 'rail', 'tunnel' => 'yes', 'service' => :any_value}, 'rail', 'master', 17..20, 1100, n, skip)
    # final
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'railway' => 'rail', 'tunnel' => 'yes', 'service' => :any_value }, 'rail', 'master', 17..20, 'way', 5)
    before_after_from_loaded_databases({ 'railway' => 'rail' }, 'rail', 'master', 17..20, 1100, 3, 1)
    before_after_from_loaded_databases({ 'railway' => 'rail', 'tunnel' => 'yes' }, 'rail', 'master', 17..20, 1100, 3, 1)

    # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 15..22, 'master', 'pnorman/osm2pgsql_style_update', 'master', 0.1)
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'amenity' => 'library', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'node', false, 22..22, 'library11', 'master')
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'shop' => 'books', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'node', false, 22..22, 'also_shop', 'master')

    # CartoCSSHelper.test_tag_on_real_data_for_this_type({'highway' => 'turning_circle'}, branch, 'master', 15..18, 'node', 2)

    n = 6
    skip = 3
    before_after_from_loaded_databases({ 'amenity' => 'library' }, 'library11', 'master', 16..18, 300, n, skip)
    n = 6
    skip = 0
    before_after_from_loaded_databases({ 'shop' => 'books' }, 'also_shop', 'master', 16..18, 300, n, skip)

    # before_after_from_loaded_databases({'amenity' => 'university'}, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
    # before_after_from_loaded_databases({'leisure' => 'track'}, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
    # before_after_from_loaded_databases({'leisure' => 'sports_centre'}, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
    # before_after_from_loaded_databases({'leisure' => 'stadium'}, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)

    before_after_from_loaded_databases({ 'highway' => 'turning_circle' }, 'master', 'master', 12..15, 500, 10)

    before_after_from_loaded_databases({ 'tourism' => 'alpine_hut' }, 'master', 'master', 12..15, 500, 10)
    final

    # CartoCSSHelper::test_tag_on_sythetic_data({'barrier' => 'swing_gate'}, 'swing')
    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'oneway' => 'yes', 'highway' => 'path'}, 'way', false, 8..22, 'nebulon/oneway-bicycle-designated', 'master')

    # CartoCSSHelper.test_tag_on_real_data_for_this_type({'tourism' => 'information'}, 'kocio/information-icon', 'master', 14..22, 'node', 5)
    # CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'bus_station'}, 'kocio/bus_station-icon', 'master', 14..22, 'node', 5)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'amenity' => 'library' }, 'kocio/library-icon-open', 'master', 22..22, 'node', 5, 115)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'amenity' => 'library' }, 'kocio/library-icon-open', 'master', 14..22, 'node', 5)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'amenity' => 'library' }, 'kocio/library-icon-open', 'master', 14..22, 'node', 5)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'amenity' => 'library' }, 'kocio/library-icon-open', 'master', 14..22, 'closed_way', 5)

    final

    final

    branch = 'master'
    CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'highway' => 'turning_circle' }, branch, 'master', 15..18, 'node', 2)
    before_after_from_loaded_databases({ 'highway' => 'turning_circle' }, branch, 'master', 15..18, 300, 1)

    # switch_databases('gis_test', 'new_york')
    # final

    get_all_road_types.each do |highway|
      puts highway
      before_after_from_loaded_databases({ 'highway' => highway, 'ref' => :any_value }, 'nebulon/road-shields', 'master', 13..22, 1000, 5)
    end

# create_databases
# reload_databases()

# PR to redo
# CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'barrier_way', 'master', 'tourism_way', 0.1)
# CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 15..22, 'barrier_way', 'master', 'tourism_way', 0.1)
# CartoCSSHelper.probe({'barrier' => 'wall', 'name' => :any_value, 'landuse' => 'cemetery'}, 'barrier_way', 'master', 19..19)
# CartoCSSHelper.probe({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master', 19..19)
# CartoCSSHelper.probe({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master', 8..8)
# CartoCSSHelper.probe({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master')
# before_after_from_loaded_databases({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master', 15..19, 600, 1)
# before_after_from_loaded_databases({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master', 15..19)
# before_after_from_loaded_databases({'barrier' => :any_value, 'name' => :any_value}, 'barrier_way', 'master', 15..19)
# CartoCSSHelper.test({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master')

=begin
    ['barrier_way', 'tourism_way'].each{|branch|
        CartoCSSHelper.probe({'tourism' => 'attraction'}, branch, 'master')
        CartoCSSHelper.probe({'waterway' => 'dam'}, branch, 'master')
        CartoCSSHelper.probe({'waterway' => 'weir'}, branch, 'master')
        CartoCSSHelper.probe({'man_made' => 'pier'}, branch, 'master')
        CartoCSSHelper.probe({'man_made' => 'breakwater'}, branch, 'master')
        CartoCSSHelper.probe({'man_made' => 'groyne'}, branch, 'master')
        CartoCSSHelper.probe({'man_made' => 'embankment'}, branch, 'master')
        CartoCSSHelper.probe({'natural' => 'cliff'}, branch, 'master')
    }
    final
=end

    # CartoCSSHelper.probe({'tourism' => 'attraction'}, 'tourism_way', 'master', 19..19)
    # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'tourism_way', 'master', 'tourism_way', 0.1)
    # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 13..22, 'tourism_way', 'master', 'tourism_way', 0.1)

# https://github.com/gravitystorm/openstreetmap-carto/issues/1781 - tweaking water colour
# TODO - from world database
# before_after_from_loaded_databases({'waterway' => 'river'}, 'water', 'master', 9..19, 1000)
# before_after_from_loaded_databases({'waterway' => 'stream'}, 'water', 'master', 9..19, 1000)
# before_after_from_loaded_databases({'waterway' => 'ditch'}, 'water', 'master', 9..19, 1000)
# before_after_from_loaded_databases({'waterway' => 'riverbank'}, 'water', 'master', 9..19, 1000)

# before_after_from_loaded_databases({'natural' => 'coastline'}, 'water', 'master', 9..19, 1000)
# final

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

    # CartoCSSHelper::Validator.run_tests('v2.34.0')

    # merged
    # before_after_from_loaded_databases({'amenity' => 'car_wash'}, 'kocio/car_wash', 'master', 14..22, 375, 5)
    # CartoCSSHelper.test ({'amenity' => 'car_wash'}), 'kocio/car_wash', 'master', 14..22

    # missing name
    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'natural' => 'peak', 'ele' => '4'}, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 24, 29 - 34
    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'natural' => 'peak', 'ele' => '4', 'name' => 'name'}, 'node', false, 22..22, 'v2.34.0', 'v2.34.0')

    # CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'aeroway' => 'gate', 'ref' => '4'}, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 20, 27, 29, 30 - 31 34
    # before_after_from_loaded_databases({'aeroway' => 'gate', 'ref' => :any_value}, 'v2.31.0', 'v2.30.0', 22..22, 100, 2)
    # CartoCSSHelper.test_tag_on_real_data({'aeroway' => 'gate', 'ref' => :any_value}, 'v2.31.0', 'v2.30.0', 22..22, ['way'], 2)

    final

    large_scale_diff(branch, master)

    generate_preview(['master'])
    final

    CartoCSSHelper::VisualDiff.enable_job_pooling
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    final

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
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    final

    (5..19).each do |zlevel|
      CartoCSSHelper::Grid.new(zlevel, branch, road_set(true, true), areas_set)
    end

    CartoCSSHelper::VisualDiff.run_jobs

    CartoCSSHelper::Validator.run_tests('v2.32.0')
  end
end

def notify(text, silent = $silent)
  return if silent
  puts "Notification: #{text}"
  system("notify-send '#{text}'")
end

def notify_spam(text)
  while true
    notify text
    sleep 10
  end
end

def done_segment
  notify 'Computed!'
end

def final
  CartoCSSHelper::VisualDiff.run_jobs
  notify_spam 'Everything computed!'
  exit
end

def encoutered_exception(e)
  puts e
  puts
  puts e.backtrace
  notify 'Crash during map generation!'
  sleep 10
end

begin
  init(make_copy_of_repository) # frozen copy making
  # CartoCSSHelper::Configuration.set_known_alternative_overpass_url
  main
rescue => e
  encoutered_exception(e) while true
end

# poszukać carto w efektywność
