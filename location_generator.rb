# frozen_string_literal: true
module CartoCSSHelper
  def land_locations(skip)
    n = 0
    Enumerator.new do |yielder|
      n += 1
      if skip > 0
        skip -= 1
      else
        lat, lon = CartoCSSHelper.get_nth_location(n)
        yielder.yield lat, lon
      end
    end
  end

  def loaded_database_centers(skip)
    Enumerator.new do |yielder|
      databases = get_list_of_databases.drop(skip)
      databases.each do |database|
        lat, lon = get_database_center(database)
        yielder.yield lat, lon
      end
    end
  end

  def get_database_center(database)
    lat = (database[:top] + database[:bottom]) / 2
    lon = (database[:left] + database[:right]) / 2
    return lat, lon
  end

  class RecordLocation
    def initialize(lat, lon)
      @lat = lat
      @lon = lon
    end

    def locator
      Enumerator.new do |yielder|
        yielder.yield @lat, @lon
      end
    end
  end

  class LocatePairedTagsInsideLoadedDatabases
    def initialize(tags_a, tags_b, type_a, type_b, skip: 0, distance_in_meters: 20)
      seed_generator = loaded_database_centers(skip)
      locator = LocatePairedTags.new(tags_a, tags_b, type_a, type_b, seed_generator, distance_in_meters: distance_in_meters)
      @inner = AllowOnlyLoadedAreas.new(location_provider: locator)
    end

    def locator
      @inner.locator
    end

    def description
      @inner.description
    end
  end

  class LocateTagsInsideLoadedDatabases
    def initialize(tags, skip: 0, types: ['node', 'way'])
      seed_generator = loaded_database_centers(skip)
      locator = LocateTags.new(tags, seed_generator, types)
      @inner = AllowOnlyLoadedAreas.new(location_provider: locator)
    end

    def locator
      @inner.locator
    end

    def description
      @inner.description
    end
  end

  class AllowOnlyLoadedAreas
    def initialize(location_provider:)
      @inner = location_provider
    end

    def locator
      inner_locator = @inner.locator
      Enumerator.new do |yielder|
        loop do
          latitude, longitude = inner_locator.next
          if get_database_containing(latitude, longitude) != nil
            yielder.yield latitude, longitude
          end
        end
      end
    end

    def description
      @inner.description
    end
  end

  class LocatePairedTags
    def initialize(tags_a, tags_b, type_a, type_b, seed_generator = land_locations, distance_in_meters: 20)
      @tags_a = tags_a
      @tags_b = tags_b
      @type_a = type_a
      @type_b = type_b
      @seed_generator = seed_generator
      @distance_in_meters = distance_in_meters
    end

    def locator
      Enumerator.new do |yielder|
        loop do
          begin
            lat, lon = @seed_generator.next
            latitude, longitude = OverpassQueryGenerator.find_data_pair(@tags_a, @tags_b, lat, lon, @type_a, @type_b, distance_in_meters: @distance_in_meters)
            next if latitude.nil?
            yielder.yield latitude, longitude
          rescue OverpassDownloader::OverpassRefusedResponse => e
            puts "Overpass refused response (#{e}, #{e.class})"
          rescue OverpassQueryGenerator::NoLocationFound => e
            puts "Overpass failed to find given tag (#{e}, #{e.class})"
          end
        end
      end
    end

    def description
      return VisualDiff.dict_to_pretty_tag_list(@tags_a) + " " + @type_a + " " + VisualDiff.dict_to_pretty_tag_list(@tags_b) + " " + @type_b
    end
  end

  class LocateTags
    def initialize(tags, seed_generator = land_locations, types = ['node', 'way'])
      @tags = tags
      @seed_generator = seed_generator
      @types = types
    end

    def locator
      Enumerator.new do |yielder|
        max_range_in_km_for_radius = 400
        loop do
          lat, lon = @seed_generator.next
          @types.each do |type|
            begin
              latitude, longitude = OverpassQueryGenerator.locate_element_with_given_tags_and_type @tags, type, lat, lon, max_range_in_km_for_radius
              yielder.yield latitude, longitude
            rescue OverpassDownloader::OverpassRefusedResponse => e
              puts "Overpass refused response (#{e}, #{e.class})"
            rescue OverpassQueryGenerator::NoLocationFound => e
              puts "Overpass failed to find given tag (#{e}, #{e.class})"
            end
          end
        end
      end
    end

    def description
      return VisualDiff.dict_to_pretty_tag_list(@tags)
    end
  end
end
