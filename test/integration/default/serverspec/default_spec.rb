require 'spec_helper'

describe 'certbot::default' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html
  describe package('certbot') do
    it { should be_installed }
  end
end
