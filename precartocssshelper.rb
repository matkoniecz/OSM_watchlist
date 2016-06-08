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

  def reload_database_using_mapzen_extract(database_name, mapzen_extract_name)
    switch_databases('gis_test', database_name)
    load_remote_file("https://s3.amazonaws.com/metro-extracts.mapzen.com/#{mapzen_extract_name}.osm.pbf", true)
    switch_databases(database_name, 'gis_test')
  end

  def reload_database_sourced_as_osm_url(database_name, url, download_bbox_size)
    switch_databases('gis_test', database_name)
    # TODO: - is it really flushing cache without manually deleting overpass cache?
    CartoCSSHelper.visualise_place_by_url(url, 19..19, 'master', 'master', nil, download_bbox_size, 35)
    switch_databases(database_name, 'gis_test')
  end

  def reload_databases
    reload_database_using_mapzen_extract('krakow', 'krakow_poland')
    reload_database_using_mapzen_extract('london', 'london_england')
    reload_database_using_mapzen_extract('rome', 'rome_italy')
    reload_database_using_mapzen_extract('reykjavik', 'reykjavik_iceland')
    reload_database_using_mapzen_extract('vienna', 'vienna_austria')

    # footways on natural=bare_rock
    reload_database_sourced_as_osm_url('well_mapped_rocky_mountains', 'http://www.openstreetmap.org/?mlat=47.56673&mlon=12.32377#map=19/47.56673/12.32377', 1)

    reload_database_using_mapzen_extract('abidjan_ivory_coast', 'abidjan_ivory-coast')
    reload_database_using_mapzen_extract('accra_ghana', 'accra_ghana')
    reload_database_using_mapzen_extract('abuja_nigeria', 'abuja_nigeria')
    reload_database_using_mapzen_extract('tokyo', 'tokyo_japan')

    reload_database_sourced_as_osm_url('market', 'http://www.openstreetmap.org/#map=19/53.86360/-0.66369', 0.4)
    reload_database_sourced_as_osm_url('rosenheim', 'http://www.openstreetmap.org/?mlat=47.82989&mlon=12.07764#map=19/47.82989/12.07764', 1)
    reload_database_sourced_as_osm_url('south_mountain', 'http://www.openstreetmap.org/?mlat=33.32792&mlon=-112.08914#map=19/33.32792/-112.08914', 1)
    reload_database_sourced_as_osm_url('bridleway', 'http://www.openstreetmap.org/?mlat=53.2875&mlon=-1.5254#map=15/53.2875/-1.5254', 1)
    reload_database_sourced_as_osm_url('vineyards', 'http://www.openstreetmap.org/?mlat=48.08499&mlon=7.64856#map=19/48.08499/7.64856', 0.8)
    reload_database_sourced_as_osm_url('monte_lozzo', 'http://www.openstreetmap.org/?mlat=45.2952&mlon=11.6215#map=14/45.2952/11.6215', 0.8)
    reload_database_sourced_as_osm_url('danube_sinkhole', 'https://www.openstreetmap.org/?mlat=47.932173&mlon=8.763528&zoom=16#map=16/47.9337/8.7667', 1)
    reload_database_using_mapzen_extract('warsaw', 'warsaw_poland')
    reload_database_using_mapzen_extract('new_york', 'new-york_new-york')
  end

  def create_databases
    create_new_gis_database('gis')
    create_new_gis_database('gis_test')
    get_list_of_databases.each {|database|
      create_new_gis_database(database[:name])
    }
  end

  def get_list_of_databases
    databases = []
    # https://github.com/mapzen/metroextractor-cities/blob/master/cities.json
    # TODO - it is quickly bitrotting as result of changes, including ones that affect existing extract names/ranges
    # this should be generated from this file
    databases << { top: 50.240, left: 19.594, bottom: 49.850, right: 20.275, name: 'krakow' }
    databases << { top: 48.06673, left: 11.82377, bottom: 47.06673, right: 12.82377, name: 'well_mapped_rocky_mountains' }
    databases << { top: 42.130, left: 12.109, bottom: 41.578, right: 12.845, name: 'rome' }
    databases << { top: 48.386, left: 16.137, bottom: 48.048, right: 16.714, name: 'vienna' }
    databases << { top: 5.523, left: -4.183, bottom: 5.220, right: -3.849, name: 'abidjan_ivory_coast' }
    databases << { top: 33.82792, left: -112.5891, bottom: 32.82792, right: -111.5891, name: 'south_mountain' }
    databases << { top: 51.984, left: -1.115, bottom: 50.941, right: 0.895, name: 'london' }
    databases << { top: 64.297, left: -22.826, bottom: 63.771, right: -21.140, name: 'reykjavik' }
    databases << { top: 48.32989, left: 11.57764, bottom: 47.32989, right: 12.57764, name: 'rosenheim' }
    databases << { top: 54.06360, left: -0.86369, bottom: 53.66360, right: -0.46369, name: 'market' }
    databases << { top: 36.558, left: 138.779, bottom: 34.867, right: 141.152, name: 'tokyo' }
    databases << { top: 9.246, left: 7.248, bottom: 8.835, right: 7.717, name: 'abuja_nigeria' }
    databases << { top: 5.675, left: -0.437, bottom: 5.475, right: -0.071, name: 'accra_ghana' }
    databases << { top: 53.7875, left: -2.0254, bottom: 52.7875, right: -1.0254, name: 'bridleway' }
    databases << { top: 48.48499, left: 7.24856, bottom: 47.68499, right: 8.04856, name: 'vineyards' }
    databases << { top: 45.6952, left: 11.2215, bottom: 44.8952, right: 12.0215, name: 'monte_lozzo' }
    databases << { top: 48.4337, left: 8.2667, bottom: 47.4337, right: 9.2667, name: 'danube_sinkhole' }
    databases << { top: 41.097, left: -74.501, bottom: 40.345, right: -73.226, name: 'new_york' }
    databases << { top: 52.623, left: 20.341, bottom: 51.845, right: 21.692, name: 'warsaw' }
