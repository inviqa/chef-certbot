require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  # Specify the operating platform to mock Ohai data from                       
  config.platform = 'ubuntu'                                                   

  # Specify the operating version to mock Ohai data from                        
  config.version = '14.04'
end

lib = File.expand_path('../../libraries', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
