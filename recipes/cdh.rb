group_domains = {}
%w{ apache nginx }.each do |server|
  next unless node[server] && node[server]['sites']

  node[server]['sites'].each do |name, site|
    next unless site['protocols'].include?('https')

    group_name = site['ssl'] && site['ssl']['san_group']
    group_name ||= name if site['ssl'] && site['ssl']['use_sni']
    group_name ||= 'shared'

    group_domains[group_name] ||= {domains:[]}
    group_domains[group_name][:domains] << site['server_name']
    group_domains[group_name][:domains] += site['server_aliases'] if site['server_aliases']
    group_domains[group_name][:ssl] = site['ssl']
  end
end

group_domains.each do |group_name, certificate_data|
  ssl_directory = "/etc/letsencrypt/live/#{certificate_data[:domains].first}"
  directory ssl_directory do
    action :nothing
    only_if do
      Certbot::Util.self_signed_certificate?(certificate_data[:ssl]['certfile'])
    end
  end

  certbot_certonly_webroot group_name do
    webroot_path node['certbot']['sandbox']['webroot_path']
    email node['certbot']['cert-owner']['email']
    domains certificate_data[:domains]
    expand true
    agree_tos true
    action :nothing
  end

  log "delayed certbot_certonly_webroot execution (#{group_name})" do
    message "certbot::cdh queueing actions [:create] for certbot_certonly_webroot #{group_name}"
    level :debug
    notifies :delete, "directory[#{ssl_directory}]", :delayed
    notifies :create, "certbot_certonly_webroot[#{group_name}]", :delayed
  end
end
