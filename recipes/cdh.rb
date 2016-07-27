group_domains = {}
%w{ apache nginx }.each do |server|
  next unless node[server] && node[server]['sites']

  node[server]['sites'].each do |name, site|
    group_name = site['ssl'] && (site['ssl']['san_group'] || (site['ssl']['use_sni'] ? name : 'shared'))
    group_domains[group_name] ||= []
    group_domains[group_name] << site['server_name']
    group_domains[group_name] += site['server_aliases'] if site['server_aliases']
  end
end

group_domains.each do |group_name, domains|
  certbot_certonly group_name do
    webroot true
    webroot_path node['certbot']['sandbox']['webroot_path']
    email node['certbot']['cert-owner']['email']
    domains domains
    expand true
    agree_tos true
  end
end