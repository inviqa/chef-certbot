use_inline_resources if defined?(:use_inline_resources)

action :create do
  options = {
    'config-dir' => node['certbot']['config_dir'],
    'work-dir' => node['certbot']['work_dir'],
    'logs-dir' => node['certbot']['logs_dir'],
    'server' => node['certbot']['server'],
    'staging' => node['certbot']['staging'],

    'webroot' => true,
    'webroot-path' => new_resource.webroot_path,
    'email' => new_resource.email,
    'domains' =>  new_resource.domains.join(','),
    'expand' => new_resource.expand,
    'agree-tos' => new_resource.agree_tos,
    'non-interactive' => true
  }

  unless options['agree-tos']
    raise 'You need to agree to the Terms of Service by setting agree_tos true'
  end

  options_array = options.map do |key, value|
    if value === true
      ["--#{key}"]
    elsif value === false || value.nil?
      []
    else
      ["--#{key}", value]
    end
  end

  execute "#{node['certbot']['bin']} certonly #{options_array.flatten.join(' ')}" do
    if node['certbot']['sandbox']['enabled']
      user node['certbot']['sandbox']['user']
    end
  end
end
