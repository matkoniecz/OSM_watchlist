# frozen_string_literal: true
require_relative 'database_manager.rb'

module CartoCSSHelper
  def reload_database_using_mapzen_extract(database_name, mapzen_extract_name)
    switch_databases('gis_test', database_name)
    load_remote_file("https://s3.amazonaws.com/metro-extracts.mapzen.com/#{mapzen_extract_name}.osm.pbf", true)
    switch_databases(database_name, 'gis_test')
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

  def mapzen_database_data(mapzen_name)
    json_describing_mapzen_databases.each do |city|
      return city[1]["bbox"] if city[0] == mapzen_name
    end
    raise "not found"
  end

  def bbox_from_mapzen_data(database_name, mapzen_name)
    bbox = mapzen_database_data(mapzen_name)
    return { top: bbox["top"].to_f, left: bbox["left"].to_f, bottom: bbox["bottom"].to_f, right: bbox["right"].to_f, name: database_name }
  end
end
