# Encoding: utf-8
# frozen_string_literal: true
require_relative 'require.rb'
require_relative 'watchlist.rb'
require_relative 'tag_analysis_for_streetcomplete.rb'
require_relative 'deferred.rb'

include CartoCSSHelper

# sudo service postgresql restart
def make_copy_of_repository
  false # true #false
end

def test_placename(branch, z_levels = 4..11)
  coords = [[50, 20, "KRK"], [53.245, -2.274, "UK"],
            [60.6696, -139.2532, "Kluane National park"],
            [-22.3276, 23.8453, "Central Kalahari Game Reserve"],
            [-24.56237, 15.33238, "Namib National Park"],
            [37.43834, -111.58082, "Grand Staircase USA"],
            [34.56186, -115.21428, "Mojave"],
            [39.1205, -94.4913],
            [16.820, 79.915],
            [64.1173, -21.8688],
            [50, 80],
            [50, 100]]
  iterate_over(branch, branch, z_levels, coords)
  iterate_over(branch, 'master', z_levels, coords)
end

module CartoCSSHelper
  def analyse_import_tags
    area_name = "Massachusetts"
    query = '[out:json];relation[boundary=administrative][type!=multilinestring][name=' + area_name + '];out;'
    explanation = 'fetching ' + area_name + ' data'
    json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
    parsed = JSON.parse(json_string)
    tags = [
      #'massgis:FEE_OWNER', 'Owner or grantor of the land represented by the polygon' so not convertible to OSM tags without research that is not worth the effort
      #'massgis:TOWN_ID', - 99% are numbers, other cases are ;-separated numbers, it is basically is_in in special format so not worth keeping
      #'massgis:OWNER_TYPE', - one letter codes, useless without documentation
      #'massgis:FEESYM', - codes, useless without documentation
      #'massgis:EOEAINVOLV', - mysterious and bizarre, useless without documentation
      #'massgis:FY_FUNDING', - funding date (?), useless if that guess is true, useless without documentation
      #'massgis:ATT_DATE', 'Date attributes were last modifed.' - useless metadata from external database
      #'massgis:LEV_PROT', - 'Code for the level of protection given to the land.' - with values: perpetuity (P), term limited (T), limited (L). I see no value here.
      #'massgis:DEED_ACRES', - area is provided by geometry itself in OSM
      #'massgis:OS_DEED_BO', - 'The book that the deed was recorded in on CAL_DATE_REC.' - useless
      #'massgis:OS_DEED_PA', - 'The page of OS_DEED_BOOK that the deed was recorded in.' - useless
      #'massgis:ASSESS_ACR', - 'Acreage of polygon according to local assessor.', again OSM stores area in geometry itself
      #'massgis:SHAPE_AREA', #numbers that probably represent area of feature what is not useful in OSM
      #'massgis:ACRES', #numbers that probably represent area of feature what is not useful in OSM
      #'massgis:OS_ID', # 'Unique ID for feature class ([TOWN_ID]-[POLY_ID]).' - useless
      #'massgis:OWNER_ABRV', # 'Abbreviation of FEE_OWNER kept in OSNAMES table.' - useless
      #'massgis:SOURCE_MAP', # 'Source map used to enter linework/attributes.' - useless
      #'massgis:ASSESS_MAP', # 'Local Assessor’s Map.' - useless
      #'massgis:ASSESS_LOT', # 'Local Assessor’s Lot.' - useless
      #'massgis:BASE_MAP', # 'Recompilation map name/type.' - useless

      #'massgis:IT_VALC', # short codes with unknown meaning, useless with documentation, probably useless anyway I found potential match but it was not helpful - 'Wetland label abbreviations' as listed in http://www.mass.gov/anf/research-and-tech/it-serv-and-support/application-serv/office-of-geographic-information-massgis/datalayers/wetchange.html 
      #'massgis:way_id', # 99% are numbers, other cases are ;-separated numbers - useless id
      #'massgis:OLI_1_INT', #always value is "CR" or "APR"
      #'massgis:INTSYM', #always value is "CR" or "APR"
      #'massgis:OLI_1_ORG', #human readable values
      #'massgis:OLI_2_ORG', #human readable values
      #'massgis:OLI_1_TYPE', values are always "S", "L" or "M"
      #'massgis:OLI_2_TYPE', #values are always "S", "L" or "M"
      #'massgis:OLI_1_ABRV', #some text codes, without obvious meaning
      #'massgis:OLI_2_ABRV', #some text codes, without obvious meaning
      #'massgis:ASSESS_BLK', #'Local Assessor’s Block.' - sounds useless, YA another internal id

      #'massgis:SHAPE_LEN', #numbers
      #'massgis:GRANTTYPE1', #values are always "S" or "F"
      'massgis:GRANTPROG1',
      'massgis:SOURCE_TYP',
      #'massgis:SOURCE_ACC', #value is always "3"
      'massgis:CAL_DATE_R',
      'massgis:ASSESS_SUB',
      'massgis:PROJ_ID1', # yet another internal id
      'massgis:PROJ_ID2',
      'massgis:LOC_ID', # 'Link to MassGIS Standard Parcel data (LOC_ID).' - yet another useless id
      'massgis:geom_id',
      'massgis:OLI_2_INT',
      'massgis:BOND_ACCT',
      'massgis:MANAGR_ABR',
      #'massgis:MANAGR_TYP', value is always "M"
      'massgis:UseType',
      'massgis:Sequence',
      'massgis:PicLink',
      'massgis:HistLink',
      'massgis:TypeCode',
      'massgis:GRANTPROG2',
      'massgis:GRANTTYPE2',
      'massgis:GridNum',
      'massgis:NameOffc',
      'massgis:BanCod',
      'massgis:Address',
      'massgis:FAACS',
      'massgis:StName',
      'massgis:StType',
      'massgis:id',
      'massgis:NameFamil',
      'massgis:PROJ_ID3',
      'massgis:Name',
      'massgis:TOTAL',
      'massgis:TIME_',
      'massgis:DAY_',
      'massgis:OBJECTID_2',
      'massgis:Shape_Le_1',
      'massgis:HNC',
      'massgis:F_S_D',
      'massgis:S_V',
      'massgis:RES',
      'massgis:OBJECTID_1',
      'massgis:UNLD',
      'massgis:MC',
      'massgis:F_S',
      'massgis:OFC',
      'massgis:PER',
      'massgis:OID_',
      'massgis:Shape_Area',
      'massgis:Shape_Leng',
      'massgis:VIS',
      'massgis:StNumsfx',
      'massgis:Type',
      'massgis:Surface',
      'massgis:NAME_1',
      'massgis:OLI_3_INT',
      'massgis:OLI_3_ABRV',
      'massgis:OLI_3_ORG',
      'massgis:OLI_3_TYPE',
      'massgis:DisplayNam',
      'massgis:StPrfx',
      'massgis:town_id',
      'massgis:fourcolor',
      'massgis:landuse',


      'massgis:MAP_ID',
      'massgis:PWSID',
      'massgis:SITE_ADDR',
      'massgis:PALIS_ID',
      'massgis:OBJECTID',
      'massgis:POLY_CODE',
      'massgis:SOURCE_SCA',
      'massgis:DCAM_ID',
      'massgis:ARTICLE97',
      'massgis:POLY_ID',
      ]