=begin
    databases << {:top => , :left => , :bottom => , :right => , :name => ''}
=end
    return databases
  end

  def before_after_from_loaded_databases(tags, to, from, zlevels, image_size = 375, count = 3, skip = 0)
    get_list_of_databases.each {|database|
      return true if count <= 0
      if skip > 0
        skip -= 1
        next
      end
      max_range_in_km_for_radius = 400
      lat = (database[:top] + database[:bottom]) / 2
      lon = (database[:left] + database[:right]) / 2
      found = false
      ['node', 'way'].each {|type|
        begin
          latitude, longitude = OverpassQueryGenerator.locate_element_with_given_tags_and_type tags, type, lat, lon, max_range_in_km_for_radius
          if latitude > database[:bottom] && latitude < database[:top] && longitude > database[:left] && longitude < database[:right]
            description = "#{database[:name]} - #{VisualDiff.dict_to_pretty_tag_list(tags)} [#{latitude}, #{longitude}] #{type}"
            before_after_directly_from_database(database[:name], latitude, longitude, to, from, zlevels, image_size, description)
            found = true
          end
        rescue OverpassQueryGenerator::NoLocationFound, OverpassDownloader::OverpassRefusedResponse
          puts 'No nearby instances of tags and tag is not extremely rare - no generation of nearby location and wordwide search was impossible. No diff image will be generated for this location.'
        end
      }
      count -= 1 if found
    }
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
    tags.each { |key, value|
      compare_presense_of_tag(branch, old_branch, key, value)
    }
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

  def create_new_gis_database(name)
    puts "Creating gis dayabase <#{name}>"
    command = "createdb #{name}"
    system command
    command = "psql -d #{name} -c 'CREATE EXTENSION hstore; CREATE EXTENSION postgis;'"
    system command
  end

  def switch_databases(new_name_for_gis, switched_into_for_gis)
    command = "echo \"alter database gis rename to #{new_name_for_gis};
alter database #{switched_into_for_gis} rename to gis;
\\q\" | psql postgres > /dev/null"
    puts "gis -> #{new_name_for_gis}, #{switched_into_for_gis} -> gis"
    system command
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
    zlevels.each {|zlevel|
      cache_filename = make_image_from_loaded_database(branch, latitude, longitude, zlevel, image_size, branch)
      collection.push(ImageForComparison.new(cache_filename, "z#{zlevel}"))
    }
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

  def visualise_changes_on_real_data_pair(tags_a, tags_b, type_a, type_b, latitude, longitude, zlevels, new_branch, old_branch, image_size)
    # TODO: - what about neraby nodes? is it also going to work?
    latitude, longitude = OverpassQueryGenerator.find_data_pair(tags_a, tags_b, latitude, longitude, type_a, type_b)
    return false if latitude.nil?
    header = "#{latitude} #{longitude} - #{VisualDiff.dict_to_pretty_tag_list(tags_a)} near #{VisualDiff.dict_to_pretty_tag_list(tags_b)}"
    VisualDiff.visualise_changes_for_location(latitude, longitude, zlevels, header, new_branch, old_branch, 0.4, image_size)
    return true
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
end

def load_remote_file(url, clear_cache = False)
  CartoCSSHelper.download_remote_file(url, clear_cache)
  filename = CartoCSSHelper.get_place_of_storage_of_resource_under_url(url)
  scene = CartoCSSHelper::VisualDiff::FileDataSource.new(nil, nil, 0.3, filename)
  scene.load
end
