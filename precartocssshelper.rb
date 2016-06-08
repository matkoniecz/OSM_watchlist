# frozen_string_literal: true
require_relative 'database_manager.rb'
require_relative 'location_generator.rb'
require_relative 'location_to_image.rb'

module CartoCSSHelper
  def large_scale_diff(to, from = 'master', image_size = 375, zlevels = 8..19)
    puts
    puts "large_scale_diff: #{from}->#{to}"
    before_after_directly_from_database('krakow', 50.06227, 19.94026, to, from, zlevels, image_size, 'Krakow')
    before_after_directly_from_database('well_mapped_rocky_mountains', 47.56673, 12.32377, to, from, zlevels, image_size, 'well_mapped_rocky_mountains')
    before_after_directly_from_database('rome', 41.86933, 12.49484, to, from, zlevels, image_size, 'Rome')
    before_after_directly_from_database('vienna', 48.19949, 16.37306, to, from, zlevels, image_size, 'Vienna')
    before_after_directly_from_database('abidjan_ivory_coast', 5.3061, -3.9859, to, from, zlevels, image_size, 'abidjan_ivory_coast')
    before_after_directly_from_database('london', 51.50780, -0.12392, to, from, zlevels, image_size, 'London')
    before_after_directly_from_database('vienna', 48.02297, 16.77659, to, from, zlevels, image_size, 'Bruck an der Leitha')
    before_after_directly_from_database('reykjavik', 64.1408, -21.8924, to, from, zlevels, image_size, 'Reykjavik')
    before_after_directly_from_database('rosenheim', 47.82989, 12.07764, to, from, zlevels, image_size, 'rosenheim')
    before_after_directly_from_database('accra_ghana', 5.55363, -0.20693, to, from, zlevels, image_size, 'accra_ghana')
    before_after_directly_from_database('abuja_nigeria', 9.05020, 7.52628, to, from, zlevels, image_size, 'abuja_nigeria')
    before_after_directly_from_database('market', 53.86360, -0.66369, to, from, zlevels, image_size, 'market')
    before_after_directly_from_database('tokyo', 35.31782, 139.50708, to, from, zlevels, image_size, 'tokyo')
  end

  def test_tag_on_real_data_pair_for_this_type(tags_a, tags_b, new_branch, old_branch, zlevels, type_a, type_b, min = 4, skip = 0, image_size = 400)
    generated = 0

    n = 0
    max_n = CartoCSSHelper.get_maxn_for_nth_location
    max_n -= skip
    skip_string = ''
    skip_string = " (#{skip} locations skipped)" if skip > 0
    while generated < min
      location = CartoCSSHelper.get_nth_location(n + skip)
      generated += 1 if visualise_changes_on_real_data_pair(tags_a, tags_b, type_a, type_b, location[0], location[1], zlevels, new_branch, old_branch, image_size)
      n += 1
      return if n > max_n
      puts "#{n}/#{max_n} locations checked #{skip_string}. #{generated}/#{min} testing location found"
    end
  end

  def visualise_changes_on_real_data_pair(tags_a, tags_b, type_a, type_b, latitude, longitude, zlevels, new_branch, old_branch, image_size)
    latitude, longitude = OverpassQueryGenerator.find_data_pair(tags_a, tags_b, latitude, longitude, type_a, type_b)
    return false if latitude.nil?
    header = "#{latitude} #{longitude} - #{VisualDiff.dict_to_pretty_tag_list(tags_a)} near #{VisualDiff.dict_to_pretty_tag_list(tags_b)}"
    VisualDiff.visualise_changes_for_location(latitude, longitude, zlevels, header, new_branch, old_branch, 0.4, image_size)
    return true
  end

  def fits_in_database_bb?(database, latitude, longitude)
    return false if latitude < database[:bottom]
    return false if latitude > database[:top]
    return false if longitude < database[:left]
    return false if longitude > database[:right]
    return true
  end

  def before_after_from_loaded_databases(tags, to, from, zlevels, image_size = 375, count = 3, skip = 0)
    get_list_of_databases.each do |database|
      return true if count <= 0
      if skip > 0
        skip -= 1
        next
      end
      max_range_in_km_for_radius = 400
      lat = (database[:top] + database[:bottom]) / 2
      lon = (database[:left] + database[:right]) / 2
      found = false
      ['node', 'way'].each do |type|
        begin
          latitude, longitude = OverpassQueryGenerator.locate_element_with_given_tags_and_type tags, type, lat, lon, max_range_in_km_for_radius
          if fits_in_database_bb?(database, latitude, longitude)
            description = "#{database[:name]} - #{VisualDiff.dict_to_pretty_tag_list(tags)} [#{latitude}, #{longitude}] #{type}"
            before_after_directly_from_database(database[:name], latitude, longitude, to, from, zlevels, image_size, description)
            found = true
          end
        rescue OverpassQueryGenerator::NoLocationFound, OverpassDownloader::OverpassRefusedResponse
          puts 'No nearby instances of tags and tag is not extremely rare - no generation of nearby location and wordwide search was impossible. No diff image will be generated for this location.'
        end
      end
      count -= 1 if found
    end
    puts "failed to find #{tags} in loaded databases"
    return false
  end

  def compare_presense_of_tag(branch, old_branch, key, value)
    # TODO: use it more in standard tests
    CartoCSSHelper::Git.checkout(old_branch)
    before = CartoCSSHelper::Heuristic.get_tags.include?([key, value])
    CartoCSSHelper::Git.checkout(branch)
    after = CartoCSSHelper::Heuristic.get_tags.include?([key, value])
    before = if before
               'found'
             else
               'missing'
             end
    after = if after
              'found'
            else
              'missing'
            end
    puts "[#{key}=#{value}]: #{before} -> #{after} in database querries"
  end

  def megatest(tags, branch, zlevels = CartoCSSHelper::Configuration.get_min_z..CartoCSSHelper::Configuration.get_max_z, types = ['node', 'closed_way', 'way'], old_branch = 'master')
    # TODO: - add test text-dy
    tags.each do |key, value|
      compare_presense_of_tag(branch, old_branch, key, value)
    end
    CartoCSSHelper.probe tags, branch, old_branch, zlevels, types
    CartoCSSHelper.test tags, branch, old_branch, zlevels, types
    CartoCSSHelper.test tags.merge({ 'name' => :any_value }), branch, old_branch, zlevels, types
  end

  def make_image_from_loaded_database(branch, latitude, longitude, zlevel, image_size, header = '')
    CartoCSSHelper::Git.checkout(branch)
    render_bbox_size = VisualDiff.get_render_bbox_size(zlevel, image_size, latitude)
    cache_folder = CartoCSSHelper::Configuration.get_path_to_folder_for_branch_specific_cache
    get_timestamp = '<<<manual file generation>>>'
    cache_filename = (cache_folder + "#{latitude} #{longitude} #{zlevel}zlevel #{image_size}px #{get_timestamp} #{render_bbox_size}.png").to_s
    unless File.exist?(cache_filename)
      TilemillHandler.run_tilemill_export_image(latitude, longitude, zlevel, render_bbox_size, image_size, cache_filename)
    end
    return cache_filename
  end

  def get_single_image_from_database(database_name, branch, latitude, longitude, zlevel, image_size, header = '')
    switch_databases('gis_test', database_name)
    zlevel_text = zlevel.to_s
    zlevel_text = "0#{zlevel}" if zlevel < 10
    header = branch if header == ''
    header += ' '
    cache_filename = make_image_from_loaded_database(branch, latitude, longitude, zlevel, image_size)
    output_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_output + "#{header} [#{latitude}, #{longitude}] z#{zlevel_text} #{image_size}px #{CartoCSSHelper::Git.get_commit_hash} #{image_size}px.png"
    FileUtils.copy_entry cache_filename, output_filename, false, false, true
    switch_databases(database_name, 'gis_test')
  end

  def x(branch, latitude, longitude, zlevels = 7..18, image_size = 550)
    collection = []
    zlevels.each do |zlevel|
      cache_filename = make_image_from_loaded_database(branch, latitude, longitude, zlevel, image_size, branch)
      collection.push(ImageForComparison.new(cache_filename, "z#{zlevel}"))
    end
    return collection
  end

  def before_after_from_loaded_database(latitude, longitude, to, from, zlevels, image_size, header)
    to_images = x(to, latitude, longitude, zlevels, image_size)
    from_images = x(from, latitude, longitude, zlevels, image_size)
    VisualDiff.pack_image_sets from_images, to_images, header + " #{zlevels}", to, from, image_size
  end

  def before_after_directly_from_database(database_name, latitude, longitude, to, from, zlevels, image_size, header = nil)
    description = "#{database_name}, z(#{zlevels}): #{from} -> #{to} [#{latitude}, #{longitude}]"
    header = description if header.nil?
    puts description
    switch_databases('gis_test', database_name)
    before_after_from_loaded_database(latitude, longitude, to, from, zlevels, image_size, header)
    switch_databases(database_name, 'gis_test')
  end
end

def load_remote_file(url, clear_cache = False)
  CartoCSSHelper.download_remote_file(url, clear_cache)
  filename = CartoCSSHelper.get_place_of_storage_of_resource_under_url(url)
  scene = CartoCSSHelper::VisualDiff::FileDataSource.new(nil, nil, 0.3, filename)
  scene.load
end
