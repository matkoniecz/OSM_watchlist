# frozen_string_literal: true
def generate_preview(branch, download_bbox_size = 0.05)
  bbox = get_openstreetmap_carto_preview_bbox
  width = 852
  height = 300
  zlevel = 15
  params = "--format=png --width=#{width} --height=#{height} --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
  project_name = CartoCSSHelper::Configuration.get_cartocss_project_name

  filename = "preview for readme #{download_bbox_size}.png"
  Git.checkout branch
  export_filename = Configuration.get_path_to_folder_for_branch_specific_cache + filename
  next if File.exist?(export_filename)
  latitude = (ymin + ymax) / 2
  longitude = (xmin + xmax) / 2
  osm_data_filename = OverpassQueryGenerator.get_file_with_downloaded_osm_data_for_location(latitude, longitude, download_bbox_size)
  DataFileLoader.load_data_into_database(osm_data_filename)

  command = "node /usr/share/tilemill/index.js export #{project_name} '#{export_filename}' #{params}"
  puts command
  system command

  source = Configuration.get_path_to_folder_for_branch_specific_cache + filename
  destination = Configuration.get_path_to_folder_for_output + "preview #{branch} #{download_bbox_size}.png"
  puts source
  puts destination
  raise 'file that should be created is not present' unless File.exist?(source)
  FileUtils.copy_entry source, destination, false, false, true
end

def get_openstreetmap_carto_preview_bbox
  top_lat = 41.8788
  lef_lon = -87.6515
  bottom_lat = 41.8693
  right_lon = -87.6150
  xmin = lef_lon
  ymin = bottom_lat
  xmax = right_lon
  ymax = top_lat
  bbox = "#{xmin},#{ymin},#{xmax},#{ymax}"
  #--bbox=[xmin,ymin,xmax,ymax]
  return bbox
end
