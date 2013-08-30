require 'spec_helper'

describe command('perl -v') do
  it { should return_stdout /v5\.18\.1/ }
end

describe command('ruby -v') do
  it { should return_stdout /ruby\s2\.0\.0p247/ }
end

describe command('node -v') do
  it { should return_stdout /v0\.10\.17/ }
end

