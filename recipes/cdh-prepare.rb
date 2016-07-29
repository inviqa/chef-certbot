group_domains = {}
%w{ apache nginx }.each do |server|
  next unless node[server] && node[server]['sites']

  node[server]['sites'].each do |name, site|
    group_name = site['ssl'] && (site['ssl']['san_group'] || (site['ssl']['use_sni'] ? name : 'shared'))
    group_domains[group_name] ||= []
    group_domains[group_name] << site['server_name']
  end
end

%w{ apache nginx }.each do |server|
  next unless node[server] && node[server]['sites']

  node[server]['sites'].each do |name, site|
    group_name = site['ssl'] && (site['ssl']['san_group'] || (site['ssl']['use_sni'] ? name : 'shared'))
    ssl_directory = "/etc/letsencrypt/live/#{group_domains[group_name].first}"
    case server
    when "apache"
      node.set[server]['sites'][name]['ssl']['certfile'] = "#{ssl_directory}/cert.pem"
      node.set[server]['sites'][name]['ssl']['certchainfile'] = "#{ssl_directory}/chain.pem"
    when "nginx"
      node.set[server]['sites'][name]['ssl']['certfile'] = "#{ssl_directory}/fullchain.pem"
    end
    node.set[server]['sites'][name]['ssl']['keyfile'] = "#{ssl_directory}/privkey.pem"
  end
end
