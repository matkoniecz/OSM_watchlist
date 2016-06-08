# frozen_string_literal: true
def get_project_location(project_name)
  return File.join(ENV['HOME'], 'Documents', 'MapBox', 'project', project_name, '')
end

def create_frozen_copy(project, index = '')
  copied_project = project + "-frozen#{index}"
  source = get_project_location(project)
  destination = get_project_location(copied_project)
  FileUtils.remove_entry destination, true
  FileUtils.copy_entry source, destination, false, false, true
  return destination
end

def expect_empty_stout_sterr(command)
  require 'open3'
  Open3.popen3(command) do |_, stdout, stderr, wait_thr|
    error = stderr.read.chomp
    stdout = stdout.read.chomp
    if error != '' || wait_thr.value.success? != true
      raise 'failed command ' + command + ' due to ' + error
    end
    return stdout != ''
  end
  raise 'impossible happened'
end

def with_uncommitted_changes
  Dir.chdir(CartoCSSHelper::Configuration.get_path_to_tilemill_project_folder) do
    system 'git stash > /dev/null'
    command = 'git diff @'
    return expect_empty_stout_sterr(command)
  end
end

def working_on_wrong_database_check(name)
  command = 'echo "\l" | psql postgres | grep ' + name
  Open3.popen3(command) do |_, stdout, stderr, wait_thr|
    error = stderr.read.chomp
    stdout = stdout.read.chomp
    raise 'failed command ' + command + ' due to ' + error if error != '' # or wait_thr.value.success? != true TODO: WAT?
    if stdout == ''
      puts "Database #{name} is missing!"
      switch_databases(name, 'gis_test')
      # raise 'working_on_wrong_database_check - missing ' + name
    end
    return
  end
  raise 'impossible happened'
end

def working_on_wrong_database
  # TODO: load it from database list for the freaking freak
  databases = ['krakow', 'vienna', 'london', 'rome', 'world', 'reykjavik', 'accra_ghana', 'abuja_nigeria', 'abidjan_ivory_coast',
               'well_mapped_rocky_mountains', 'rosenheim', 'south_mountain', 'tokyo', 'market', 'bridleway', 'vineyards', 'monte_lozzo',
               'danube_sinkhole', 'warsaw', 'new_york']
  databases.each do |name|
    working_on_wrong_database_check(name)
  end
  return false
end

def set_paths(tilemill_project_location)
  CartoCSSHelper::Configuration.set_style_specific_data(CartoCSSHelper::StyleDataForDefaultOSM.get_style_data)
  CartoCSSHelper::Configuration.set_path_to_tilemill_project_folder(tilemill_project_location)
  CartoCSSHelper::Configuration.set_path_to_folder_for_output(File.join(ENV['HOME'], 'Documents', 'OSM', 'CartoCSSHelper-output', ''))
  CartoCSSHelper::Configuration.set_path_to_folder_for_cache(File.join(ENV['HOME'], 'Documents', 'OSM', 'CartoCSSHelper-tmp', ''))
end

def warn_about_live_git_repository
  puts 'WARNING WARNING WARNING'
  puts 'WARNING WARNING WARNING'
  puts 'WARNING WARNING WARNING'
  puts 'WARNING WARNING WARNING'
  puts 'running on live git repository'
  puts 'using it may result in generated images for wrong versions of code'
  puts 'WARNING WARNING WARNING'
  puts 'WARNING WARNING WARNING'
  puts 'WARNING WARNING WARNING'
  puts 'WARNING WARNING WARNING'
end

def init(create_copy = true, index = '')
  raise 'loaded_not_generic_database' if working_on_wrong_database

  $silent = false
  project = 'osm-carto'
  destination = get_project_location(project)
  if create_copy
    destination = create_frozen_copy(project, index)
  else
    warn_about_live_git_repository
  end

  set_paths(destination)

  raise 'uncommitted changes in project' if with_uncommitted_changes
  CartoCSSHelper::OverpassQueryGenerator.check_for_free_space
end
