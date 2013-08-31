require 'spec_helper'

describe file('/home/vagrant/petatube') do
  it { should be_directory }
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

