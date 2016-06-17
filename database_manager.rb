# frozen_string_literal: true
require_relative 'database_manager_mapzen.rb'
require_relative 'database_manager_psql_handler.rb'

module CartoCSSHelper
  def reload_database_sourced_as_osm_url(database_name, url, download_bbox_size)
    switch_databases('gis_test', database_name)
    # TODO: - is it really flushing cache without manually deleting overpass cache?
    CartoCSSHelper.visualise_place_by_url(url, 19..19, 'master', 'master', nil, download_bbox_size, 35)
    switch_databases(database_name, 'gis_test')
  end

  def reload_databases
    mapzen_databases.each do |entry|
      reload_database_using_mapzen_extract(entry[:database_name], entry[:mapzen_name])
    end

    osm_link_databases.each do |entry|
      reload_database_sourced_as_osm_url(entry[:database_name], entry[:link], entry[:size])
    end
  end

  def create_databases
    create_new_gis_database('gis')
    create_new_gis_database('gis_test')
    get_list_of_databases.each do |database|
      create_new_gis_database(database[:name])
    end
  end

  def get_list_of_databases
    databases = []
    mapzen_databases.each do |entry|
      databases << bbox_from_mapzen_data(entry[:database_name], entry[:mapzen_name])
    end
    databases << { top: 33.82792, left: -112.5891, bottom: 32.82792, right: -111.5891, name: 'south_mountain' }
    databases << { top: 48.32989, left: 11.57764, bottom: 47.32989, right: 12.57764, name: 'rosenheim' }
    databases << { top: 54.06360, left: -0.86369, bottom: 53.66360, right: -0.46369, name: 'market' }
    databases << { top: 53.7875, left: -2.0254, bottom: 52.7875, right: -1.0254, name: 'bridleway' }
    databases << { top: 48.48499, left: 7.24856, bottom: 47.68499, right: 8.04856, name: 'vineyards' }
    databases << { top: 45.6952, left: 11.2215, bottom: 44.8952, right: 12.0215, name: 'monte_lozzo' }
    databases << { top: 48.4337, left: 8.2667, bottom: 47.4337, right: 9.2667, name: 'danube_sinkhole' }

    databases.insert(1, { top: 48.06673, left: 11.82377, bottom: 47.06673, right: 12.82377, name: 'well_mapped_rocky_mountains' })
    return databases
  end

  def mapzen_databases
    return [
      # TODO: - databases should be registered or something, not hardcoded
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

  def add_mapzen_extract(database_name, mapzen_extract_name)
    create_new_gis_database(database_name)
    reload_database_using_mapzen_extract(database_name, mapzen_extract_name)
    puts "remember to add its entry to mapzen_databases\n" * 20
  end

  def osm_link_databases
    return [
      { database_name: 'well_mapped_rocky_mountains', link: 'https://www.openstreetmap.org/#map=/47.56673/12.32377', size: 1 }, # footways on natural=bare_rock

      { database_name: 'market', link: 'https://www.openstreetmap.org/#map=/53.86360/-0.66369', size: 0.4 },
      { database_name: 'rosenheim', link: 'https://www.openstreetmap.org/#map=/47.82989/12.07764', size: 1 },
      { database_name: 'south_mountain', link: 'https://www.openstreetmap.org/#map=/33.32792/-112.08914', size: 1 },
      { database_name: 'bridleway', link: 'https://www.openstreetmap.org/#map=/53.2875/-1.5254', size: 1 },
      { database_name: 'vineyards', link: 'https://www.openstreetmap.org/#map=/48.08499/7.64856', size: 0.8 },
      { database_name: 'monte_lozzo', link: 'https://www.openstreetmap.org/#map=/45.2952/11.6215', size: 0.8 },
      { database_name: 'danube_sinkhole', link: 'https://www.openstreetmap.org/#map=/47.9337/8.7667', size: 1 },
    ]
  end

  def verify
    osm_link_databases.each do |entry|
      get_list_of_databases.each do |split|
        next unless split[:name] == entry[:database_name]
        size = split[:top] - split[:bottom]
        puts size
        size = split[:right] - split[:left]
        puts size
        central_lat = ((split[:top] + split[:bottom]) / 2)
        central_lon = ((split[:right] + split[:left]) / 2)
        link = "https://www.openstreetmap.org/#map=/#{central_lat.round(5)}/#{central_lon.round(5)}"
        next unless entry[:link] != link
        puts entry[:link]
        puts link
        puts "mismatch"
      end
    end
  end

  def fits_in_database_bb?(database, latitude, longitude)
    return false if latitude < database[:bottom]
    return false if latitude > database[:top]
    return false if longitude < database[:left]
    return false if longitude > database[:right]
    return true
  end

  def get_database_containing(latitude, longitude)
    get_list_of_databases.each do |database|
      return database if fits_in_database_bb?(database, latitude, longitude)
    end
    return nil
  end
end
