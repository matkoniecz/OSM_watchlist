# encoding: UTF-8
# frozen_string_literal: true
require 'rmagick'
require 'color'
include Magick

def is_present_in_list_of_hashs(list, key_searched, value_searched)
  not_found = true
  list.each do |tags|
    key = tags.keys[0]
    value = tags[key]
    if key == key_searched && value == value_searched
      not_found = false
      break
    end
  end
  return not_found
end

def search_for_missing_areas(branch, areas, zlevel, on_water)
  CartoCSSHelper::Git.checkout(branch)
  list_of_documented = CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_tags
  last_key = ''
  list_of_documented.each do |tag_info|
    next unless CartoCSSHelper::Info.rendered_on_zlevel({ tag_info.key => tag_info.value }, 'area', zlevel, on_water)
    not_found = is_present_in_list_of_hashs(areas, tag_info.key, tag_info.value)
    next unless not_found
    area = Scene.new({ tag_info.key => tag_info.value }, zlevel, on_water, 'area')
    node = Scene.new({ tag_info.key => tag_info.value }, zlevel, on_water, 'node')
    next unless area.is_output_different(node)
    if last_key != tag_info.key
      puts
      puts "#{last_key}.each{ |value|
returned.push({'#{last_key}' => value, 'name' => value})
}"
      puts
      print "#{tag_info.key} = ["
      last_key = tag_info.key
    end
    print "'#{tag_info.value}', "
  end
end

def get_dominant_color(filename, neutral_color = nil)
  image = ImageList.new(filename)
  colors = {}
  (0..133).each do |delta|
    pixel = image.pixel_color(33 + delta, 33 + delta)
    unless neutral_color.nil?
      next if pixel == neutral_color
    end
    colors[pixel] = 0 if colors[pixel].nil?
    colors[pixel] += 1
  end
  return neutral_color if colors == {}
  return colors.key(colors.values.max)
end

def pixel_to_color_RGB(pixel)
  r = pixel.red / 256
  g = pixel.green / 256
  b = pixel.blue / 256
  return Color::RGB.from_fraction(r.to_f / 256, g.to_f / 256, b.to_f / 256)
end

def get_dominant_colors(branch, tags, zlevel, on_water, type, folder = nil)
  CartoCSSHelper::Git.checkout(branch)
  s = Scene.new({}, zlevel, on_water, type)
  ground_color = get_dominant_color(s.get_image_filename)
  list_of_tags_and_dominant_color = []
  tags.each do |tag|
    # puts tag
    s = Scene.new(tag, zlevel, on_water, type)
    cache_filename = s.get_image_filename
    folder = if folder.nil?
               ''
             else
               folder + '/'
             end
    name = ''
    (0..(tag.keys.length - 1)).each do |i|
      key = tag.keys[i]
      value = tag[key]
      next if key == 'area' || key == 'name'
      name += ' ' if name != ''
      name += "#{key}=#{value}"
    end

    # output_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_output+"#{folder}#{zlevel}/#{name}.png"
    # FileUtils.copy_entry cache_filename, output_filename, false, false, true
    typical = get_dominant_color(cache_filename, ground_color)
    list_of_tags_and_dominant_color << { name: name, color: pixel_to_color_RGB(typical), color_as_pixel: typical, filename: cache_filename }
  end
  return list_of_tags_and_dominant_color
end

def compute_neighbours_to(branch, color_as_pixel, name, list_of_tags_and_dominant_color)
  CartoCSSHelper::Git.checkout(branch)
  list_of_tags_and_dominant_color.each do |i|
    lab_a = pixel_to_color_RGB(color_as_pixel).to_lab
    lab_b = i[:color].to_lab
    i[:delta] = i[:color].delta_e94(lab_a, lab_b)
    puts
    i[:neighbour] = { name: name, color: pixel_to_color_RGB(color_as_pixel), color_as_pixel: color_as_pixel, filename: nil }
  end
  return list_of_tags_and_dominant_color
end

