name 'certbot'
maintainer 'Andy Thompson'
maintainer_email 'athompson@inviqa.com'
license 'Apache-2.0'
description 'Installs/Configures certbot'
long_description 'Installs/Configures certbot'
version '0.2.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

issues_url 'https://github.com/inviqa/chef-certbot/issues'
source_url 'https://github.com/inviqa/chef-certbot'

os_support = {
  'redhat' => '>= 7.0.0',
  'centos' => '>= 7.0.0',
  'fedora' => '>= 28.0',
  'debian' => '>= 8.0.0',
  'ubuntu' => '>= 14.04',
  'amazon' => '>= 2.0.0',
}

os_support.each do |os, ver|
  supports os, ver
end

depends 'apache2'
depends 'nginx'
depends 'yum-epel'
