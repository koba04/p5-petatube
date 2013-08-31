#
# Cookbook Name:: petatube
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "git clone petatube" do
  user node[:user][:name]
  cwd  node[:user][:home]
  environment "HOME" => node[:user][:home]
  code <<-EOC
    git clone https://github.com/koba04/p5-petatube.git petatube
  EOC
  not_if { File.exist?("#{node[:user][:home]}/petatube") }
end

directory "/var/log/petatube" do
  action :create
end

cookbook_file "/etc/supervisor/conf.d/nginx.conf" do
  source "nginx.conf"
  action :create
end

cookbook_file "/etc/supervisor/conf.d/petatube.conf" do
  source "petatube.conf"
  action :create
end

cookbook_file "/etc/supervisor/conf.d/redis.conf" do
  source "redis.conf"
  action :create
end

# supervisor reload

