# frozen_string_literal: true
def test_forest
  CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test({ 'natural' => 'valley', 'landuse' => 'forest' }, 'closed_way', false, 22..22, 'forest', 'master')

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'natural' => :any_value, 'landuse' => 'forest' })
  diff_on_loaded_database(location_provider: locator, to: 'forest', from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocateTags.new({ 'natural' => :any_value, 'landuse' => 'forest' })
  diff_on_loaded_database(location_provider: locator, to: 'forest', from: 'master', zlevels: 15..19, image_size: 375, count: 6)

  locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'natural' => 'wood' })
  diff_on_loaded_database(location_provider: locator, to: 'forest', from: 'master', zlevels: 15..19, image_size: 375, count: 6)
end

def debris
  get_all_road_types.each do |highway|
    puts highway
    before_after_from_loaded_databases({ 'highway' => highway, 'ref' => :any_value }, 'nebulon/road-shields', 'master', 13..22, 1000, 5)
  end
end
