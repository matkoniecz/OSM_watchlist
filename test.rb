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
    CartoCSSHelper.probe({'natural' => 'wetland'}, 'unify', 'master')
    CartoCSSHelper.probe({'natural' => 'marsh'}, 'unify', 'master')
    CartoCSSHelper.probe({'natural' => 'mud'}, 'unify', 'master')
    CartoCSSHelper.probe({'leisure' => 'park'}, 'unify', 'master')
    CartoCSSHelper.probe({'leisure' => 'recreation_ground'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'recreation_ground'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'village_green'}, 'unify', 'master')
    CartoCSSHelper.probe({'leisure' => 'common'}, 'unify', 'master')
    CartoCSSHelper.probe({'leisure' => 'garden'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'quarry'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'vineyard'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'orchard'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'cemetery'}, 'unify', 'master')
    CartoCSSHelper.probe({'amenity' => 'grave_yard'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'residential'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'garages'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'meadow'}, 'unify', 'master')
    CartoCSSHelper.probe({'natural' => 'grassland'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'grass'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'allotments'}, 'unify', 'master')
    CartoCSSHelper.probe({'natural' => 'wood'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'forest'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'farmyard'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'farm'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'farmland'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'greenhouse_horticulture'}, 'unify', 'master')
    CartoCSSHelper.probe({'shop' => 'mall'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'retail'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'industrial'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'railway'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'commercial'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'brownfield'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'landfill'}, 'unify', 'master')
    CartoCSSHelper.probe({'landuse' => 'construction'}, 'unify', 'master')
    CartoCSSHelper.probe({'tourism' => 'caravan_site'}, 'unify', 'master')
    CartoCSSHelper.probe({'tourism' => 'theme_park'}, 'unify', 'master')
    CartoCSSHelper.probe({'tourism' => 'zoo'}, 'unify', 'master')
    CartoCSSHelper.probe({'tourism' => 'attraction'}, 'unify', 'master')
    CartoCSSHelper.probe({'amenity' => 'kindergarten'}, 'unify', 'master')
    CartoCSSHelper.probe({'amenity' => 'school'}, 'unify', 'master')
    CartoCSSHelper.probe({'amenity' => 'college'}, 'unify', 'master')
    CartoCSSHelper.probe({'amenity' => 'university'}, 'unify', 'master')
    CartoCSSHelper.probe({'natural' => 'heath'}, 'unify', 'master')
    CartoCSSHelper.probe({'natural' => 'scrub'}, 'unify', 'master')
    CartoCSSHelper.probe({'natural' => 'beach'}, 'unify', 'master')
    CartoCSSHelper.probe({'leisure' => 'sports_centre'}, 'unify', 'master')
    CartoCSSHelper.probe({'leisure' => 'stadium'}, 'unify', 'master')
    CartoCSSHelper.probe({'leisure' => 'track'}, 'unify', 'master')
    CartoCSSHelper.probe({'leisure' => 'pitch'}, 'unify', 'master')
    #before_after_from_loaded_databases({'landuse' => :any_value, 'name' => :any_value}, 'unify', 'master', 8..22, 1000)
    #before_after_from_loaded_databases({'natural' => :any_value, 'name' => :any_value}, 'unify', 'master', 12..22, 1000)
    #before_after_from_loaded_databases({'leisure' => :any_value, 'name' => :any_value}, 'unify', 'master', 12..22, 1000)
    #before_after_from_loaded_databases({'tourism' => :any_value, 'name' => :any_value}, 'unify', 'master', 12..22, 1000)
    #before_after_from_loaded_databases({'tourism' => 'attraction', 'name' => :any_value}, 'unify', 'master', 12..22, 1000)
    #before_after_from_loaded_databases({'shop' => 'mall', 'name' => :any_value}, 'unify', 'master', 12..22, 1000)
    final


    #dashes not visible enough
    #before_after_from_loaded_databases({'access' => 'destination', 'highway' => 'track'}, 'destination', 'master', 15..19)
    #before_after_from_loaded_databases({'access' => 'private', 'highway' => 'track'}, 'destination', 'master', 15..19)
    #final
    #CartoCSSHelper.probe({'access' => 'destination', 'highway' => 'track'}, 'destination', 'master', 19..19)
    #CartoCSSHelper.probe({'highway' => 'track'}, 'destination', 'master', 19..19)
    #CartoCSSHelper.probe({'access' => 'destination', 'highway' => 'track'}, 'destination', 'master')
    #CartoCSSHelper.probe({'highway' => 'track'}, 'destination', 'master')
    #before_after_from_loaded_databases({'highway' => 'track'}, 'destination', 'master', 10..17)

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


    CartoCSSHelper.probe({'tourism' => 'attraction'}, 'tourism_way', 'master', 19..19)
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 18..18, 'tourism_way', 'master', 'tourism_way', 0.1)
    CartoCSSHelper.visualise_place_by_url('http://www.openstreetmap.org/way/256157138#map=18/50.94165/6.96538', 13..22, 'tourism_way', 'master', 'tourism_way', 0.1)

    CartoCSSHelper.test({'access' => 'destination', 'highway' => 'track'}, 'destination', 'master')
    CartoCSSHelper.test({'highway' => 'track'}, 'destination', 'master')
    CartoCSSHelper.test({'access' => 'private', 'highway' => 'track'}, 'destination', 'master')

    final
    


    #final
    #reload_databases
    
  
    #before_after_from_loaded_databases({'name' => 'Rondo Ofiar Katynia'}, 'nebulon/road-shields', 'master', 13..13, 300, 1)
    #before_after_from_loaded_databases({'oneway' => 'yes'}, 'nebulon/road-shields', 'master', 13..13, 1000, 1)
    #before_after_from_loaded_databases({'oneway' => 'yes'}, 'nebulon/road-shields', 'master', 13..13, 1000, 2)
    #before_after_from_loaded_databases({'oneway' => 'yes'}, 'nebulon/road-shields', 'master', 13..15, 1000, 10)

	get_all_road_types.each{|highway|
	    if highway == "trunk_link"
            next
        end
        #before_after_from_loaded_databases({'oneway' => 'yes', 'highway' => highway}, 'nebulon/oneway-arrows', 'master', 16..19, 1000, 1)
	}


    #final

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
http://wiki.openstreetmap.org/w/index.php?title=Talk:Proposed_features/*%3Ddepot&diff=1204124&oldid=1204114&rcid=&curid=147803
utworzyć obserwowane i dodać tam http://overpass-turbo.eu/s/aBE
https://github.com/gravitystorm/openstreetmap-carto/pull/1692 - report Carto bug
http://overpass-turbo.eu/s/avc highway=track w Krakowie
+{"power_source"=>"wind", "power"=>"generator"} + wiatrak w Polsce
#TODO reduce saturation of grass and fields

