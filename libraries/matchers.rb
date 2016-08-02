if defined?(ChefSpec)
  %w( certonly_webroot ).each do |r|
    ChefSpec.define_matcher("certbot_#{r}".to_sym)

    %w( create ).each do |a|
      define_method("#{a}_certbot_#{r}".to_sym) do |resource_name|
        ChefSpec::Matchers::ResourceMatcher.new(
          "certbot_#{r}".to_sym, a, resource_name
        )
      end
    end
  end
end
