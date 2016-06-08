# frozen_string_literal: true
module CartoCSSHelper
  def loaded_database_centers(skip)
    Enumerator.new do |yielder|
      get_list_of_databases.each do |database|
        if skip > 0
          skip -= 1
          next
        end
        lat, lon = get_database_center(database)
        yielder.yield lat, lon
      end
    end
  end

  class LocatePairedTagsInsideLoadedDatabases
    def initialize(tags_a, tags_b, type_a, type_b, skip)
      seed_generator = loaded_database_centers(skip)
      locator = LocatePairedTags.new(tags_a, tags_b, type_a, type_b, seed_generator)
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
    def initialize(_tags_a, _tags_b, _type_a, _type_b, skip)
      seed_generator = loaded_database_centers(skip)
      locator = LocateTags.new(tags, seed_generator)
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
          # puts "#{latitude} #{longitude}"
          get_list_of_databases.each do |database|
            next unless fits_in_database_bb?(database, latitude, longitude)
            puts "#{latitude} #{longitude} is inside #{database[:name]}"
            yielder.yield latitude, longitude
            next
          end
        end
      end
    end

    def description
      @inner.description
    end
 end

  # blatant DRY violation with locate_tags_inside_loaded_database
  class LocatePairedTags
    def initialize(tags_a, tags_b, type_a, type_b, seed_generator)
      @tags_a = tags_a
      @tags_b = tags_b
      @type_a = type_a
      @type_b = type_b
      @seed_generator = seed_generator
    end

    def locator
      Enumerator.new do |yielder|
        loop do
          lat, lon = @seed_generator.next
          ['node', 'way'].each do |_type|
            latitude, longitude = OverpassQueryGenerator.find_data_pair(@tags_a, @tags_b, lat, lon, @type_a, @type_b)
            next if latitude.nil?
            yielder.yield latitude, longitude
          end
        end
      end
    end

    def description
      return VisualDiff.dict_to_pretty_tag_list(@tags_a) + @type_a + VisualDiff.dict_to_pretty_tag_list(@tags_b) + @type_b
    end
  end

  class LocateTags
    def initialize(tags, seed_generator)
      @tags = tags
      @seed_generator = seed_generator
    end

    def locator
      Enumerator.new do |yielder|
        max_range_in_km_for_radius = 400
        loop do
          lat, lon = @seed_generator.next
          ['node', 'way'].each do |type|
            latitude, longitude = OverpassQueryGenerator.locate_element_with_given_tags_and_type @tags, type, lat, lon, max_range_in_km_for_radius
            yielder.yield latitude, longitude
          end
        end
      end
    end

    def description
      return VisualDiff.dict_to_pretty_tag_list(tags)
    end
  end

  def get_database_center(database)
    lat = (database[:top] + database[:bottom]) / 2
    lon = (database[:left] + database[:right]) / 2
    return lat, lon
  end
end
