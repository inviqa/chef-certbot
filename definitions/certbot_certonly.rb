define :certbot_certonly do
  options = params
  options.delete :name
  options[:domains] = params[:domains].join(',')
  options[:'non-interactive'] = true

  unless options[:agree_tos]
    raise 'You need to agree to the Terms of Service by setting agree_tos true'
  end

  options_array = options.map do |key, value|
    key = key.to_s.gsub('_', '-')

    if value === true || value === false
      ["--#{key}"]
    else
      ["--#{key}", value]
    end
  end

  execute "certbot certonly #{options_array.flatten.join(' ')}" do
    user node['certbot']['sandbox']['user']
  end
end
