# frozen_string_literal: true
module CartoCSSHelper
  def create_new_gis_database(name)
    puts "Creating gis database <#{name}>"
    command = "createdb #{name}"
    system command
    command = "psql -d #{name} -c 'CREATE EXTENSION hstore; CREATE EXTENSION postgis;'"
    system command
    # TODO: move to execute_command (but add test before that)
  end

  def switch_databases(new_name_for_gis, switched_into_for_gis)
    command = "echo \"alter database gis rename to #{new_name_for_gis};
alter database #{switched_into_for_gis} rename to gis;
\\q\" | psql postgres > /dev/null"
    puts "gis -> #{new_name_for_gis}, #{switched_into_for_gis} -> gis"
    system command
    # TODO: move to execute_command (but add test before that)
  end

  def psql_database_exists(name)
    # based on
    # http://stackoverflow.com/questions/14549270/check-if-database-exists-in-postgresql-using-shell/16783253#16783253
    # http://stackoverflow.com/questions/6550484/avoid-grep-returning-error-when-input-doesnt-match
    database = execute_command('psql -lqt | cut -d \| -f 1 | grep -w ' + name + ' | cat')
    return database.include?(name)
  end
end
