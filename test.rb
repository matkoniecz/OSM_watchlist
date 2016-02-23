# Encoding: utf-8
require_relative '../CartoCSSHelper/lib/cartocss_helper'
require_relative '../CartoCSSHelper/lib/cartocss_helper/configuration'
require_relative '../CartoCSSHelper/lib/cartocss_helper/visualise_changes_image_generation'
require_relative '../CartoCSSHelper/lib/cartocss_helper/util/filehelper'
require_relative '../CartoCSSHelper/delta'
require_relative 'gsoc'
require_relative 'archive'
require_relative 'road_grid'
require_relative 'startup'
require_relative 'precartocssshelper'

include CartoCSSHelper

require 'fileutils'

#TODO w renderowaniu miejsc przeskocz nad tymi gdzie miejsce jest znane a plik jest nadal do pobrania - oznacza to iż jest on wileki, został skasowany przy czyszczeniu nadmiaru a będzie się 

module CartoCSSHelper
  def test_low_zoom(branch, zlevels)
    zlevels.each{|z|
      puts z
      get_single_image_from_database('world', branch, 50.8288, 4.3684, z, 750, 'Brussels')
      get_single_image_from_database('world', branch, -36.84870, 174.76135, z, 750, 'Auckland')
      get_single_image_from_database('world', branch, 39.9530, -75.1858, z, 750, 'New Jersey')
      get_single_image_from_database('world', branch, 55.39276, 13.29790, z, 750, 'Malmo - fields')
    }
  end

  def main
    #CartoCSSHelper::test_tag_on_sythetic_data({'barrier' => 'swing_gate'}, 'swing')
    #CartoCSSHelper::test_tag_on_sythetic_data({'barrier' => 'lift_gate'}, 'swing')

    #CartoCSSHelper::test_tag_on_sythetic_data({'amenity' => 'library'}, 'kocio/library-icon')
    #CartoCSSHelper::test_tag_on_sythetic_data({'amenity' => 'shelter'}, 'kocio/shelter-svg')
    #CartoCSSHelper::test_tag_on_sythetic_data({'tourism' => 'information'}, 'kocio/information-icon')
    #CartoCSSHelper::test_tag_on_sythetic_data({'natural' => 'cave_entrance'}, 'kocio/cave-icon')

    CartoCSSHelper.test_tag_on_real_data_for_this_type({'oneway' => 'yes', 'highway' => 'path', 'bicycle' => 'designated'}, 'nebulon/oneway-bicycle-designated', 'master', 13..22, 'way', 2)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'oneway' => 'yes', 'highway' => 'path', 'horse' => 'designated'}, 'nebulon/oneway-bicycle-designated', 'master', 13..22, 'way', 2)

    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'oneway' => 'yes', 'highway' => 'path'}, 'way', false, 8..22, 'nebulon/oneway-bicycle-designated', 'master')
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'oneway' => 'yes', 'highway' => 'path', 'bicycle' => 'designated'}, 'way', false, 8..22, 'nebulon/oneway-bicycle-designated', 'master')
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'oneway' => 'yes', 'highway' => 'path', 'horse' => 'designated'}, 'way', false, 8..22, 'nebulon/oneway-bicycle-designated', 'master')
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'highway' => 'path', 'horse' => 'designated'}, 'way', false, 8..22, 'nebulon/oneway-bicycle-designated', 'master')
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'highway' => 'path', 'horse' => 'designated', 'surface' => 'unpaved'}, 'way', false, 8..22, 'nebulon/oneway-bicycle-designated', 'master')
    CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'highway' => 'path', 'horse' => 'designated', 'surface' => 'paved'}, 'way', false, 8..22, 'nebulon/oneway-bicycle-designated', 'master')
    CartoCSSHelper::test_tag_on_sythetic_data({'amenity' => 'bus_station'}, 'kocio/bus_station-icon')

    final

    reload_databases()
    #create_databases



    before_after_from_loaded_databases({'amenity' => 'library'}, 'kocio/library-icon', 'master', 15..18, 300, 1)
    before_after_from_loaded_databases({'amenity' => 'bus_station'}, 'kocio/bus_station-icon', 'master', 15..18, 300, 1)
    before_after_from_loaded_databases({'amenity' => 'shelter'}, 'kocio/shelter-svg', 'master', 15..18, 300, 1)
    before_after_from_loaded_databases({'tourism' => 'information'}, 'kocio/information-icon', 'master', 15..18, 300, 1)
    before_after_from_loaded_databases({'natural' => 'cave_entrance'}, 'kocio/cave-icon', 'master', 15..18, 300, 1)
    before_after_from_loaded_databases({'oneway' => 'yes', 'highway' => 'path', 'bicycle' => 'designated'}, 'nebulon/oneway-bicycle-designated', 'master', 15..18, 300, 1)
    before_after_from_loaded_databases({'oneway' => 'yes', 'highway' => 'path', 'horse' => 'designated'}, 'nebulon/oneway-bicycle-designated', 'master', 15..18, 300, 1)
    final

    branch = 'master'
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'highway' => 'turning_circle'}, branch, 'master', 15..18, 'node', 2)
    before_after_from_loaded_databases({'highway' => 'turning_circle'}, branch, 'master', 15..18, 300, 1)
    #test_tag_on_real_data_pair_for_this_type({'highway'=>'turning_circle'}, {'highway' => 'service'}, branch, 'master', 15..18, 'way', 1, 0, 375)
    #test_tag_on_real_data_pair_for_this_type({'highway'=>'turning_circle'}, {'highway' => 'service', 'service' => 'driveway'}, branch, 'master', 15..18, 'way', 1, 0, 375)
    #test_tag_on_real_data_pair_for_this_type({'highway'=>'turning_circle'}, {'highway' => 'living_street'}, branch, 'master', 15..18, 'way', 1, 0, 375)
    #test_tag_on_real_data_pair_for_this_type({'highway'=>'turning_circle'}, {'highway' => 'service', 'service' => 'parking_aisle'}, branch, 'master', 15..18, 'way', 1, 0, 375)

   #switch_databases('gis_test', 'new_york')
   #final
   #generate_preview(['master'])

    #switch_databases('gis_test', 'krakow')
    #final

    #before_after_from_loaded_databases({'leisure' => 'marina'}, 'math/marina-label', 'master', 15..19, 300, 10)
    #before_after_from_loaded_databases({'amenity' => 'taxi'}, 'math/taxi-zoomlevel', 'master', 15..19, 300, 10)

	get_all_road_types.each{|highway|
		puts highway
        before_after_from_loaded_databases({'highway' => highway, 'ref' => :any_value}, 'nebulon/road-shields', 'master', 13..22, 1000, 5)
	}


    #PR puiblished
    #CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'barrier_way', 'master', 'tourism_way', 0.1)
    #CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 15..22, 'barrier_way', 'master', 'tourism_way', 0.1)
    #CartoCSSHelper.probe({'barrier' => 'wall', 'name' => :any_value, 'landuse' => 'cemetery'}, 'barrier_way', 'master', 19..19)
    #CartoCSSHelper.probe({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master', 19..19)
    #CartoCSSHelper.probe({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master', 8..8)
    #CartoCSSHelper.probe({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master')
    #before_after_from_loaded_databases({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master', 15..19, 600, 1)
    #before_after_from_loaded_databases({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master', 15..19)
    #before_after_from_loaded_databases({'barrier' => :any_value, 'name' => :any_value}, 'barrier_way', 'master', 15..19)
    #CartoCSSHelper.test({'barrier' => 'wall', 'name' => :any_value}, 'barrier_way', 'master')

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


    #CartoCSSHelper.probe({'tourism' => 'attraction'}, 'tourism_way', 'master', 19..19)
    #CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'tourism_way', 'master', 'tourism_way', 0.1)
    #CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 13..22, 'tourism_way', 'master', 'tourism_way', 0.1)

    final
    
    #https://github.com/gravitystorm/openstreetmap-carto/issues/1781
    #TODO - from world database
    #before_after_from_loaded_databases({'waterway' => 'river'}, 'water', 'master', 9..19, 1000)
    #before_after_from_loaded_databases({'waterway' => 'stream'}, 'water', 'master', 9..19, 1000)
    #before_after_from_loaded_databases({'waterway' => 'ditch'}, 'water', 'master', 9..19, 1000)
    #before_after_from_loaded_databases({'waterway' => 'riverbank'}, 'water', 'master', 9..19, 1000)

    #before_after_from_loaded_databases({'natural' => 'coastline'}, 'water', 'master', 9..19, 1000)
    #final

    #generate_preview(['master'])

    #before_after_from_loaded_databases({'historic' => 'wayside_cross'}, 'cross', 'master', 16..22, 375)
    #before_after_from_loaded_databases({'man_made' => 'cross'}, 'cross', 'master', 16..22, 375)

    #test_cross_pr
    
    #CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'barrier' => 'lift_gate', 'name' => 'a'}, 'closed_way', false, 22..22, 'master', 'master')
    #catcha-all for areas

    #missing label
    #CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'tourism' => 'viewpoint', 'name' => 'a'}, 'closed_way', false, 22..22, 'master', 'master')

