require 'open3'

# frozen_string_literal: true
def get_project_location(project_name)
  return File.join(ENV['HOME'], 'Documents', 'MapBox', 'project', project_name, '')
end

def destination_of_frozen_copy(project)
  copied_project = project + "-frozen"
  return get_project_location(copied_project)
end

def create_frozen_copy(project)
  source = get_project_location(project)
  destination = destination_of_frozen_copy(project)
  FileUtils.remove_entry destination, true
  FileUtils.copy_entry source, destination, false, false, true
end

def execute_and_expect_no_output(command)
  output = execute_command(command)
  if output != ''
    raise "#{command} was supposed to give no output but it resulted in #{output}"
  end
end

def with_uncommitted_changes
  Dir.chdir(CartoCSSHelper::Configuration.get_path_to_tilemill_project_folder) do
    system 'git stash > /dev/null'
    command = 'git diff @'
    return execute_and_expect_no_output(command)
  end
end

def database_exists(name)
  # based on
  # http://stackoverflow.com/questions/14549270/check-if-database-exists-in-postgresql-using-shell/16783253#16783253
  # http://stackoverflow.com/questions/6550484/avoid-grep-returning-error-when-input-doesnt-match
  database = execute_command('psql -lqt | cut -d \| -f 1 | grep -w ' + name + ' | cat')
  return database.include?(name)
end

def working_on_wrong_database_check(name)
  return if database_exists(name)
  puts "Database #{name} is missing!"
  switch_databases(name, 'gis_test')
end

def working_on_wrong_database
  database_list = get_list_of_databases
  database_list << { name: "world" } # TODO: what about world database???
  database_list << { name: "entire_world" } # TODO: what about world database???

  database_list.each do |name|
    working_on_wrong_database_check(name[:name])
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

def init(create_copy = true)
  project = 'openstreetmap-carto'
  destination = get_project_location(project)
  if create_copy
    destination = destination_of_frozen_copy(project)
  else
    warn_about_live_git_repository
  end
  set_paths(destination)

  raise 'loaded_not_generic_database' if working_on_wrong_database
  create_frozen_copy(project) if create_copy

  raise 'uncommitted changes in project' if with_uncommitted_changes
  CartoCSSHelper::OverpassQueryGenerator.check_for_free_space
end
