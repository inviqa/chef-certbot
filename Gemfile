source "https://rubygems.org"

gem 'rake', '~> 12.3'
gem 'berkshelf', '~> 4.0'

group :integration do
  gem 'kitchen-vagrant', '~> 0.20.0'
  gem 'test-kitchen', '~> 1.7', '< 1.16'
end

group :test do
  gem 'chefspec', '~> 4.4'
  gem 'chef', '~> 12.0'
  gem 'foodcritic', '~> 6.0'
  gem 'rubocop', '~> 0.49.0'
end

group :deployment do
  gem 'stove', '~> 3.2'
end
