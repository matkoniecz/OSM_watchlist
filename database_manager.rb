# frozen_string_literal: true
module CartoCSSHelper
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
end