=begin
  
    tags.each do |key|
      query = filter_across_named_region("['#{key}']", area_name)
      explanation = "analysis of #{key} in #{area_name}"
      puts "obtaining raw string - #{explanation}"
      json_string = CartoCSSHelper::OverpassQueryGenerator.get_overpass_query_results(query, explanation)
    end
=end

    tags.each do |tag|
      value_distribution_for_each_territory(parsed, tag).each do |entry|
        show_stats(entry[:stats], tag + " in " + area_name)
      end
    end
  end


  def main
    analyse_import_tags
    #tactile_paving_stats #TODO idea - make an actionable list (load what SC allows, compare to outputs, output diff)
    #bikeway_stats
    run_watchlist
    return
    final

    generate_preview('master')
    locator = CartoCSSHelper::LocateTagsInsideLoadedDatabases.new({ 'amenity' => 'pub', 'name' => :any_value }, skip: 0)
    diff_on_loaded_database(location_provider: locator, to: 'noto_710', from: 'master', zlevels: 16..18, image_size: 700, count: 1)
    run_tests
    final

    CartoCSSHelper::Configuration.set_renderer(:kosmtik)
    location = [[49.91002, -122.78525, "pnorman example"], [49.0907, 22.5646, "Bieszczady"], [37.41499, -111.55294, "staircase"]]

    iterate_over('dissolve_national_parks_proof_of_concept', 'master', 7..14, location)
    # iterate_over('case_nightmare_green', 'master', 7..10, [[38.122, -110.237, "staircase"]])

    CartoCSSHelper::Configuration.set_renderer(:kosmtik)
    test_710_variants(1)

    final

    # wat(50, 20)
    # wat(51.5, 0)
    # wat(0, 0)

    test_placename('wat', 7..12)
    # test_placename('gradual_forest', 6..12)

    puts "-----"
    test_710_variants(10)
    test_710_variants(15)
    test_710_variants(5)

    # show_military_danger_areas('danger')
    # execute_command("echo \"layer, time, sample, branch\" > tested_file.txt", true)
    # compare_time('master', 'speedtest', 5, 'new_data.txt')
    # test_office(15, 'master')
    # railway_station_areas_label('area_station')
    # CartoCSSHelper.add_mapzen_extract('las_vegas', 'las-vegas_nevada')
    # CartoCSSHelper.add_mapzen_extract('ateny', 'athens_greece')

    final

    CartoCSSHelper::VisualDiff.enable_job_pooling
    CartoCSSHelper::VisualDiff.shuffle_jobs(8)
    CartoCSSHelper::VisualDiff.run_jobs
  end
