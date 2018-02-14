require 'json'
require 'serverspec'

if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM).nil?
  set :backend, :exec
else
  set :backend, :cmd
  set :os, family: 'windows'
end

NODE_JSON_PATH = '/tmp/test-helper/node.json'
raise 'Could not find node.json, is test-helper::default in the runlist?' unless ::File.exists?(NODE_JSON_PATH)
$node = ::JSON.parse(File.read(NODE_JSON_PATH))
