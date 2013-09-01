#
# Cookbook Name:: petatube
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "git clone" do
  user node[:user][:name]
  cwd  node[:user][:home]
  environment "HOME" => node[:user][:home]
  code <<-EOC
    git clone https://github.com/koba04/p5-petatube.git petatube
    cd petatube
    git submodule update
  EOC
  not_if { File.exist?("#{node[:user][:home]}/petatube") }
end

bash "git pull" do
  user node[:user][:name]
  cwd  node[:user][:home]
  environment "HOME" => node[:user][:home]
  code <<-EOC
    cd petatube
    git pull --rebase
    git submodule update
  EOC
  only_if { File.exist?("#{node[:user][:home]}/petatube") }
end

bash "install gems" do
  user node[:user][:name]
  cwd  node[:user][:home]
  environment "HOME" => node[:user][:home]
  code <<-EOC
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init -)"
    export PATH="#{node[:user][:home]}/.anyenv/envs/rbenv/shims/:$PATH"
    cd #{node[:user][:home]}/petatube/app
    gem install bundler
    rbenv rehash
    bundle install --path vendor/bundle
  EOC
end

bash "set up perl module" do
  user node[:user][:name]
  cwd  node[:user][:home]
  environment "HOME" => node[:user][:home]
  code <<-EOC
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init -)"
    export PATH="#{node[:user][:home]}/.anyenv/envs/plenv/shims/:$PATH"
    cd #{node[:user][:home]}/petatube/app
    curl -L http://cpanmin.us | perl - App::cpanminus
    plenv rehash
    cpanm Carton
    plenv rehash
    carton install
  EOC
end

bash "install npm" do
  user node[:user][:name]
  cwd  node[:user][:home]
  environment "HOME" => node[:user][:home]
  code <<-EOC
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init -)"
    export PATH="#{node[:user][:home]}/.anyenv/envs/ndenv/shims/:$PATH"
    cd #{node[:user][:home]}/petatube/app
    npm install -g grunt-cli
    npm install
    ndenv rehash
  EOC
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

