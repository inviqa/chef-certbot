template "#{node['nginx']['dir']}/certbot.conf" do
  source 'certbot.conf.erb'
end