end

def wat(lat, lon)
  puts "master"
  get_single_image_from_database('entire_world', 'master', lat, lon, 6, 298)
  puts
  puts

  puts "layerless"
  get_single_image_from_database('entire_world', 'layerless', lat, lon, 6, 298)
  puts
  puts
end

def switch_to_database(name)
  init(false) # frozen copy making
  switch_databases('gis_test', name)
  final
end

# sudo service postgresql restart
def switch_database
  # switch_to_database('entire_world')
  # switch_to_database('krakow')

  # create_new_gis_database('new_gis')
  # CartoCSSHelper::DataFileLoader.load_data_into_database("/home/mateusz/Downloads/export.osm", true)
  # switch_databases('placenames', 'new_gis')
end

# TODO:
# https://github.com/gravitystorm/openstreetmap-carto/issues/assigned/matkoniecz

def waiting_pr
  obelisk('obelisk')
end

def test_water_color
  # https://github.com/gravitystorm/openstreetmap-carto/issues/1781 - tweaking water colour
  # TODO - from world database
  before_after_from_loaded_databases({ 'waterway' => 'river' }, 'water', 'master', 9..19, 1000)
  before_after_from_loaded_databases({ 'waterway' => 'stream' }, 'water', 'master', 9..19, 1000)
  before_after_from_loaded_databases({ 'waterway' => 'ditch' }, 'water', 'master', 9..19, 1000)
  before_after_from_loaded_databases({ 'waterway' => 'riverbank' }, 'water', 'master', 9..19, 1000)

  before_after_from_loaded_databases({ 'natural' => 'coastline' }, 'water', 'master', 9..19, 1000)
end

def database_cleaning
  create_databases
  reload_databases
end

# see deferred.rb

run_and_report_the_end
