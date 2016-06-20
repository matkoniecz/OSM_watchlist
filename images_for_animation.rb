# frozen_string_literal: true
def generate_files_for_style_animation_for_given_revision(revision, r)
  if [500].include?(r)
    puts "known to be buggy"
    return
  end
  header = r.to_s.rjust(5, '0')
  # because the first wiki map - http://wiki.openstreetmap.org/wiki/History_of_OpenStreetMap : 51.3686, -0.4419
  begin
    get_single_image_from_database('entire_world', revision, 51.66243, -0.58722, 8, 780, "z8 #{header}")
    get_single_image_from_database('london', revision, 51.3686, -0.4419, 14, 780, "z14 #{header}")
    get_single_image_from_database('london', revision, 51.37245, -0.45807, 18, 780, "z18 #{header}")
  rescue CartoCSSHelper::TilemillFailedToGenerateFile => e
    puts "error on generation #{e}"
  end
end

def get_all_revisions(_branch)
  Dir.chdir(Configuration.get_path_to_tilemill_project_folder) do
    revisions = execute_command("git rev-list master", true)
    revisions = revisions.split("\n").reverse
    return revisions
  end
end

def generate_files_for_style_animation
  # convert -delay 200 -loop 0 *.png animation.gif
  # from http://unix.stackexchange.com/a/24019/92199
  divider = 100
  skip = 250
  # very early versions are looking for resources in places like
  # /usr/local/share/mapnik/shape-resources/world_boundaries
  #  0: f5f8a8238d82ea29cd3b93ab0636300723f8cfdb
  # 100: 328a36e4ab89e294dd3c0c780e9c57623d0a7533
  # 200: 82722dc5558c83acb20f247086aed36e38180d1f

  revisions = get_all_revisions(branch)
  revisions_filtered = []
  revisions.each_index do |index|
    revisions_filtered << revisions[index] if index % divider == 0
  end
  revisions_filtered << 'master'
  index = 0
  revisions_filtered.each do |revision|
    revision = revision.strip
    r = index * divider
    puts
    puts r
    puts revision
    index += 1
    if r < skip
      puts "skip"
      next
    end
    generate_files_for_style_animation_for_given_revision(revision, r)
  end
end
