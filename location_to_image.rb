# frozen_string_literal: true
require_relative 'database_manager'

module CartoCSSHelper
  def diff_on_loaded_database(location_provider:, to:, from: 'master', zlevels:, image_size: 375, count: 2)
    locator = location_provider.locator
    begin
      count.times do
        latitude, longitude = locator.next
        puts latitude, longitude
        database = get_database_containing(latitude, longitude)
        unless try_to_render(location_provider: location_provider, database: database, latitude: latitude, longitude: longitude, to: to, from: from, zlevels: zlevels, image_size: image_size)
          puts "locator returned location outside any available loaded database"
        end
      end
    rescue StopIteration
      puts "Supply of places in the database exhausted for <#{location_provider.description}>"
    end
  end

  def try_to_render(location_provider:, database:, latitude:, longitude:, to:, from:, zlevels:, image_size:)
    if fits_in_database_bb?(database, latitude, longitude)
      description = "#{location_provider.description} on #{database[:name]} [#{latitude}, #{longitude}]"
      before_after_directly_from_database(database[:name], latitude, longitude, to, from, zlevels, image_size, description)
      return true
    end
    return false
  end

  def diff_on_overpass_data(location_provider:, to:, from: 'master', zlevels:, image_size: 375, count: 2)
    locator = location_provider.locator
    begin
      count.times do
        latitude, longitude = locator.next
        puts latitude, longitude
        description = "#{location_provider.description} on overpass data [#{latitude}, #{longitude}]"
        VisualDiff.visualise_changes_for_location(latitude, longitude, zlevels, description, to, from, 0.4, image_size)
      end
    rescue StopIteration
      puts "Supply of places in the database exhausted for <#{location_provider.description}>"
    end
  end
end
