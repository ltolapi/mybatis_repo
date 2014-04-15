
# Cookbook Name:: mybatis
# Recipe:: init_mybatis
#
# Copyright 2013, Scholastic, Inc.
#
# All rights reserved - Do Not Redistribute
#

# Create a directory for the migrations

include_recipe "maven"

directory node[:sch_mybatis][:migrations_working_folder] do
  owner "root"
  group "root"
  mode "0755"
  action :create
	recursive true
end

# Run the init function of mybatis to create the directory structure and scripts
bash "init_mybatis" do    
	code <<-EOH
	cd #{node[:sch_mybatis][:migrations_working_folder]}
	#{node[:sch_mybatis][:install_folder]}/#{node[:sch_mybatis][:installed_name]}/bin/migrate init
	EOH
	not_if do
		File.exists?("#{node[:sch_mybatis][:migrations_working_folder]}/drivers")
	end
end

# Install JDBC driver
#cookbook_file "#{node[:sch_mybatis][:migrations_working_folder]}/drivers/mysql-connector-java-5.1.21-bin.jar" do
# source "mysql-connector-java-5.1.21-bin.jar"
#	mode "0755"
#	not_if do
#   File.exists?("#{node[:sch_mybatis][:migrations_working_folder]}/drivers/mysql-connector-java-5.1.21-bin.jar")
#	end
#end

# Removed the above and added the following to update/download mysql jar file
maven "mysql-connector-java" do
  group_id "mysql"
  version "#{node[:sch_mybatis][:mysql_connector_java_version]}"
  mode   0644
  owner  "root"
  dest "#{node[:sch_mybatis][:migrations_working_folder]}/drivers/"
  packaging "jar"
end

# Configure migrations environment
# This recipe was originally built to do migrations from the slz ion database
# it was later augmented to work with any database, hence the next if statment

if node[:sch_mybatis][:db_port].empty? 
	db_port = node['samconnect']['iondb_port']
	db_username = node['samconnect']['iondb_username']
	db_password = node['samconnect']['iondb_password']
else
	db_port = node['sch_mybatis']['db_port']
	db_username = node['sch_mybatis']['db_username']
	db_password = node['sch_mybatis']['db_password']
end

template "#{node[:sch_mybatis][:migrations_working_folder]}/environments/#{node[:sch_mybatis][:environment]}.properties" do
  source "environment.properties.erb"
  mode "0644"
  variables(
    :driver => "#{node['sch_mybatis']['db_driver']}",
    :url => "#{node['sch_mybatis']['db_url']}:#{db_port}/#{node['sch_mybatis']['db_name']}",    
    :username => db_username,
    :password => db_password )
end
