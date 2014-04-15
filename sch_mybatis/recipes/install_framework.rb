#
# Cookbook Name:: mybatis
# Recipe:: install_framework
#
# Copyright 2013, Scholastic, Inc.
#
# All rights reserved - Do Not Redistribute
#
# get files

include_recipe "java"

directory node[:sch_mybatis][:install_folder] do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

#cookbook_file "#{node[:sch_mybatis][:install_folder]}/#{node[:sch_mybatis][:source]}" do
#  source node[:sch_mybatis][:source]
#	mode "0644"
#	not_if do
#    File.exists?("#{node[:sch_mybatis][:install_folder]}/#{node[:sch_mybatis][:source]}")
#	end
#end

bash "put_files" do
  code <<-EOH
	cd  #{node[:sch_mybatis][:install_folder]}
  wget --no-check-certificate #{node[:sch_mybatis][:installer_url]}
  unzip #{node[:sch_mybatis][:install_folder]}/#{node[:sch_mybatis][:source]} -d #{node[:sch_mybatis][:install_folder]}
  chmod -R 755 #{node[:sch_mybatis][:install_folder]}
	mkdir /tmp/mybatis
	mv *.zip /tmp/mybatis
	mv * #{node[:sch_mybatis][:installed_name]}
	mv /tmp/mybatis/* .
  EOH
	only_if do
	  Dir["#{node[:sch_mybatis][:install_folder]}/*#{node[:sch_mybatis][:version]}"].empty?
	end
end
