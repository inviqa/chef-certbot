default['certbot']['auto_setup'] = true

default['certbot']['sandbox']['enabled'] = false
default['certbot']['sandbox']['user'] = 'certbot'
default['certbot']['sandbox']['group'] = 'certbot'
default['certbot']['sandbox']['webroot_path'] = '/var/www/certbot'

default['certbot']['default_cron']['predefined_value'] = '@daily'
default['certbot']['cron_name'] = 'certbot-renew'

default['certbot']['config_dir'] = '/etc/letsencrypt'
default['certbot']['work_dir'] = '/var/lib/letsencrypt'
default['certbot']['logs_dir'] = '/var/log/letsencrypt'
default['certbot']['server'] = nil
default['certbot']['staging'] = false

default['certbot']['certbot_auto_path'] = '/usr/local/bin/certbot-auto'
default['certbot']['package'] = 'certbot'

default['certbot']['renew_post_services'] = {}
default['certbot']['services'] = {}

if platform_family?('rhel') && node['platform_version'].to_i >= 7
  default['certbot']['install_method'] = 'package'
  default['certbot']['bin'] = 'certbot'
elsif platform_family?('fedora') && node['platform_version'].to_i >= 23
  default['certbot']['install_method'] = 'package'
  default['certbot']['bin'] = 'certbot'
elsif platform?('ubuntu') && node['plaform_version'].to_f > 16.04
  default['certbot']['install_method'] = 'package'
  default['certbot']['package'] = 'letsencrypt'
  default['certbot']['bin'] = 'letsencrypt'
else
  default['certbot']['install_method'] = 'certbot-auto'
  default['certbot']['bin'] = node['certbot']['certbot_auto_path']
end
