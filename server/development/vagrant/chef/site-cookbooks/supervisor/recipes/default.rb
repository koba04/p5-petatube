#
# Cookbook Name:: supervisor
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'supervisor' do
  action :install
end

service 'supervisor' do
  action [:enable, :start]
end
