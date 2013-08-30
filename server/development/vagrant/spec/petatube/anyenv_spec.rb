require 'spec_helper'

describe command('/home/vagrant/.anyenv/envs/plenv/shims/perl -v') do
  it { should return_stdout /v5\.18\.1/ }
end

describe command('/home/vagrant/.anyenv/envs/rbenv/shims/ruby -v') do
  it { should return_stdout /ruby\s2\.0\.0p247/ }
end

describe command('/home/vagrant/.anyenv/envs/ndenv/shims/node -v') do
  it { should return_stdout /v0\.10\.17/ }
end

