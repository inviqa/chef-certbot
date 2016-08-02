require 'chefspec'
require 'chefspec/berkshelf'

lib = File.expand_path('../../libraries', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
