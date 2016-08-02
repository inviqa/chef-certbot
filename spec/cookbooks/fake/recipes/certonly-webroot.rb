certbot_certonly_webroot 'single-cert' do
  webroot_path '/var/www/certbot'
  email 'root@localhost'
  domains ['mysite1.dev']
  expand false
  agree_tos true
end

certbot_certonly_webroot 'multi-cert' do
  webroot_path '/var/www/certbot'
  email 'root@localhost'
  domains ['mysite2.dev', 'js.mysite2.dev', 'css.mysite2.dev']
  expand true
  agree_tos true
end
