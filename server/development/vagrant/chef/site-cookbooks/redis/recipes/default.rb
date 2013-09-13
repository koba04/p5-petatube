#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

version = node[:version]

remote_file "/tmp/redis-#{version}.tar.gz" do
  source "http://download.redis.io/releases/redis-#{version}.tar.gz"
  not_if { system("/usr/local/bin/redis-server -v") }
end

bash "redis" do
  cwd "/tmp/"
  user "root"
  code <<-EOC
    tar xzf redis-#{version}.tar.gz
    cd redis-#{version}
    make && make install
  EOC
  not_if { system("/usr/local/bin/redis-server -v") }
end

directory "/var/lib/redis/petatube" do
  recursive true
  action :create
end


