default['certbot']['auto-setup'] = true
default['certbot']['sandbox']['user'] = 'certbot'
default['certbot']['sandbox']['group'] = 'certbot'
default['certbot']['sandbox']['webroot_path'] = '/var/www/certbot'

default['certbot']['default_cron']['predefined_value'] = '@daily'
default['certbot']['cron_name'] = 'certbot-renew'