#
# Cookbook Name:: sch_mybatis
# Recipe:: default
#
# Copyright 2013, Scholastic, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe "sch_mybatis::install_framework"
include_recipe "sch_mybatis::init_mybatis"
if node[:sch_mybatis][:use_git_repo] 
	include_recipe "sch_mybatis::deploy_from_git"
end

if node[:sch_mybatis][:run_bootstrap] 
	include_recipe "sch_mybatis::bootstrap"
else 
	# set bootstrap to complete, as it is assumed end user employed some method other than mybatis for bootstrap
#	ruby_block "sch_mybatis_bootstrap_run_flag" do
#		block do
			node.set['sch_mybatis_bootstrap_complete'] = true
			node.save
#		end
#	end
end

include_recipe "sch_mybatis::migrate"

