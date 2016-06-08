# frozen_string_literal: true
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

  def mapzen_databases
    return [
      { database_name: 'krakow', mapzen_name: 'krakow_poland' },
      { database_name: 'rome', mapzen_name: 'rome_italy' },
      { database_name: 'vienna', mapzen_name: 'vienna_austria' },
      { database_name: 'abidjan_ivory_coast', mapzen_name: 'abidjan_ivory-coast' },
      { database_name: 'london', mapzen_name: 'london_england' },
      { database_name: 'reykjavik', mapzen_name: 'reykjavik_iceland' },
      { database_name: 'tokyo', mapzen_name: 'tokyo_japan' },
      { database_name: 'abuja_nigeria', mapzen_name: 'abuja_nigeria' },
      { database_name: 'accra_ghana', mapzen_name: 'accra_ghana' },
      # {:database_name => 'new_york', :mapzen_name =>'new-york_new-york'},
      # {:database_name => 'warsaw', :mapzen_name =>'warsaw_poland'},
    ]
  end

  def reload_databases
    mapzen_databases.each do |entry|
      reload_database_using_mapzen_extract(entry[:database_name], entry[:mapzen_name])
    end

    # footways on natural=bare_rock
    reload_database_sourced_as_osm_url('well_mapped_rocky_mountains', 'http://www.openstreetmap.org/?mlat=47.56673&mlon=12.32377#map=19/47.56673/12.32377', 1)

    reload_database_sourced_as_osm_url('market', 'http://www.openstreetmap.org/#map=19/53.86360/-0.66369', 0.4)
    reload_database_sourced_as_osm_url('rosenheim', 'http://www.openstreetmap.org/?mlat=47.82989&mlon=12.07764#map=19/47.82989/12.07764', 1)
    reload_database_sourced_as_osm_url('south_mountain', 'http://www.openstreetmap.org/?mlat=33.32792&mlon=-112.08914#map=19/33.32792/-112.08914', 1)
    reload_database_sourced_as_osm_url('bridleway', 'http://www.openstreetmap.org/?mlat=53.2875&mlon=-1.5254#map=15/53.2875/-1.5254', 1)
    reload_database_sourced_as_osm_url('vineyards', 'http://www.openstreetmap.org/?mlat=48.08499&mlon=7.64856#map=19/48.08499/7.64856', 0.8)
    reload_database_sourced_as_osm_url('monte_lozzo', 'http://www.openstreetmap.org/?mlat=45.2952&mlon=11.6215#map=14/45.2952/11.6215', 0.8)
    reload_database_sourced_as_osm_url('danube_sinkhole', 'https://www.openstreetmap.org/?mlat=47.932173&mlon=8.763528&zoom=16#map=16/47.9337/8.7667', 1)
  end

  def create_databases
    create_new_gis_database('gis')
    create_new_gis_database('gis_test')
    get_list_of_databases.each do |database|
      create_new_gis_database(database[:name])
    end
  end

  def raw_json_describing_mapzen_databases
    # https://github.com/mapzen/metroextractor-cities/blob/master/cities.json
    url = 'https://raw.githubusercontent.com/mapzen/metroextractor-cities/master/cities.json'
    clear_cache = false
    CartoCSSHelper.download_remote_file(url, clear_cache)
    filename = CartoCSSHelper.get_place_of_storage_of_resource_under_url(url)
    json_string = ''
    File.open(filename, "r") do |file|
      json_string = file.read
    end
    require 'json'
    obj = JSON.parse(json_string)
    return obj
  end

  def json_describing_mapzen_databases
    returned = []
    raw_json_describing_mapzen_databases['regions'].each do |region|
      region[1]['cities'].each do |city|
        returned << city
      end
    end
    return returned
  end

  def mapzen_database_data(database_name, mapzen_name)
    json_describing_mapzen_databases.each do |city|
      if city[0] == mapzen_name
        bbox = city[1]["bbox"]
        return { top: bbox["top"].to_f, left: bbox["left"].to_f, bottom: bbox["bottom"].to_f, right: bbox["right"].to_f, name: database_name }
      end
    end
    raise "not found"
  end

  def get_list_of_databases
    databases = []
    mapzen_databases.each do |entry|
      databases << mapzen_database_data(entry[:database_name], entry[:mapzen_name])
    end
    databases << { top: 33.82792, left: -112.5891, bottom: 32.82792, right: -111.5891, name: 'south_mountain' }
    databases << { top: 48.32989, left: 11.57764, bottom: 47.32989, right: 12.57764, name: 'rosenheim' }
    databases << { top: 54.06360, left: -0.86369, bottom: 53.66360, right: -0.46369, name: 'market' }
    databases << { top: 53.7875, left: -2.0254, bottom: 52.7875, right: -1.0254, name: 'bridleway' }
    databases << { top: 48.48499, left: 7.24856, bottom: 47.68499, right: 8.04856, name: 'vineyards' }
    databases << { top: 45.6952, left: 11.2215, bottom: 44.8952, right: 12.0215, name: 'monte_lozzo' }
    databases << { top: 48.4337, left: 8.2667, bottom: 47.4337, right: 9.2667, name: 'danube_sinkhole' }

    databases.insert(1, { top: 48.06673, left: 11.82377, bottom: 47.06673, right: 12.82377, name: 'well_mapped_rocky_mountains' })
=begin
    databases << {:top => , :left => , :bottom => , :right => , :name => ''}
=end
    return databases
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
