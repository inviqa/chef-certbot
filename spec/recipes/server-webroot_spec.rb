describe 'certbot::server-webroots' do
  context 'with nginx in run_list' do
    cached(:chef_run) do
      stub_command('which nginx').and_return('/usr/bin/nginx')
      ChefSpec::SoloRunner.new(step_into: ['ruby_block']) do |node|
        node.normal['certbot']['services']['nginx'] = true
      end.converge('fake::configure-nginx')
    end

    it 'will create a nginx configuration for certbot webroot plugin' do
      expect(chef_run).to render_file('/etc/nginx/certbot.conf')
    end

    it "will set up access to certbot's webroot" do
      expect(chef_run).to create_directory('/var/www/certbot')
    end
  end

  context 'with apache2 in run_list' do
    cached(:chef_run) do
      stub_command('/usr/sbin/apache2 -t')
      ChefSpec::SoloRunner.new(step_into: ['ruby_block']) do |node|
        node.normal['apache']['service_name'] = 'apache2'
        node.normal['apache']['conf_dir'] = '/etc/apache2'
        node.normal['certbot']['services']['apache2'] = true
      end.converge('fake::configure-apache2')
    end

    it 'will create an apache configuration for certbot webroot plugin' do
      expect(chef_run).to render_file('/etc/apache2/certbot.conf')
    end
  end

  context 'apache version is 2.2' do
    cached(:chef_run) do
      stub_command('/usr/sbin/apache2 -t')
      ChefSpec::SoloRunner.new do |node|
        node.normal['apache']['service_name'] = 'apache2'
        node.normal['apache']['version'] = '2.2'
        node.normal['apache']['conf_dir'] = '/etc/apache2'
        node.normal['certbot']['services']['apache2'] = true
      end.converge('fake::configure-apache2')
    end

    it 'will create an apache configuration for certbot webroot plugin' do
      expect(chef_run).to render_file('/etc/apache2/certbot.conf')
        .with_content(/\s*Allow from all/)
    end
  end

  context 'apache version is 2.4' do
    cached(:chef_run) do
      stub_command('/usr/sbin/apache2 -t')
      ChefSpec::SoloRunner.new do |node|
        node.normal['apache']['service_name'] = 'apache2'
        node.normal['apache']['version'] = '2.4'
        node.normal['apache']['conf_dir'] = '/etc/apache2'
        node.normal['certbot']['services']['apache2'] = true
      end.converge('fake::configure-apache2')
    end

    it 'will create an apache 2.4 configuration for certbot webroot plugin' do
      expect(chef_run).to render_file('/etc/apache2/certbot.conf')
        .with_content(/\s*Require all granted/)
    end
  end
end