def compute_all_deltas(list_of_tags_and_dominant_color)
  returned = []
  list_of_tags_and_dominant_color.each do |i|
    list_of_tags_and_dominant_color.each do |t|
      lab_a = i[:color].to_lab
      lab_b = t[:color].to_lab
      delta = i[:color].delta_e94(lab_a, lab_b)
      puts "===="
      puts i[:name]
      puts i[:color].delta_e94(lab_a, lab_b)
      puts i[:color].delta_e94(lab_b, lab_a)
      puts t[:name]
      puts "===="
      next if delta == 0
      new = i.clone
      new[:delta] = delta
      new[:neighbour] = t
      returned << new
    end
  end
  return returned
end

def compute_closest_among_all(list_of_tags_and_dominant_color)
  list_of_tags_and_dominant_color.each do |i|
    min_real_delta = 10_000_000
    closest = nil
    list_of_tags_and_dominant_color.each do |t|
      lab_a = i[:color].to_lab
      lab_b = t[:color].to_lab
      delta = i[:color].delta_e94(lab_a, lab_b)
      if delta > 0 && delta < min_real_delta
        min_real_delta = delta
        closest = t
      end
    end
    i[:delta] = min_real_delta
    i[:neighbour] = closest
    # puts "#{i[:name]} <> #{closest[:name]} = #{min_real_delta}"
  end
  return list_of_tags_and_dominant_color
end

def get_smallest_deltas_from_list(list_of_tags_and_dominant_color, count)
  if count > list_of_tags_and_dominant_color.length
    count = list_of_tags_and_dominant_color.length
  end
  return list_of_tags_and_dominant_color.group_by { |r| r[:delta] }
                                        .sort_by  { |k, _v| k }
                                        .first(count)
                                        .map(&:last)
                                        .flatten
end

def generate_log_about_deltas(list_of_tags_and_dominant_color, count, assume_neighbour_to_be_known = false)
  list_of_tags_and_dominant_color = get_smallest_deltas_from_list(list_of_tags_and_dominant_color, count)
  list_of_tags_and_dominant_color.each_with_index do |e, _i|
    if assume_neighbour_to_be_known
      puts "#{e[:name]}: #{e[:delta].round(2)}"
    else
      puts "#{e[:name]} <-> #{e[:neighbour][:name]} - #{e[:delta].round(2)}"
    end
  end
end

def generate_file_about_deltas(list_of_tags_and_dominant_color, output_filename, count)
  list_of_tags_and_dominant_color = get_smallest_deltas_from_list(list_of_tags_and_dominant_color, count)

  image_size = 200
  x_margin = 10
  y_margin = 30
  canvas = Magick::Image.new(image_size * 3.5, (image_size + y_margin) * list_of_tags_and_dominant_color.length)
  list_of_tags_and_dominant_color.each_with_index do |e, i|
    image = Magick::Image.read(e[:filename])[0]
    drawer = Magick::Draw.new
    canvas.composite!(image, x_margin, (y_margin + image_size) * i + y_margin, Magick::OverCompositeOp)
    unless e[:neighbour][:filename].nil?
      neighbour_image = Magick::Image.read(e[:neighbour][:filename])[0]
      canvas.composite!(neighbour_image, x_margin * 2 + image_size * 2, (y_margin + image_size) * i + y_margin, Magick::OverCompositeOp)
    end
    drawer.pointsize(10)
    drawer.text(x_margin, (y_margin + image_size) * (i + 1) - image_size, e[:name])
    drawer.draw(canvas)
    drawer.text(x_margin * 2 + image_size * 2, (y_margin + image_size) * (i + 1) - image_size, e[:neighbour][:name])
    drawer.draw(canvas)
    drawer.pointsize(22)
    drawer.text(x_margin + image_size * 1.4, (y_margin + image_size) * (i + 1) - image_size / 2, e[:delta].round(2).to_s)
    drawer.draw(canvas)
    gc = Magick::Draw.new
    gc.stroke = e[:color_as_pixel]
    gc.fill = e[:color_as_pixel]
    gc.rectangle x_margin * 2 + image_size, (y_margin + image_size) * (i + 1) - image_size / 2, x_margin * 2 + image_size + x_margin * 6, (y_margin + image_size) * (i + 1) - image_size / 2 + x_margin * 6
    gc.draw(canvas)
    gc = Magick::Draw.new
    gc.stroke = e[:neighbour][:color_as_pixel]
    gc.fill = e[:neighbour][:color_as_pixel]
    gc.rectangle x_margin * 2 + image_size * 1.5, (y_margin + image_size) * (i + 1) - image_size / 2, x_margin * 2 + image_size * 1.5 + x_margin * 6, (y_margin + image_size) * (i + 1) - image_size / 2 + x_margin * 6
    gc.draw(canvas)
  end
  output_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_output + output_filename
  canvas.write(output_filename)
