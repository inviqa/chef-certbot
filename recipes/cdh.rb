certbot_group_domains = {}
%w{ apache nginx }.each do |server|
  next unless node[server] && node[server]['sites']

  node[server]['sites'].each do |name, site|
    site = ConfigDrivenHelper::Util.merge_default_shared_site(node, name, site, server)
    next unless site['protocols'].include?('https')

    group_name = site['ssl'] && site['ssl']['san_group']
    group_name ||= name if site['ssl'] && site['ssl']['use_sni']
    group_name ||= 'shared'

    certbot_group_domains[group_name] ||= {domains:[], servers: []}
    certbot_group_domains[group_name][:domains] << site['server_name']
    certbot_group_domains[group_name][:domains] += site['server_aliases'] if site['server_aliases']
    certbot_group_domains[group_name][:servers] << server

    ssl_directory = "/etc/letsencrypt/live/#{certbot_group_domains[group_name][:domains].first}"
    case server
    when "apache"
      certbot_group_domains[group_name][:certfile] = "#{ssl_directory}/cert.pem"
      node.set[server]['sites'][name]['ssl']['certchainfile'] = "#{ssl_directory}/chain.pem"
    when "nginx"
      certbot_group_domains[group_name][:certfile] = "#{ssl_directory}/fullchain.pem"
    end
    node.set[server]['sites'][name]['ssl']['certfile'] = certbot_group_domains[group_name][:certfile]
    node.set[server]['sites'][name]['ssl']['keyfile'] = "#{ssl_directory}/privkey.pem"
  end
end

include_recipe 'certbot'
include_recipe 'config-driven-helper::ssl-cert-self-signed'

certbot_group_domains.each do |group_name, certificate_data|
  ssl_directory = "/etc/letsencrypt/live/#{certificate_data[:domains].first}"
  directory ssl_directory do
    action :nothing
    only_if do
      Certbot::Util.self_signed_certificate?(certificate_data[:certfile])
    end
  end

  # this is to ensure nginx is definitely finished reloading by ensuring
  # certbot_certonly_webroot is run right at the end of the chef run
  log "delayed certbot_certonly_webroot execution (#{group_name})" do
    message "certbot::cdh queueing actions [:create] for certbot_certonly_webroot #{group_name}"
    notifies :write, "log[delayed certbot_certonly_webroot execution (#{group_name}) further]", :delayed
  end

  log "delayed certbot_certonly_webroot execution (#{group_name}) further" do
    message "certbot::cdh queueing actions [:create] for certbot_certonly_webroot #{group_name}"
    level :debug
    notifies :delete, "directory[#{ssl_directory}]", :delayed
    notifies :create, "certbot_certonly_webroot[#{group_name}]", :delayed
    action :nothing
  end

  certbot_certonly_webroot group_name do
    webroot_path node['certbot']['sandbox']['webroot_path']
    email node['certbot']['cert-owner']['email']
    domains certificate_data[:domains]
    expand true
    agree_tos true
    action :nothing
    certificate_data[:servers].uniq.each do |server|
      server = 'apache2' if server == 'apache'
      notifies :reload, "service[#{server}]", :delayed
    end
  end
end
