#
# Cookbook Name:: mybatis
# Recipe:: deploy_from_git
#
# Copyright 2013, Scholastic, Inc.
#
# All rights reserved - Do Not Redistribute
#


#delete the script folder and contents if this recipe has not run before
directory "#{node[:sch_mybatis][:migrations_working_folder]}/scripts" do
	recursive true
	action :delete
	not_if { node.attribute?("mybatis_install_git_complete") }
end

directory "#{node[:sch_mybatis][:git_repo_destination]}" do
	action :create
end

#create the changelog table if it requested, only do it on first run
if node[:sch_mybatis][:create_mybatis_changelog_table] then
	template "/tmp/19700101000001_changelog.sql" do
		source "changelog.sql.erb"
		not_if { node.attribute?("mybatis_setup_git_complete") }
	end
	bash "run_migration" do
		code <<-EOH
		mkdir #{node[:sch_mybatis][:migrations_working_folder]}/scripts
		mv /tmp/19700101000001_changelog.sql #{node[:sch_mybatis][:migrations_working_folder]}/scripts/.
		cd #{node[:sch_mybatis][:migrations_working_folder]}
		#{node[:sch_mybatis][:install_folder]}/#{node[:sch_mybatis][:installed_name]}/bin/migrate up
		rm -rf #{node[:sch_mybatis][:migrations_working_folder]}/scripts
		EOH
		not_if { node.attribute?("mybatis_setup_git_complete") }
	end
end

package "git"

#oauth implementation . sync the local repo with the master/desired
#if node[:sch_mybatis][:git_security_type] == "oauth" then
#	git node[:sch_mybatis][:git_repo_destination] do
#		repository node[:sch_mybatis][:git_repo] 
#		reference node[:sch_mybatis][:deploy_revision]
#		action :sync
#		user "root"
#		group "root"
#	end
#end

#Download the mybatis zip file from git 
#if node[:sch_mybatis][:git_security_type] == "oauth" then
#	git node[:sch_mybatis][:git_repo_destination] do
#		repository node[:sch_mybatis][:source_url] 
#		reference node[:sch_mybatis][:deploy_revision]
#		action :sync
#		user "root"
#		group "root"
#	end
#end


bash "download_jar" do
		code <<-EOH
		cd #{node[:sch_mybatis][:download_directory]}
                rm -rf #{node[:sch_mybatis][:download_directory]}/*
		wget --user=#{node[:sch_mybatis][:artefactory_uname]} --password=#{node[:sch_mybatis][:artefactory_password]}  #{node[:sch_mybatis][:jar_url]}
		unzip litpro-db*.jar
		EOH
end


#deploy key implemenation
if node[:sch_mybatis][:git_security_type] == "deploy_key" then
	application "deploy_from_git" do
		path "#{node[:sch_mybatis][:git_repo_destination]}"
		repository "#{node[:sch_mybatis][:git_repo]}"
		deploy_key node[:sch_mybatis][:deploy_key]
		revision node[:sch_mybatis][:deploy_revision]
		action :force_deploy
	end
end 

#create the symlink
link "#{node[:sch_mybatis][:migrations_working_folder]}/scripts" do
  to "#{node[:sch_mybatis][:download_directory]}/db/scripts"
end

#set the complete flag
ruby_block "mybatis_git_setup_run_flag" do
  block do
    node.set['mybatis_setup_git_complete'] = true
    node.save
  end
end
