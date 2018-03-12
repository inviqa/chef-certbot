describe 'fake::certonly-webroot' do
  context 'with two certonly webroots' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['certbot_certonly_webroot']).converge(described_recipe)
    end

    it "will create a single domain certificate" do
      expect(chef_run).to run_execute('certbot certonly --config-dir /etc/letsencrypt --work-dir /var/lib/letsencrypt --logs-dir /var/log/letsencrypt --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite1.dev --agree-tos --non-interactive').with({
        user: nil
      })
    end

    it "will create a multi domain certificate" do
      expect(chef_run).to run_execute('certbot certonly --config-dir /etc/letsencrypt --work-dir /var/lib/letsencrypt --logs-dir /var/log/letsencrypt --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite2.dev,js.mysite2.dev,css.mysite2.dev --expand --agree-tos --non-interactive').with({
        user: nil
      })
    end
  end

  context 'with a certonly webroot that has not agreed TOS' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['certbot_certonly_webroot']).converge('fake::certonly-webroot-disagree')
    end

    it "will raise an error" do
      expect{chef_run}.to raise_error
    end
  end

  context 'with a native distro package' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.2.1511', step_into: ['certbot_certonly_webroot']).converge(described_recipe)
    end

    it "will use the package's bin to generate certificates" do
      expect(chef_run).to run_execute('certbot certonly --config-dir /etc/letsencrypt --work-dir /var/lib/letsencrypt --logs-dir /var/log/letsencrypt --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite1.dev --agree-tos --non-interactive').with({
        user: nil
      })
    end
  end

  context 'with sandbox enabled' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['certbot_certonly_webroot']) do |node|
        node.set['certbot']['sandbox']['enabled'] = true
      end.converge(described_recipe)
    end

    it "will use the sandbox user to generate certificates" do
      expect(chef_run).to run_execute('certbot certonly --config-dir /etc/letsencrypt --work-dir /var/lib/letsencrypt --logs-dir /var/log/letsencrypt --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite1.dev --agree-tos --non-interactive').with({
        user: 'certbot'
      })
    end
  end
end
