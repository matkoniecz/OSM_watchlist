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
    get_timestamp = '<<<manual file generation>>>'
    cache_filename = "#{latitude} #{longitude} #{zlevel}zlevel #{image_size}px #{get_timestamp} #{render_bbox_size}.png"
    cache_location = RendererHandler.request_image_from_renderer(latitude, longitude, zlevel, render_bbox_size, image_size, cache_filename)
    puts cache_location
    return cache_location
  end

  def get_single_image_from_database(database_name, branch, latitude, longitude, zlevel, image_size, header = '')
    switch_databases('gis_test', database_name)
    zlevel_text = zlevel.to_s
    zlevel_text = "0#{zlevel}" if zlevel < 10
    header = branch if header == ''
    header += ' '
    cache_location = make_image_from_loaded_database(branch, latitude, longitude, zlevel, image_size)
    output_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_output + "#{header} [#{latitude}, #{longitude}] z#{zlevel_text} #{image_size}px #{CartoCSSHelper::Git.get_commit_hash} #{image_size}px.png"
    FileUtils.copy_entry cache_location, output_filename, false, false, true
    switch_databases(database_name, 'gis_test')
  end

  def x(branch, latitude, longitude, zlevels = 7..18, image_size = 550)
    raise 'renamed'
  end

  def collect_images(branch, latitude, longitude, zlevels = 7..18, image_size = 550)
    collection = []
    zlevels.each do |zlevel|
      cache_location = make_image_from_loaded_database(branch, latitude, longitude, zlevel, image_size, branch)
      collection.push(ImageForComparison.new(cache_location, "z#{zlevel}"))
    end
    return collection
  end

  def before_after_from_loaded_database(latitude, longitude, to, from, zlevels, image_size, header)
    to_images = collect_images(to, latitude, longitude, zlevels, image_size)
    from_images = collect_images(from, latitude, longitude, zlevels, image_size)
    VisualDiff.pack_image_sets(from_images, to_images, header + " #{zlevels}", to, from, image_size)
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

def iterate_over(branch, base_branch, z_levels, coords, size: 750)
  coords.each do |coord|
    lat, lon, name = coord
    [size].each do |image_size|
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
