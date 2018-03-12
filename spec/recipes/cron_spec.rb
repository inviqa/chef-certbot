describe 'certbot::cron' do
  context 'with default configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'will create cron to renew the certificates daily' do
      expect(chef_run).to create_cron_d('certbot-renew').with({
        command: '/usr/local/sbin/certbot-renew.sh',
        user: 'root',
        predefined_value: '@daily',
      })
    end
    it 'will create the cron script' do
      expect(chef_run).to render_file('/usr/local/sbin/certbot-renew.sh').with_content(%r(^certbot renew --post-hook "touch \$UPDATE_FLAG_FILE"$))
    end
  end

  context 'with specified cron timing configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['certbot']['cron'] = {
          minute: 0,
          hour: 2,
        }
      end.converge(described_recipe)
    end

    it 'will create cron to renew the certificates daily' do
      expect(chef_run).to create_cron_d('certbot-renew').with({
        command: '/usr/local/sbin/certbot-renew.sh',
        user: 'root',
        minute: 0,
        hour: 2,
      })
    end
  end

  context 'with nginx service set in attributes to reload after renew' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['certbot']['renew_post_services']['nginx'] = 'reload'
      end.converge(described_recipe)
    end

    it 'will reload nginx in the cron script' do
      expect(chef_run).to render_file('/usr/local/sbin/certbot-renew.sh').with_content(/^\s*service nginx reload$/)
    end
  end

  context 'with nginx in run_list' do
    cached(:chef_run) do
      stub_command("which nginx").and_return('/usr/bin/nginx')
      ChefSpec::SoloRunner.new(step_into: ['ruby_block']).converge('fake::configure-nginx')
    end

    it 'will reload nginx in the cron script' do
      expect(chef_run).to render_file('/usr/local/sbin/certbot-renew.sh').with_content(/^\s*service nginx reload$/)
    end
  end

  context 'with apache2 in run_list' do
    cached(:chef_run) do
      stub_command("/usr/sbin/apache2 -t")
      ChefSpec::SoloRunner.new(step_into: ['ruby_block']).converge('fake::configure-apache2')
    end

    it 'will reload nginx in the cron script' do
      expect(chef_run).to render_file('/usr/local/sbin/certbot-renew.sh').with_content(/^\s*service apache2 reload$/)
    end
  end

  context 'with sandbox enabled' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['certbot']['sandbox']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'will run certbot as sandbox user in the cron script' do
      expect(chef_run).to render_file('/usr/local/sbin/certbot-renew.sh').with_content(%r(^su - certbot -c "certbot renew --post-hook \\"touch \$UPDATE_FLAG_FILE\\""$))
    end
  end
end
