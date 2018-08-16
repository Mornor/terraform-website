require 'spec_helper'

describe package("yum-utils") do
  it { should be_installed }
end

describe package("docker-ce") do
  it { should be_installed }
end

describe package("python2-pip") do
  it { should be_installed }
end
