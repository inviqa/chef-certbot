ruby_block 'detect web server services in use' do
  block do
    if run_context.loaded_recipe?('nginx')
      node.default['certbot']['renew_post_services']['nginx'] = 'reload'
      node.default['certbot']['services']['nginx'] = true
    end
    if run_context.loaded_recipe?('apache2')
      service_name = node['apache']['service_name']
      node.default['certbot']['renew_post_services'][service_name] = 'reload'
      node.default['certbot']['services']['apache2'] = true
    end
  end
end

include_recipe 'certbot::create-sandbox' if node['certbot']['sandbox']['enabled']
include_recipe 'certbot::server-webroots'
include_recipe 'certbot::cron'
