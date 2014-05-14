# Cookbook Name:: jboss installation
# Recipe:: default
#
# Copyright 2013, Lakshmi Prasad
#
# All rights reserved - Do Not Redistribute

jboss_home = node['jboss']['jboss_home']
jboss_user = node['jboss']['jboss_user']

# find all members of the jboss group, so we can make them members
jboss_members = Array.new
jboss_members << jboss_user

tarball_name = node['jboss']['dl_url'].
  split('/')[-1].
  sub!('.tar.gz', '')
path_arr = jboss_home.split('/')
path_arr.delete_at(-1)
jboss_parent = path_arr.join('/')

# get files
bash "Download and extract to #{jboss_home}" do
  code <<-EOH
  cd /tmp
  wget #{node['jboss']['dl_url']}
  
  tar xvzf #{tarball_name}.tar.gz -C /usr/share/
  chown -R jboss:jboss #{jboss_home}
  rm -f #{tarball_name}.tar.gz
  cd /usr/share/
  mv #{tarball_name} jboss-as
  EOH
  not_if "test -d #{jboss_home}"
end


# set permissions on directory
directory jboss_home do
  group jboss_user
  owner jboss_user
  recursive true
end

directory node['jboss']['jboss_certs'] do
  group jboss_user
  owner jboss_user
 end

 template "#{jboss_home}/standalone/configuration/standalone.xml" do
  source "standalone.xml.erb"
  mode "0755"
  owner "root"
  group "root"
  end
 
# template init file
template "/etc/init.d/jboss" do
  source "init_el.erb"
  mode "0755"
  owner "root"
  group "root"
  not_if "test -d /etc/init.d/jboss"
end

# add sudoers
template "/etc/sudoers.d/jboss" do
  source "jboss_sudoers"
  mode 0440
  owner "root"
  group "root"
end

# start service
service "jboss" do
  action [ :enable, :start ]
end
