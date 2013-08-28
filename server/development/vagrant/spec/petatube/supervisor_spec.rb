require 'spec_helper'

describe package('supervisor') do
  it { should be_installed }
end

describe file('/etc/supervisor/supervisord.conf') do
  it { should be_file }
end
