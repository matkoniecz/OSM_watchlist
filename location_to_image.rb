# frozen_string_literal: true
module CartoCSSHelper
  def diff_on_loaded_database(location_provider:, to:, from: 'master', zlevels:, image_size: 375, count: 2)
    locator = location_provider.locator
    count.times do
      latitude, longitude = locator.next
      puts latitude, longitude
      get_list_of_databases.each do |database|
        if fits_in_database_bb?(database, latitude, longitude)
          description = "#{database[:name]} - #{location_provider.description} [#{latitude}, #{longitude}]"
          before_after_directly_from_database(database[:name], latitude, longitude, to, from, zlevels, image_size, description)
        end
      end
    end
  end

  def diff_on_overpass_data(location_provider:, to:, from: 'master', zlevels:, image_size: 375, count: 2)
    locator = location_provider.locator
    count.times do
      latitude, longitude = locator.next
      puts latitude, longitude
      header = "#{database[:name]} - #{location_provider.description} [#{latitude}, #{longitude}]"
      VisualDiff.visualise_changes_for_location(latitude, longitude, zlevels, header, to, from, 0.4, image_size)
    end
  end
end
