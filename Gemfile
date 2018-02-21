source "https://rubygems.org"

gem 'rake', '~> 10.1'
gem 'berkshelf', '~> 4.0'

group :integration do
  gem 'kitchen-vagrant', '~> 0.20.0'
  gem 'test-kitchen', '~> 1.7', '< 1.16'
end

group :test do
  gem 'chefspec', '~> 4.4'
  gem 'chef', '~> 12.0'
  gem 'foodcritic', '~> 6.0'
  gem 'nokogiri', '~> 1.6.3.1'
  gem 'rubocop', '~> 0.39.0'
end

group :deployment do
  gem 'stove', '~> 3.2'
end
