#
# Cookbook Name:: mybatis
# Recipe:: bootstrap
#
# Copyright 2013, Scholastic, Inc.
#
# All rights reserved - Do Not Redistribute
#

# url location for wget, along with username and password
# unzip it to bootstrap.sql after download, only if new file
# then run bootstrap as bash, but only run if "bootstrap complete" attribute is not set

if !node[:sch_mybatis][:bootstrap_file_in_git] # use wget to download the bootstrap file, as assumption is its not in GIT

	old_file = "#{node[:sch_mybatis][:migrations_working_folder]}/scripts/#{node[:sch_mybatis][:bootstrap_script_name]}"
	if File.exists?(old_file) 
		old_file_date = File.mtime(old_file)
	else
		old_file_date = Time.at(0)
	end
#download the bootstrap file 
	bash "bootstrap_mybatis" do    
		code <<-EOH
		cd #{node[:sch_mybatis][:migrations_working_folder]}/scripts
		wget -N --user=#{node[:sch_mybatis][:bootstrap_script_username]} --password='#{node[:sch_mybatis][:bootstrap_script_password]}'  #{node[:sch_mybatis][:bootstrap_script_location]}/#{node[:sch_mybatis][:bootstrap_script_name]}
		EOH
		not_if { node.attribute?("mybatis_bootstrap_complete") }
	end

	ruby_block "unzip_and_rename" do
		block do
			new_file = "#{node[:sch_mybatis][:migrations_working_folder]}/scripts/#{node[:sch_mybatis][:bootstrap_script_name]}"
			if old_file_date.to_s != File.mtime(new_file)
				if new_file.downcase.include?(".zip")
					`mkdir /var/tmp/mybatis`
					`unzip -o #{new_file} -d /var/tmp/mybatis`
					`mv /var/tmp/mybatis/*.sql #{node[:sch_mybatis][:migrations_working_folder]}/scripts/bootstrap.sql`
					`rm -rf /var/tmp/mybatis`
#					`unzip -o #{new_file} -d #{node[:sch_mybatis][:migrations_working_folder]}/scripts`
#					unzipped_file=new_file.split(".")[0].to_s
#					unzipped_file=unzipped_file + ".sql"
#					File.rename(unzipped_file,  "#{node[:sch_mybatis][:migrations_working_folder]}/scripts/bootstrap.sql")
				else
				  File.rename(new_file, "#{node[:sch_mybatis][:migrations_working_folder]}/scripts/bootstrap.sql")
				end 
			end
		end
		not_if { node.attribute?("mybatis_bootstrap_complete") }
	end
end

#Run the bootstrap only if bootstrap complete is not set
execute "mybatis_bootstrap" do
#	command "cd #{node[:sch_mybatis][:migrations_working_folder]};#{node[:sch_mybatis][:install_folder]}/#{node[:sch_mybatis][:installed_name]}/bin/migrate bootstrap"
  command "cd #{node[:sch_mybatis][:migrations_working_folder]}/scripts;mysql -u#{node[:sch_mybatis][:db_username]} -p#{node[:sch_mybatis][:db_password]} #{node[:sch_mybatis][:db_name]} < bootstrap.sql"
	notifies :create, "ruby_block[mybatis_bootstrap_run_flag]", :immediately
	timeout node[:sch_mybatis][:script_timeout] 
	not_if { node.attribute?("mybatis_bootstrap_complete") }
end

#set bootstrap complete
ruby_block "mybatis_bootstrap_run_flag" do
  block do
    node.set['mybatis_bootstrap_complete'] = true
    node.save
  end
  action :nothing
end


