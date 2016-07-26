split_domains = {}
%w{ apache nginx }.each do |server|
  next unless node[server] && node[server]['sites']

  node[server]['sites'].each do |name, site|
    split_name = site['certbot'] && site['certbot']['split'] ? name : 'shared'
    split_domains[split_name] ||= []
    split_domains[split_name] << site['server_name']
    split_domains[split_name] += site['server_aliases'] if site['server_aliases']
  end
end

split_domains.each do |split_name, domains|
  certbot_certonly split_name do
    webroot true
    webroot_path node['certbot']['sandbox']['webroot_path']
    email node['certbot']['cert-owner']['email']
    domains domains
    expand true
    agree_tos true
  end
end