#TODO watchlist
=begin
    
rescue todo - watchlist for rare landuse values in Kraków, ; w surface
http://wiki.openstreetmap.org/wiki/Tag%3Alanduse%3Ddepot - update
http://overpass-turbo.eu/s/aJA access=public eliminator
    #http://overpass-turbo.eu/s/aJm - reduce impact before rendering proposal
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'public'}, 'public', 'master', 13..19, 'way', 2)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'private'}, 'public', 'master', 13..19, 'way', 2)
    CartoCSSHelper.test_tag_on_real_data_for_this_type({'amenity' => 'parking', 'access'=>'yes'}, 'public', 'master', 13..19, 'way', 2)
=end

    
    
    #CartoCSSHelper::Validator.run_tests('v2.34.0')

    #merged
    #before_after_from_loaded_databases({'amenity' => 'car_wash'}, 'kocio/car_wash', 'master', 14..22, 375, 5)
    #CartoCSSHelper.test ({'amenity' => 'car_wash'}), 'kocio/car_wash', 'master', 14..22

    z = 14..18

    #missing name
    #CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'natural' => 'peak', 'ele' => '4'}, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 24, 29 - 34
    #CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'natural' => 'peak', 'ele' => '4', 'name' => 'name'}, 'node', false, 22..22, 'v2.34.0', 'v2.34.0')

    #CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'aeroway' => 'gate', 'ref' => '4'}, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 20, 27, 29, 30 - 31 34
    #before_after_from_loaded_databases({'aeroway' => 'gate', 'ref' => :any_value}, 'v2.31.0', 'v2.30.0', 22..22, 100, 2)
    #CartoCSSHelper.test_tag_on_real_data({'aeroway' => 'gate', 'ref' => :any_value}, 'v2.31.0', 'v2.30.0', 22..22, ['way'], 2)


    final

    show_fixed_bugs(branch)
    large_scale_diff(branch, master)
    test_low_invisible(branch, master)



    generate_preview(['master'])
    final

    CartoCSSHelper::VisualDiff.enable_job_pooling
    gsoc_places(frozen_trunk, frozen_trunk, 10..18)
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    final



