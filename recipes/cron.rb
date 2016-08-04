cron_d node['certbot']['cron_name'] do
  command "su - #{node['certbot']['sandbox']['user']} -c '#{node['certbot']['bin']} renew' && service nginx reload"
  user 'root'
  (node['certbot']['cron'] || node['certbot']['default_cron']).each do |key, value|
    send key, value
  end
end
