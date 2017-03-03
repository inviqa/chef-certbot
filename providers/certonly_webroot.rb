use_inline_resources if defined?(:use_inline_resources)

action :create do
  options = {
    'config-dir' => node['certbot']['config_dir'],
    'work-dir' => node['certbot']['work_dir'],
    'logs-dir' => node['certbot']['logs_dir'],
    'server' => node['certbot']['server'],

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

  unless options['agree-tos']
    raise 'You need to agree to the Terms of Service by setting agree_tos true'
  end

  chef_gem 'inifile'

  require 'inifile'
  iniobject = IniFile.new(options)

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
