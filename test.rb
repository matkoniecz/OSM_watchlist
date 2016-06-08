# Encoding: utf-8
# frozen_string_literal: true
require_relative '../CartoCSSHelper/lib/cartocss_helper'
require_relative '../CartoCSSHelper/lib/cartocss_helper/configuration'
require_relative '../CartoCSSHelper/lib/cartocss_helper/visualise_changes_image_generation'
require_relative '../CartoCSSHelper/lib/cartocss_helper/util/filehelper'
require_relative 'archive/gsoc2015'
require_relative 'archive/archive'
require_relative 'road_grid'
require_relative 'startup'
require_relative 'precartocssshelper'

include CartoCSSHelper

require 'fileutils'

# TODO: w renderowaniu miejsc przeskocz nad tymi gdzie miejsce jest znane a plik jest nadal do pobrania - oznacza to iż jest on wileki, został skasowany przy czyszczeniu nadmiaru a będzie się

def make_copy_of_repository
  false # true #false
end

def test_turning_circle
  tags_a = { 'highway' => 'turning_circle' }
  tags = [{ 'highway' => 'residential' }, { 'highway' => 'living_street' },
          { 'highway' => 'service' }, { 'highway' => 'service', 'service' => 'driveway' },
          { 'highway' => 'service', 'service' => 'parking_aisle' }]

  tags.each do |tags_b|
    puts tags_b
    locator = CartoCSSHelper::LocatePairedTagsInsideLoadedDatabases.new(tags_a, tags_b, 'node', 'way', 0)
    diff_on_loaded_database(location_provider: locator, to: 'turning_circle', from: 'master', zlevels: 15..19, image_size: 375, count: 6)
  end

  # test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'residential' }, 'turning_circle', 'master', 15..19, 'node', 'way', 2, 0, 375)
  # test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'living_street' }, 'turning_circle', 'master', 15..19, 'node', 'way', 2, 0, 375)
  # test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'service' }, 'turning_circle', 'master', 15..19, 'node', 'way', 2, 0, 375)
  # test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'service', 'service' => 'driveway' }, 'turning_circle', 'master', 15..19, 'node', 'way', 2, 0, 375)
  # test_tag_on_real_data_pair_for_this_type({ 'highway' => 'turning_circle' }, { 'highway' => 'service', 'service' => 'parking_aisle' }, 'turning_circle', 'master', 15..19, 'node', 'way', 2, 0, 375)
end

def test_viewpoint
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'viewpoint', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'closed_way', false, 12..22, 'viewpoint', 'master')
  before_after_from_loaded_databases({ 'tourism' => 'viewpoint', 'name' => :any_value }, 'viewpoint', 'master', 18..18, 350, 5, 0)
  # missing label
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', '41714f1')

  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'attraction', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', 'master')
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'viewpoint', 'master')

  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'attraction', 'name' => 'a' }, 'closed_way', false, 22..22, 'test1', 'master')
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'tourism' => 'viewpoint', 'name' => 'a' }, 'closed_way', false, 22..22, 'test1', 'master')
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

def test_rail_pr
  # before_after_from_loaded_databases({'railway' => 'rail', 'tunnel' => 'yes', 'service' => :any_value}, 'rail', 'master', 17..20, 1100, n, skip)
  # final
  CartoCSSHelper.test_tag_on_real_data_for_this_type({ 'railway' => 'rail', 'tunnel' => 'yes', 'service' => :any_value }, 'rail', 'master', 17..20, 'way', 5)
  before_after_from_loaded_databases({ 'railway' => 'rail' }, 'rail', 'master', 17..20, 1100, 3, 1)
  before_after_from_loaded_databases({ 'railway' => 'rail', 'tunnel' => 'yes' }, 'rail', 'master', 17..20, 1100, 3, 1)
end

def test_library_book_shop_prs
  # CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 15..22, 'master', 'pnorman/osm2pgsql_style_update', 'master', 0.1)
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'amenity' => 'library', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'node', false, 22..22, 'library11', 'master')
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'shop' => 'books', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ' }, 'node', false, 22..22, 'also_shop', 'master')
  n = 6
  skip = 3
  before_after_from_loaded_databases({ 'amenity' => 'library' }, 'library11', 'master', 16..18, 300, n, skip)
  n = 6
  skip = 0
  before_after_from_loaded_databases({ 'shop' => 'books' }, 'also_shop', 'master', 16..18, 300, n, skip)