=begin
    branch = frozen_trunk
    [11..19].each {|zlevels| #19..19, 15..15, 11..11,
        get_all_road_types.each { |tag|
        before_after_from_loaded_databases({'highway' => tag, 'bridge' => 'yes'}, branch, branch, zlevels)
        before_after_from_loaded_databases({'highway' => tag, 'tunnel' => 'yes'}, branch, branch, zlevels)
        before_after_from_loaded_databases({'highway' => tag}, branch, branch, zlevels)
      }
    }
=end


    [11,10,9,8].each{|z|
      ['55c4b27', master].each {|branch| #new-road-style
        image_size = 780
        if z <= 6
          image_size = 300
        end
        #get_single_image_from_database('world', branch, 50.8288, 4.3684, z, 300, "Brussels #{branch}")
        #get_single_image_from_database('world', branch, -36.84870, 174.76135, z, 300, "Auckland #{branch}")
        #get_single_image_from_database('world', branch, 39.9530, -75.1858, z, 300, "New Jersey #{branch}")
        #get_single_image_from_database('world', branch, 55.39276, 13.29790, z, 300, "Malmo - fields #{branch}")
        get_single_image_from_database('world', branch, 50, 40, z, image_size, "Russia interior #{branch}")
        get_single_image_from_database('world', branch, 50, 20, z, image_size, "Krakow #{branch}")
        get_single_image_from_database('world', branch, 35.07851, 137.684848, z, image_size, "Japan #{branch}")
        if z < 10
          #nothing interesting on z11+
          get_single_image_from_database('world', branch, -12.924, -67.841, z, image_size, "South America #{branch}")
          get_single_image_from_database('world', branch, 50, 0, z, image_size, "UK, France #{branch}")
        end
        get_single_image_from_database('world', branch, 16.820, 79.915, z, image_size, "India #{branch}")
        before_after_directly_from_database('world', 53.8656, -0.6659, branch, branch, z..z, image_size, "rural UK #{branch}")
        before_after_directly_from_database('world', 64.1173, -21.8688, branch, branch, z..z, image_size, "Iceland, Reykjavik #{branch}")
      }
    }
    image_size = 780
    [6, 5, 7].each{|z|
      ['55c4b27', master].each {|branch|
        #get_single_image_from_database('world', branch, 50.8288, 4.3684, z, 300, "Brussels #{branch}")
        #get_single_image_from_database('world', branch, -36.84870, 174.76135, z, 300, "Auckland #{branch}")
        #get_single_image_from_database('world', branch, 39.9530, -75.1858, z, 300, "New Jersey #{branch}")
        #get_single_image_from_database('world', branch, 55.39276, 13.29790, z, 300, "Malmo - fields #{branch}")
        get_single_image_from_database('world', branch, 50, 40, z, image_size, "Russia interior #{branch}")
        get_single_image_from_database('world', branch, 50, 20, z, image_size, "Krakow #{branch}")
        get_single_image_from_database('world', branch, 35.07851, 137.684848, z, image_size, "Japan #{branch}")
        if z < 10
          #nothing interesting on z11+
          get_single_image_from_database('world', branch, -12.924, -67.841, z, image_size, "South America #{branch}")
          get_single_image_from_database('world', branch, 50, 0, z, image_size, "UK, France #{branch}")
        end
        get_single_image_from_database('world', branch, 16.820, 79.915, z, image_size, "India #{branch}")
        before_after_directly_from_database('world', 53.8656, -0.6659, branch, branch, z..z, image_size, "rural UK #{branch}")
        before_after_directly_from_database('world', 64.1173, -21.8688, branch, branch, z..z, image_size, "Iceland, Reykjavik #{branch}")
      }
    }
    gsoc_places('trunk', 'gsoc', 9..18)
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    #show_fixed_bugs('gsoc')
    final



    test_low_invisible(branch, branch)

    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/?mlat=53.149497&mlon=-6.3292126', 16..16, branch, 'master', 'bog', 0.1)
    test_tag_on_real_data_pair_for_this_type({'highway'=>'pedestrian'}, {'highway' => 'living_street'}, branch, 'master', 17..17, 'way', 2, 5, 375)
    test_tag_on_real_data_pair_for_this_type({'natural'=>'heath'}, {'highway' => 'secondary', 'ref' => :any_value}, branch, 'master', 16..16, 'way', 2, 6, 375)
    test_tag_on_real_data_pair_for_this_type({'natural'=>'beach'}, {'highway' => 'secondary'}, branch, 'master', 17..17, 'way', 2, 6, 375)
    test_tag_on_real_data_pair_for_this_type({'natural'=>'sand'}, {'highway' => 'secondary'}, branch, 'master', 17..17, 'way', 1, 72, 375)
    test_tag_on_real_data_pair_for_this_type({'natural'=>'wetland', 'wetland' => 'bog'}, {'highway' => 'secondary', 'ref' => :any_value}, branch, 'master', 17..17, 'way', 1, 72, 375)
    before_after_directly_from_database('world', 47.1045, -122.5882, branch, 'master', 9..10, 375)

    before_after_directly_from_database('rome', 41.92054, 12.48020, branch, 'master', 12..19, 375)
    before_after_directly_from_database('rome', 41.85321, 12.44090, branch, 'master', 12..19, 375)
    large_scale_diff(branch, 'master')
    before_after_directly_from_database('krakow', 50.08987, 19.89922, branch, 'master', 12..19, 375)
    generate_preview([branch])


    CartoCSSHelper::VisualDiff.enable_job_pooling
    gsoc_places(branch, branch, 7..17)
    CartoCSSHelper::VisualDiff.run_jobs

    gsoc_full(branch, branch, 7..17)
    CartoCSSHelper::VisualDiff.shuffle_jobs(4)
    CartoCSSHelper::VisualDiff.run_jobs

    (5..19).each { |zlevel|
      CartoCSSHelper::Grid.new(zlevel, branch, road_set(true, true), areas_set)
    }

    test_all_road_types(branch)

    CartoCSSHelper::VisualDiff.run_jobs

    base_test(to)

    CartoCSSHelper::VisualDiff.run_jobs

    CartoCSSHelper::Validator.run_tests('v2.32.0')
  end

   def test_destination_change
   #dashes not visible enough
   before_after_from_loaded_databases({'access' => 'destination', 'highway' => 'track'}, 'destination', 'master', 15..19)
   before_after_from_loaded_databases({'access' => 'private', 'highway' => 'track'}, 'destination', 'master', 15..19)
   #final
   CartoCSSHelper.probe({'access' => 'destination', 'highway' => 'track'}, 'destination', 'master', 19..19)
   CartoCSSHelper.probe({'highway' => 'track'}, 'destination', 'master', 19..19)
   CartoCSSHelper.probe({'access' => 'destination', 'highway' => 'track'}, 'destination', 'master')
   CartoCSSHelper.probe({'highway' => 'track'}, 'destination', 'master')
   before_after_from_loaded_databases({'highway' => 'track'}, 'destination', 'master', 10..17)
   CartoCSSHelper.test({'access' => 'destination', 'highway' => 'track'}, 'destination', 'master')
   CartoCSSHelper.test({'highway' => 'track'}, 'destination', 'master')
   CartoCSSHelper.test({'access' => 'private', 'highway' => 'track'}, 'destination', 'master')        
  end
end

#    additional_test_unpaved('master', 'master')
#not great, not terrribe
#test_tag_on_real_data_pair_for_this_type({'natural'=>'heath'}, {'highway' => 'secondary', 'ref' => :any_value}, 'new-road-style', 'new-road-style', 16..16, 'way')
#test_tag_on_real_data_pair_for_this_type({'natural'=>'wetland', 'wetland' => 'bog'}, {'highway' => 'secondary', 'ref' => :any_value}, 'new-road-style', 'new-road-style', 17..17, 'way')
#test_airport_unify




def notify(text, silent=$silent)
  if silent
    return
  end
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

begin
  init
  #CartoCSSHelper::Configuration.set_known_alternative_overpass_url
  main
rescue => e
  puts e
  puts
  puts e.backtrace
  notify_spam('Crash during map generation!')
end


#poszukać carto w efektywność
