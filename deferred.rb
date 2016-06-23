def wrpped
  test_office(15, 'office')
  rescue => e
    puts "=====\n" * 20
    puts e
    puts "=====\n" * 20
  end

def test_office(n, branch)
  # https://github.com/gravitystorm/openstreetmap-carto/issues/1697 https://github.com/gravitystorm/openstreetmap-carto/issues/108

  # example of node http://www.openstreetmap.org/node/3042848835#map=19/50.02626/19.91366
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => :any_value })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'government' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'company' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'insurance' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'administrative' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  # https://github.com/gravitystorm/openstreetmap-carto/issues/1922
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'lawyer' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  # ?
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'yes' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'name' => :any_value, 'office' => 'estate' })
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 15..19, image_size: 375, count: n)
end

def aeroway_is_not_road
  branch = 'master'

  count = 5
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'aeroway' => 'taxiway', 'bridge' => 'yes' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'aeroway' => 'runway', 'bridge' => 'yes' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  skip = 0
  seed_generator = land_locations(skip)
  locator = CartoCSSHelper::LocateTags.new({ 'aeroway' => 'taxiway', 'bridge' => 'yes' }, seed_generator: seed_generator)
  diff_on_overpass_data(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)
  locator = CartoCSSHelper::LocateTags.new({ 'aeroway' => 'runway', 'bridge' => 'yes' }, seed_generator: seed_generator)
  diff_on_overpass_data(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  CartoCSSHelper.probe({ 'aeroway' => 'taxiway', 'bridge' => 'yes' }, branch, 'master')
  CartoCSSHelper.probe({ 'aeroway' => 'runway', 'bridge' => 'yes' }, branch, 'master')
  CartoCSSHelper.probe({ 'aeroway' => 'taxiway' }, branch, 'master')
  CartoCSSHelper.probe({ 'aeroway' => 'runway' }, branch, 'master')

  return

  count = 5
  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'aeroway' => 'taxiway' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'aeroway' => 'runway' }, skip: 0)
  diff_on_loaded_database(location_provider: locator, to: branch, from: 'master', zlevels: 16..19, image_size: 375, count: count)
end 
