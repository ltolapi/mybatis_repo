#
# Cookbook Name:: mybatis
# Recipe:: migrate
#
# Copyright 2013, Scholastic, Inc.
#
# All rights reserved - Do Not Redistribute
# Assumption is the migration sql is not a zip file

#if !node[:sch_mybatis][:use_git_repo] 
#	node[:sch_mybatis][:migration_scripts].each do |download_file|
#		bash "download_migration" do    
#			code <<-EOH
#			cd #{node[:sch_mybatis][:migrations_working_folder]}/scripts
#			wget -N --user=#{node[:sch_mybatis][:bootstrap_script_username]} --password='#{node[:sch_mybatis][:bootstrap_script_password]}'  #{downoad_file}
#			EOH
#			only_if { node.attribute?("mybatis_bootstrap_complete") }
#		end
#	end
#end


migrate_command = ""

# Migrate command of 'version' requires a version # be supplied.
# If no version # supplied, use the up command instead
if node[:sch_mybatis][:migrate_to_version] == ""
	migrate_command = "up"
else
	migrate_command = node[:sch_mybatis][:migrate_command] + " " + node[:sch_mybatis][:migrate_to_version]
end

bash "run_migrations" do
	user "root"
	export MIGRATIONS_HOME=/usr/share/mybatis-migrations-3.2.0/bin
	cwd "#{node[:sch_mybatis][:migrations_working_folder]}"
	code <<-EOH
	#{node[:sch_mybatis][:install_folder]}/#{node[:sch_mybatis][:installed_name]}/bin/migrate #{migrate_command} --env=#{node[:sch_mybatis][:environment]}
	EOH
	timeout node[:sch_mybatis][:script_timeout] 
 	#only_if { node.attribute?("mybatis_bootstrap_complete") }
end
