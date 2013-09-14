require 'spec_helper'

describe file('/home/vagrant/petatube') do
  it { should be_directory }
end

describe command('/home/vagrant/.anyenv/envs/rbenv/shims/bundle -v') do
  it { should return_stdout /Bundler version/ }
end

describe command('/home/vagrant/.anyenv/envs/plenv/shims/cpanm -v') do
  it { should return_stdout /App::cpanminus/ }
end

describe command('/home/vagrant/.anyenv/envs/plenv/shims/carton -v') do
  it { should return_stdout /carton v/ }
end

describe command('/home/vagrant/.anyenv/envs/ndenv/shims/grunt --version') do
  it { should return_stdout /grunt-cli/ }
end

describe file('/var/log/petatube') do
  it { should be_directory }
end

describe file('/etc/supervisor/conf.d/nginx.conf') do
  it { should be_file }
end

describe file('/etc/supervisor/conf.d/petatube.conf') do
  it { should be_file }
end

describe file('/etc/supervisor/conf.d/redis.conf') do
  it { should be_file }
end

