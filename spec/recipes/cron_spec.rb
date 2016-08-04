describe 'certbot::cron' do
  context 'with default configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'will create cron to renew the certificates daily' do
      expect(chef_run).to create_cron_d('certbot-renew').with({
        command: "su - certbot -c '/usr/local/bin/certbot-auto renew' && service nginx reload",
        user: 'root',
        predefined_value: '@daily',
      })
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
        command: "su - certbot -c '/usr/local/bin/certbot-auto renew' && service nginx reload",
        user: 'root',
        minute: 0,
        hour: 2,
      })
    end
  end
end
