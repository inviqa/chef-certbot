certbot_certonly_webroot 'single-cert' do
  webroot_path '/var/www/certbot'
  email 'root@localhost'
  domains ['mysite1.dev']
  expand false
end
