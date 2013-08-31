require 'spec_helper'

describe file('/home/vagrant/app/petatube') do
  it { should be_directory }
end