end

def switch_to_krakow_database
  # switch_databases('gis_test', 'krakow')
  # switch_databases('gis_test', 'new_york')
  # final
end

def test_imagic_sport_color_pr
  before_after_from_loaded_databases({ 'amenity' => 'university' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'track' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'sports_centre' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
  before_after_from_loaded_databases({ 'leisure' => 'stadium' }, 'imagico/sport-colors', 'master', 14..18, 500, n, skip)
end

def database_cleaning
  create_databases
  reload_databases
end

def barrier_names
  before_after_from_loaded_databases({ 'barrier' => 'wall', 'name' => :any_value }, 'barrier_way', 'master', 15..19, 600, 1)
  before_after_from_loaded_databases({ 'barrier' => 'wall', 'name' => :any_value }, 'barrier_way', 'master', 15..19)
  before_after_from_loaded_databases({ 'barrier' => :any_value, 'name' => :any_value }, 'barrier_way', 'master', 15..19)

  # PR to redo
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'barrier_way', 'master', 'tourism_way', 0.1)
  CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 15..22, 'barrier_way', 'master', 'tourism_way', 0.1)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value, 'landuse' => 'cemetery' }, 'barrier_way', 'master', 19..19)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, 'barrier_way', 'master', 19..19)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, 'barrier_way', 'master', 8..8)
  CartoCSSHelper.probe({ 'barrier' => 'wall', 'name' => :any_value }, 'barrier_way', 'master')
  CartoCSSHelper.test({ 'barrier' => 'wall', 'name' => :any_value }, 'barrier_way', 'master')

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
end

def missing_labels
  # missing name - see https://github.com/gravitystorm/openstreetmap-carto/issues/1797
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'peak', 'ele' => '4' }, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 24, 29 - 34
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'peak', 'ele' => '4', 'name' => 'name' }, 'node', false, 22..22, 'v2.34.0', 'v2.34.0')

  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'aeroway' => 'gate', 'ref' => '4' }, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 20, 27, 29, 30 - 31 34
  before_after_from_loaded_databases({ 'aeroway' => 'gate', 'ref' => :any_value }, 'v2.31.0', 'v2.30.0', 22..22, 100, 2)
  CartoCSSHelper.test_tag_on_real_data({ 'aeroway' => 'gate', 'ref' => :any_value }, 'v2.31.0', 'v2.30.0', 22..22, ['way'], 2)
end

def test_forest
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'valley', 'landuse' => 'forest' }, 'closed_way', false, 22..22, 'forest', 'master')

  locator = LocateTagsInsideLoadedDatabases({ 'natural' => :any_value, 'landuse' => 'forest' })
  diff_on_loaded_database(location_provider: locator, to: 'forest', from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = LocateTagsInsideLoadedDatabases({ 'natural' => 'wood' })
  diff_on_loaded_database(location_provider: locator, to: 'forest', from: 'master', zlevels: 15..19, image_size: 375, count: 6)
end

module CartoCSSHelper
  def main
    # before_after_from_loaded_databases({ 'man_made' => 'obelisk' }, 'master', 'master', 14..18, 300, 10, 0)

    # before_after_from_loaded_databases({ 'tourism' => 'alpine_hut' }, 'master', 'master', 12..15, 500, 10)
    test_turning_circle
    test_eternal_710_text_resize

    final

    get_all_road_types.each do |highway|
      puts highway
      before_after_from_loaded_databases({ 'highway' => highway, 'ref' => :any_value }, 'nebulon/road-shields', 'master', 13..22, 1000, 5)
    end

    CartoCSSHelper::VisualDiff.enable_job_pooling
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    CartoCSSHelper::VisualDiff.run_jobs
  end
end

def show_road_grid
  # TODO: code is broken, requires updates
  (5..19).each do |zlevel|
    CartoCSSHelper::Grid.new(zlevel, branch, road_set(true, true), areas_set)
  end
end

def run_tests
  CartoCSSHelper::Validator.run_tests('v2.32.0')
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
