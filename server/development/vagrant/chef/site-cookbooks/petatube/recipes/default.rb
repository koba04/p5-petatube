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