=end

    #todo - try reduce glow on footways
    #make tracks wider at high zooms
    
    #see also https://github.com/mapzen/metroextractor-cities/issues/308
    #final

    #https://github.com/gravitystorm/openstreetmap-carto/pull/1804#issuecomment-140301711
    #before_after_from_loaded_databases({'amenity' => 'fountain'}, 'kocio/fountain', 'master', 16..22, 375)

    #WIP
    #before_after_from_loaded_databases({'name' => 'Las Wolski'}, 'track', 'master', 13..22, 1000, 1)
    #before_after_from_loaded_databases({'highway' => 'track'}, 'track', 'v2.34.0', 13..22, 1000, 1)
    #before_after_from_loaded_databases({'highway' => 'track'}, 'track', 'v2.34.0', 13..22, 375, 5)

    #https://github.com/gravitystorm/openstreetmap-carto/issues/1100
    #zlevels = 4..22
    #size = 375
    #from = 'master'
    #to = 'denode'
    #CartoCSSHelper.test ({'landuse' => 'forest', 'name' => :any_value}), to, from, 16..22, ['node']
    #CartoCSSHelper.test ({'landuse' => 'forest', 'name' => :any_value}), to, from, 16..22
    #before_after_directly_from_database('world', 50, 20, to, from, zlevels, size, 'denode [50,20]')


    #CartoCSSHelper::Validator.run_tests('v2.34.0')

    #merged
    #before_after_from_loaded_databases({'amenity' => 'car_wash'}, 'kocio/car_wash', 'master', 14..22, 375, 5)
    #CartoCSSHelper.test ({'amenity' => 'car_wash'}), 'kocio/car_wash', 'master', 14..22


    #kocio - neither opposing nor merging
    #before_after_from_loaded_databases({'shop' => 'sports'}, 'kocio/sports-icon', 'v2.34.0', 17..19, 375, 3, 1)


    z = 14..18


    #CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'natural' => 'peak', 'ele' => '4'}, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 24, 29 - 34
    #CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'natural' => 'peak', 'ele' => '4', 'name' => 'name'}, 'node', false, 22..22, 'v2.34.0', 'v2.34.0')

    #CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({'aeroway' => 'gate', 'ref' => '4'}, 'node', false, 22..22, 'v2.31.0', 'v2.30.0') # 20, 27, 29, 30 - 31 34
    #before_after_from_loaded_databases({'aeroway' => 'gate', 'ref' => :any_value}, 'v2.31.0', 'v2.30.0', 22..22, 100, 2)
    #CartoCSSHelper.test_tag_on_real_data({'aeroway' => 'gate', 'ref' => :any_value}, 'v2.31.0', 'v2.30.0', 22..22, ['way'], 2)


    #CartoCSSHelper.probe ({'amenity' => 'nightclub'}), 'v2.30.0', 'v2.29.0', 22..22 #24, 29 - 32, 34
    #CartoCSSHelper.probe ({'amenity' => 'nightclub'}), 'dy_again', 'v2.30.0', 22..22 #24, 29 - 32, 34

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

    #CartoCSSHelper.test_tag_on_real_data_for_this_type({'highway' => :any_value, 'oneway' => 'yes'}, 'blue-oneway', branch, 14..19, 'way', 10)

    test_all_road_types(branch)

    CartoCSSHelper::VisualDiff.run_jobs

    base_test(to)

    CartoCSSHelper::VisualDiff.run_jobs

    CartoCSSHelper::Validator.run_tests('v2.32.0')
  end
end

#for imports
#https://s3.amazonaws.com/metro-extracts.mapzen.com/trinidad-tobago.osm.pbf
#https://s3.amazonaws.com/metro-extracts.mapzen.com/montevideo_uruguay.osm.pbf
#https://s3.amazonaws.com/metro-extracts.mapzen.com/temuco_chile.osm.pbf
#https://s3.amazonaws.com/metro-extracts.mapzen.com/antananarivo_madagascar.osm.pbf


#CartoCSSHelper.probe({'aeroway' => 'aerodrome'}, 'airport-unify', 'master', 10..14)
#CartoCSSHelper.probe({'aeroway' => 'aerodrome'}, 'airport-unify', 'dbfcce0', 10..14)
#CartoCSSHelper.probe({'aeroway' => 'aerodrome'}, 'dbfcce0', '4af711b', 10..14)

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


#TODO detect good moment to remove waterway=wadi railway=preserved power=sub_station building=no power=station