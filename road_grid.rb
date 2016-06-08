# encoding: UTF-8
require_relative 'gsoc'

# include CartoCSSHelper::TilemillHandler

module CartoCSSHelper
  class Grid
    def get_free_id
      @free_id += 1
      return @free_id
    end

    def initialize(zlevel, new_branch, way_tag_list, area_tag_list, header = '')
      Git.checkout new_branch
      debug = false
      @lat = 0
      @lon = 20
      @data_file_maker = DataFileGenerator.new(nil, nil, @lat, @lon, 0.2)
      @delta = 0.0003 * 2.0**(19 - zlevel)
      @data_file_maker.prepare_file
      @max_x = way_tag_list.length
      @max_y = way_tag_list.length
      @free_id = (@max_x + 1) * (@max_y + 1) + 100000

      add_ways(way_tag_list)

      way_count = way_tag_list.length
      add_areas(way_count, area_tag_list)

      @data_file_maker.finish_file
      DataFileLoader.load_data_into_database(Configuration.get_data_filename, debug)
      zlevel_text = "z#{zlevel}"
      if zlevel < 10
        zlevel_text = "z0#{zlevel}"
      end
      data = way_tag_list.to_s + '<>' + area_tag_list.to_s
      data_hash = Digest::SHA1.hexdigest(data)
      output_filename = Configuration.get_path_to_folder_for_output + "road grid #{new_branch} #{zlevel_text} #{Git.get_commit_hash} #{header}.png"
      cache_filename = Configuration.get_path_to_folder_for_branch_specific_cache + "road grid v8 #{zlevel_text} #{data_hash}.png"
      unless File.exist?(cache_filename)
        image_size = 3000
        render_bbox_size = VisualDiff.get_render_bbox_size(zlevel, image_size, @lat)
        TilemillHandler.run_tilemill_export_image(@lat, @lon, zlevel, render_bbox_size, image_size, cache_filename, debug)
      end
      FileUtils.copy_entry cache_filename, output_filename, false, false, true
    end

    def add_ways(way_tag_list)
      (1..@max_y).each { |y|
        nodes_in_way = []
        (1..@max_x).each { |x|
          node_id = y * @max_y + x
          @data_file_maker.add_node(@lat + (-@max_y / 2 + y) * @delta, @lon + (-@max_x / 2 + x) * @delta, {}, node_id)
          nodes_in_way.push(node_id)
        }
        @data_file_maker.add_way(way_tag_list[y - 1], nodes_in_way, get_free_id)
      }
      (1..@max_x).each { |x|
        nodes_in_way = []
        (1..@max_y).each { |y|
          nodes_in_way.push(y * @max_y + x)
        }
        @data_file_maker.add_way(way_tag_list[x - 1], nodes_in_way, get_free_id)
      }
    end

    def add_areas(way_count, area_tag_list)
      if area_tag_list.empty?
        return
      end
      available_space_for_one_area = @delta * way_count / area_tag_list.length
      i = 0
      area_tag_list.each {|tag|
        nodes_in_way = []
        base_longitude = @lon + i * available_space_for_one_area + available_space_for_one_area / 2 - @delta * way_count / 2
        delta_longitude = available_space_for_one_area / 2
        base_latitude = @lat
        delta_latitude = @max_y * @delta

        start_node_id = node_id = get_free_id
        @data_file_maker.add_node(base_latitude + delta_latitude, base_longitude + delta_longitude, {}, node_id)
        nodes_in_way.push(node_id)

        node_id = get_free_id
        @data_file_maker.add_node(base_latitude - delta_latitude, base_longitude + delta_longitude, {}, node_id)
        nodes_in_way.push(node_id)

        node_id = get_free_id
        @data_file_maker.add_node(base_latitude - delta_latitude, base_longitude - delta_longitude, {}, node_id)
        nodes_in_way.push(node_id)

        node_id = get_free_id
        @data_file_maker.add_node(base_latitude + delta_latitude, base_longitude - delta_longitude, {}, node_id)
        nodes_in_way.push(node_id)

        nodes_in_way.push(start_node_id)

        @data_file_maker.add_way(tag.merge({ 'area' => 'yes' }), nodes_in_way, get_free_id)

        i += 1
      }
    end
  end
