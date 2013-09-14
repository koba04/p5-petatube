require 'spec_helper'

describe command('redis-server -v') do
  it { should return_stdout /2\.6\.16/ }
end

