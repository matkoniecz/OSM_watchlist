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
  puts "copy start"
  source = get_project_location(project)
  destination = destination_of_frozen_copy(project)
  FileUtils.remove_entry destination, true
  FileUtils.copy_entry source, destination, false, false, true
  puts "copy end"
end

def execute_and_expect_no_output(command)
  output = execute_command(command)
  if output != ''
    raise "#{command} was supposed to give no output but it resulted in #{output}"
  end
end

def with_uncommitted_changes
  Dir.chdir(CartoCSSHelper::Configuration.get_path_to_cartocss_project_folder) do
    system 'git stash > /dev/null'
    command = 'git diff @'
    return execute_and_expect_no_output(command)
  end
end

def working_on_wrong_database_check(name)
  return if psql_database_exists(name)
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

def set_paths(cartocss_project_location)
  CartoCSSHelper::Configuration.set_style_specific_data(CartoCSSHelper::StyleDataForDefaultOSM.get_style_data)
  CartoCSSHelper::Configuration.set_path_to_cartocss_project_folder(cartocss_project_location)
  CartoCSSHelper::Configuration.set_path_to_folder_for_output(File.join(ENV['HOME'], 'Documents', 'OSM', 'CartoCSSHelper-output', ''))
  CartoCSSHelper::Configuration.set_path_to_folder_for_cache(File.join(ENV['HOME'], 'Documents', 'OSM', 'CartoCSSHelper-tmp', ''))
  CartoCSSHelper::Configuration.set_path_to_kosmtik(File.join(ENV['HOME'], 'Desktop', 'kosmtik', ''))
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

def final
  CartoCSSHelper::VisualDiff.run_jobs
  notify_spam 'Everything computed!'
  exit
end

def get_minutes_spend_on(start, finish)
  return nil if finish.nil?
  return nil if start.nil?
  return (finish - start).to_i / 60
end

def encoutered_exception(e, start_time, load_end, end_time)
  puts e.class
  puts e
  puts
  puts e.backtrace
  min_of_loading = get_minutes_spend_on(start_time, load_end)
  min_of_work = get_minutes_spend_on(load_end, end_time)
  min_of_errors = get_minutes_spend_on(end_time, Time.now)
  notify "Crash during map generation! (after #{min_of_work} min of work and #{min_of_errors} min of errors with #{min_of_loading} min of loading before)"
  sleep 10
end

def run_and_report_the_end
  start_time = Time.now
  begin
    # verify
    switch_database
    init(make_copy_of_repository) # frozen copy making
    # CartoCSSHelper::Configuration.set_known_alternative_overpass_url
    load_end = Time.now
    main
  rescue => e
    end_time = Time.now
    encoutered_exception(e, start_time, load_end, end_time) while true
  end
end