end

def generate_images_about_neighbours(branch, areas, zlevel)
  CartoCSSHelper::Git.checkout(branch)
  on_water = false
  type = 'area'
  list_of_tags_and_dominant_color = get_dominant_colors(branch, areas, zlevel, on_water, type, 'landcover')
  list_of_tags_and_dominant_color.each do |e|
    list = compute_neighbours_to(branch, e[:color_as_pixel], e[:name], list_of_tags_and_dominant_color)
    count = 20
    generate_file_about_deltas(list, "#{e[:name]} z#{zlevel} #{branch}.png", count)
  end
end

def generate_image_of_close_landcovers(branch, areas, zlevel, count = 10)
  CartoCSSHelper::Git.checkout(branch)
  on_water = false
  type = 'area'
  list_of_tags_and_dominant_color = get_dominant_colors(branch, areas, zlevel, on_water, type, 'landcover')
  list_of_tags_and_dominant_color = compute_all_deltas(list_of_tags_and_dominant_color)

  generate_file_about_deltas(list_of_tags_and_dominant_color, "landcover_edelta_z#{zlevel} #{branch}.png", count)
end

def check_new_color(branch, zlevel, red, green, blue, name = nil)
  on_water = false
  type = 'area'
  list_of_tags_and_dominant_color = get_dominant_colors(branch, areas_set, zlevel, on_water, type, 'landcover')
  name = "rgb(#{red}, #{green}, #{blue})" if name.nil?
  color_as_pixel = Pixel.new(red * 257.0, green * 257.0, blue * 257.0, 0)
  # color_as_pixel = Pixel.new(60909, 56797, 51657, 0)
  # puts color_as_pixel
  # puts list_of_tags_and_dominant_color
  list = compute_neighbours_to(branch, color_as_pixel, name, list_of_tags_and_dominant_color)
  puts name
  generate_file_about_deltas(list, name + " z#{zlevel} #{branch}.png", 5)
  generate_log_about_deltas(list, 105, true)
  puts
  puts
  puts
end

def check_color(hex, name)
  hex = hex.delete('#').scan(/../).map { |color| color.to_i(16) }
  check_new_color(13, hex[0], hex[1], hex[2], 'farmland ' + name)
end

def edelta_run # 'older_master_but_after_last_landcover_change'
  areas = []
  areas.push({ 'landuse' => 'residential' })
  areas.push({ 'landuse' => 'commercial' })
  areas.push({ 'landuse' => 'retail' })
  areas.push({ 'landuse' => 'industrial' })
  areas.push({ 'highway' => 'pedestrian' })
  areas.push({ 'highway' => 'living_street' })
  areas.push({ 'natural' => 'water' })

  ['titan_blue', 'imagico_renewed', 'ren2', 'imagico_blue', 're2re', 'red'].each do |branch|
    [16].each do |zlevel| # 10, 13, 20
      generate_image_of_close_landcovers(branch, areas, zlevel, 50)
      # generate_image_of_close_landcovers(branch, areas_set, zlevel)
    end
  end

=begin

  areas = areas_set
  [13, 20, 10].each do |zlevel|
    generate_image_of_close_landcovers('old_new_forest', areas, zlevel)
    generate_image_of_close_landcovers('no_scrub', areas, zlevel)
    generate_image_of_close_landcovers('older_master_but_after_last_landcover_change', areas, zlevel)
  end

  return
  on_water = false
  zlevel = 13
  # generate_images_about_neighbours(branch, areas, zlevel)
  generate_image_of_close_landcovers(branch, areas, zlevel)
  # search_for_missing_areas(branch, areas, zlevel, on_water)

  branch = 'new_forest'
  # generate_images_about_neighbours(branch, areas, zlevel)
  generate_image_of_close_landcovers(branch, areas, zlevel)
  # search_for_missing_areas(branch, areas, zlevel, on_water)
  return

  # check_color('#fbecd7', 'lch(94, 12, 80)')
=end
end
