# encoding: UTF-8
# frozen_string_literal: true
require_relative '../CartoCSSHelper/lib/cartocss_helper'
require_relative '../CartoCSSHelper/lib/cartocss_helper/configuration'
require_relative '../CartoCSSHelper/lib/cartocss_helper/visualise_changes_image_generation'
require_relative '../CartoCSSHelper/lib/cartocss_helper/util/filehelper'
# include CartoCSSHelper::RendererHandler

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
      @free_id = (@max_x + 1) * (@max_y + 1) + 100_000

      add_ways(way_tag_list)

      way_count = way_tag_list.length
      add_areas(way_count, area_tag_list)

      @data_file_maker.finish_file
      DataFileLoader.load_data_into_database(Configuration.get_data_filename, debug)
      zlevel_text = "z#{zlevel}"
      zlevel_text = "z0#{zlevel}" if zlevel < 10
      data = way_tag_list.to_s + '<>' + area_tag_list.to_s
      data_hash = Digest::SHA1.hexdigest(data)
      output_filename = Configuration.get_path_to_folder_for_output + "road grid #{new_branch} #{zlevel_text} #{Git.get_commit_hash} #{header}.png"
      cache_filename = Configuration.get_path_to_folder_for_branch_specific_cache + "road grid v8 #{zlevel_text} #{data_hash}.png"
      image_size = 3000
      render_bbox_size = VisualDiff.get_render_bbox_size(zlevel, image_size, @lat)
      cache_location = RendererHandler.request_image_from_renderer(@lat, @lon, zlevel, render_bbox_size, image_size, cache_filename, debug)
      FileUtils.copy_entry cache_location, output_filename, false, false, true
    end

    def add_ways(way_tag_list)
      (1..@max_y).each do |y|
        nodes_in_way = []
        (1..@max_x).each do |x|
          node_id = y * @max_y + x
          @data_file_maker.add_node(@lat + (-@max_y / 2 + y) * @delta, @lon + (-@max_x / 2 + x) * @delta, {}, node_id)
          nodes_in_way.push(node_id)
        end
        @data_file_maker.add_way(way_tag_list[y - 1], nodes_in_way, get_free_id)
      end
      (1..@max_x).each do |x|
        nodes_in_way = []
        (1..@max_y).each do |y|
          nodes_in_way.push(y * @max_y + x)
        end
        @data_file_maker.add_way(way_tag_list[x - 1], nodes_in_way, get_free_id)
      end
    end

    def add_areas(way_count, area_tag_list)
      return if area_tag_list.empty?
      available_space_for_one_area = @delta * way_count / area_tag_list.length
      i = 0
      area_tag_list.each do |tag|
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
      end
    end
  end
end

def road_set(without_access = true, without_surface = true)
  main = get_all_road_types
  # rest_area, services, proposed
  access = ['', 'private', 'destination']
  surface = ['paved', 'unpaved']
  access = [''] if without_access
  surface = [''] if without_surface

  returned = []
  main.each do |value|
    access.each do |access_value|
      surface.each do |surface_value|
        returned.push({ 'highway' => value, 'name' => value + ' ' + access_value + ' ' + surface_value, 'access' => access_value, 'surface' => surface_value, 'ref' => '12345' })
      end
    end
  end
  access.each do |access_value|
    surface.each do |surface_value|
      returned.push({ 'highway' => 'service', 'service' => 'driveway', 'name' => 'service, service=driveway' + ' ' + access_value + ' ' + surface_value, 'access' => access_value, 'surface' => surface_value, 'ref' => '12345' })
    end
  end
  return returned
end

def get_landuse_data
  return [
    { key: 'landuse',
      values: ['allotments', 'basin', 'brownfield', 'cemetery', 'commercial',
               'conservation', 'construction', 'farm', 'farmland', 'farmyard', 'forest',
               'garages', 'grass', 'greenhouse_horticulture', 'industrial', 'landfill',
               'meadow', 'military', 'orchard', 'quarry', 'railway', 'recreation_ground',
               'reservoir', 'residential', 'retail', 'village_green', 'vineyard'] },
    { key: 'natural',
      values: ['bare_rock', 'beach', 'glacier', 'grassland', 'heath', 'marsh',
               'sand', 'scree', 'scrub', 'shingle', 'water', 'wetland', 'wood'] },
    { key: 'amenity',
      values: ['bicycle_parking', 'college', 'grave_yard', 'hospital',
               'kindergarten', 'parking', 'place_of_worship', 'prison', 'university',
               'school'] },
    { key: 'aeroway',
      values: ['aerodrome', 'apron', 'helipad', 'runway', 'taxiway'] },
    { key: 'power',
      values: ['generator', 'station', 'sub_station', 'substation'] },
    { key: 'highway',
      values: ['footway', 'living_street', 'path', 'pedestrian', 'platform',
               'residential', 'rest_area', 'service', 'services', 'track', 'unclassified'] },
    { key: 'leisure',
      values: ['common', 'garden', 'golf_course', 'marina', 'miniature_golf',
               'nature_reserve', 'park', 'pitch', 'playground', 'recreation_ground',
               'sports_centre', 'stadium', 'swimming_pool', 'track'] },
    { key: 'tourism',
      values: ['camp_site', 'caravan_site', 'picnic_site', 'theme_park'] },
    { key: 'railway',
      values: ['platform', 'station'] },
    { key: 'man_made',
      values: ['breakwater', 'groyne'] },
    { key: 'barrier',
      values: ['hedge'] },
  ]
end

def areas_set
  returned = []
  returned.push({ 'fixme' => 'yes' })
  get_landuse_data.each[:values].each do |value|
    returned.push({ landuses[:key] => value, 'name' => value })
  end
  returned.push({ 'building' => Heuristic.get_generic_tag_value })
  returned.push({ 'building' => Heuristic.get_generic_tag_value, 'amenity' => 'place_of_worship' })
  returned.push({ 'amenity' => 'grave_yard', 'religion' => 'jewish' })
  returned.push({ 'amenity' => 'grave_yard', 'religion' => 'christian' })
  return returned
end
