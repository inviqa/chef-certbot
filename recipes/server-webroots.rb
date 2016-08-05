directory node['certbot']['sandbox']['webroot_path']

template "#{node['nginx']['dir']}/certbot.conf" do
  source 'certbot-nginx.conf.erb'
  only_if { node['certbot']['services']['nginx'] }
end if node['nginx']

template "#{node['apache']['conf_dir'] || node['apache']['dir']}/certbot.conf" do
  source 'certbot-apache.conf.erb'
  only_if { node['certbot']['services']['apache2'] }
end if node['apache']
