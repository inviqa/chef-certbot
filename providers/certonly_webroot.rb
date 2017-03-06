use_inline_resources if defined?(:use_inline_resources)

action :create do
  options = {
    'config-dir' => node['certbot']['config_dir'],
    'work-dir' => node['certbot']['work_dir'],
    'logs-dir' => node['certbot']['logs_dir'],

    'authenticator' => 'webroot',
    'webroot' => true,
    'webroot-path' => new_resource.webroot_path,
    'email' => new_resource.email,
    'domains' =>  new_resource.domains.join(','),
    'expand' => new_resource.expand,
    'agree-tos' => new_resource.agree_tos,
    'rsa-key-size' => new_resource.rsa_key_size,
    'staging' => new_resource.staging,
    'non-interactive' => true
  }

  if node['certbot']['server'] && !new_resource.staging
    options['server'] = node['certbot']['server']
  end

  unless options['agree-tos']
    raise 'You need to agree to the Terms of Service by setting agree_tos true'
  end

  # certbot fails if certain parameters are specified with a false value, so
  # here we make sure to remove those special cases
  flags = %w(non-interactive noninteractive force-interactive dry-run
             keep-until-expiring keep reinstall expand force-renewal
             renew-by-default allow-subset-of-names duplicate os-packages-only
             no-self-upgrade must-staple hsts test-cert staging debug
             no-verify-ssl break-my-certs)
  options.each { |key, value| options.delete(key) if !value and \
    flags.include?(key) }

  chef_gem 'inifile'

  require 'inifile'
  iniobject = IniFile.new(:default => 'global')
  iniobject['global'] = options

  configfile = "#{node['certbot']['work_dir']}/#{new_resource.name}.ini"
  file configfile do
    content iniobject.to_s
    mode "0640"
  end

  execute "#{node['certbot']['bin']} certonly --config #{configfile}" do
    if node['certbot']['sandbox']['enabled']
      user node['certbot']['sandbox']['user']
    end
  end
end
