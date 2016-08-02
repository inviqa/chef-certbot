group_domains = {}
%w{ apache nginx }.each do |server|
  next unless node[server] && node[server]['sites']

  node[server]['sites'].each do |name, site|
    next unless site['protocols'].include?('https')

    group_name = site['ssl'] && site['ssl']['san_group']
    group_name ||= name if site['ssl'] && site['ssl']['use_sni']
    group_name ||= 'shared'

    group_domains[group_name] ||= []
    group_domains[group_name] << site['server_name']
    group_domains[group_name] += site['server_aliases'] if site['server_aliases']
  end
end

group_domains.each do |group_name, domains|
  certbot_certonly_webroot group_name do
    webroot_path node['certbot']['sandbox']['webroot_path']
    email node['certbot']['cert-owner']['email']
    domains domains
    expand true
    agree_tos true
    action :nothing
  end

  log "delayed certbot_certonly_webroot execution (#{group_name})" do
    message "certbot::cdh queueing actions [:create] for certbot_certonly_webroot #{group_name}"
    level :debug
    notifies :create, "certbot_certonly_webroot[#{group_name}]", :delayed
  end
end