end

def road_set(without_access = true, without_surface = true)
  main = get_all_road_types
  # rest_area, services, proposed
  access = ['', 'private', 'destination']
  surface = ['paved', 'unpaved']
  if without_access
    access = ['']
  end
  if without_surface
    surface = ['']
  end

  returned = []
  main.each{|value|
    access.each{|access_value|
      surface.each{|surface_value|
        returned.push({ 'highway' => value, 'name' => value + ' ' + access_value + ' ' + surface_value, 'access' => access_value, 'surface' => surface_value, 'ref' => '12345' })
      }
    }
  }
  access.each{|access_value|
    surface.each{|surface_value|
      returned.push({ 'highway' => 'service', 'service' => 'driveway', 'name' => 'service, service=driveway' + ' ' + access_value + ' ' + surface_value, 'access' => access_value, 'surface' => surface_value, 'ref' => '12345' })
    }
  }
  return returned
end

def areas_set
  landuses = ['allotments', 'basin', 'brownfield', 'cemetery', 'commercial', 'conservation', 'construction', 'farm', 'farmland', 'farmyard', 'forest', 'garages', 'grass', 'greenhouse_horticulture', 'industrial', 'landfill', 'meadow', 'military', 'orchard', 'quarry', 'railway', 'recreation_ground', 'reservoir', 'residential', 'retail', 'village_green', 'vineyard']
  natural = ['bare_rock', 'beach', 'glacier', 'grassland', 'heath', 'marsh', 'sand', 'scree', 'scrub', 'shingle', 'water', 'wetland', 'wood']
  amenity = ['bicycle_parking', 'college', 'grave_yard', 'hospital', 'kindergarten', 'parking', 'place_of_worship', 'prison', 'university', 'school']
  aeroway = ['aerodrome', 'apron', 'helipad', 'runway', 'taxiway']
  power = ['generator', 'station', 'sub_station', 'substation']
  highway = ['footway', 'living_street', 'path', 'pedestrian', 'platform', 'residential', 'rest_area', 'service', 'services', 'track', 'unclassified']
  leisure = ['common', 'garden', 'golf_course', 'marina', 'miniature_golf', 'nature_reserve', 'park', 'pitch', 'playground', 'recreation_ground', 'sports_centre', 'stadium', 'swimming_pool', 'track']
  tourism = ['camp_site', 'caravan_site', 'picnic_site', 'theme_park']

  returned = []
  returned.push({ 'fixme' => 'yes' })
  landuses.each{|value|
    returned.push({ 'landuse' => value, 'name' => value })
  }
  natural.each{|value|
    returned.push({ 'natural' => value, 'name' => value })
  }
  amenity.each{ |value|
    returned.push({ 'amenity' => value, 'name' => value })
  }
  aeroway.each{ |value|
    returned.push({ 'aeroway' => value, 'name' => value })
  }
  power.each{ |value|
    returned.push({ 'power' => value, 'name' => value })
  }
  highway.each{ |value|
    returned.push({ 'highway' => value, 'name' => value })
  }
  leisure.each{ |value|
    returned.push({ 'leisure' => value, 'name' => value })
  }
  tourism.each{ |value|
    returned.push({ 'tourism' => value, 'name' => value })
  }
  returned.push({ 'railway' => 'platform' })
  returned.push({ 'railway' => 'station' })
  returned.push({ 'man_made' => 'breakwater' })
  returned.push({ 'man_made' => 'groyne' })
  returned.push({ 'barrier' => 'hedge' })
  returned.push({ 'building' => Heuristic.get_generic_tag_value })
  returned.push({ 'building' => Heuristic.get_generic_tag_value, 'amenity' => 'place_of_worship' })
  returned.push({ 'amenity' => 'grave_yard', 'religion' => 'jewish' })
  returned.push({ 'amenity' => 'grave_yard', 'religion' => 'christian' })
  return returned
end
