def gather_data(branch, sample, filename)
	Dir.chdir(Configuration.get_path_to_tilemill_project_folder) do
		Git.checkout(branch)
		command = "carto -b project.mml 2>&1"
		filters = " | egrep -B1 'Inheritance time: ' | sed -e 's/processing layer: //g' | sed -e 's/Inheritance time://g' "
		merge_every_two_lines_in_one = "| paste - - "
		more_filters = "| sed -e 's/	/,/g' | sed -e 's/ms//g' | sed -e 's/$/, #{sample}, #{branch}/g'"
		target = " >> #{filename}"
		execute_command(command+filters+merge_every_two_lines_in_one+more_filters+target)
	end
end

def compare_time(branch1, branch2, samples, filename)
	execute_command("echo \"layer, time, sample, branch\" > #{filename}")
	samples.times do |sample|
		puts "sample #{sample}"
		gather_data(branch1, sample, filename)
		gather_data(branch2, sample, filename)
	end
end