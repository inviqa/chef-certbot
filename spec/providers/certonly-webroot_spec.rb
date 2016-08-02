describe 'certbot::cdh' do
  context 'with a shared nginx site configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['certbot_certonly_webroot', 'log']) do |node|
        node.set['nginx']['sites']['mysite1'] = {
          server_name: 'mysite1.dev',
          protocols: ['http', 'https']
        }
        node.set['nginx']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
          protocols: ['http', 'https']
        }
        node.set['certbot']['cert-owner']['email'] = 'root@localhost'
      end.converge(described_recipe)
    end

    it "will create a single shared certificate" do
      resource = chef_run.log('delayed certbot_certonly_webroot execution (shared)')
      expect(resource).to notify('certbot_certonly_webroot[shared]').to(:create).delayed
      chef_run.certbot_certonly_webroot('shared').old_run_action :create
      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite1.dev,mysite2.dev,js.mysite2.dev,css.mysite2.dev --expand --agree-tos --non-interactive').with({
        user: 'certbot'
      })
    end
  end

  context 'with a split nginx site configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['certbot_certonly_webroot', 'log']) do |node|
        node.set['nginx']['sites']['mysite1'] = {
          server_name: 'mysite1.dev',
          protocols: ['http', 'https'],
          ssl: {
            use_sni: true
          }
        }
        node.set['nginx']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
          protocols: ['http', 'https'],
          ssl: {
            use_sni: true
          }
        }
        node.set['nginx']['sites']['mysite3'] = {
          server_name: 'mysite3.dev',
          protocols: ['http', 'https'],
          ssl: {
            san_group: 'mysite34'
          }
        }
        node.set['nginx']['sites']['mysite4'] = {
          server_name: 'mysite4.dev',
          protocols: ['http', 'https'],
          ssl: {
            san_group: 'mysite34'
          }
        }
        node.set['certbot']['cert-owner']['email'] = 'root@localhost'
      end.converge(described_recipe)
    end

    it "will create a separate certificate per site when use_sni is on" do
      resource = chef_run.log('delayed certbot_certonly_webroot execution (mysite1)')
      expect(resource).to notify('certbot_certonly_webroot[mysite1]').to(:create).delayed
      resource = chef_run.log('delayed certbot_certonly_webroot execution (mysite2)')
      expect(resource).to notify('certbot_certonly_webroot[mysite2]').to(:create).delayed
      chef_run.certbot_certonly_webroot('mysite1').old_run_action :create
      chef_run.certbot_certonly_webroot('mysite2').old_run_action :create

      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite1.dev --expand --agree-tos --non-interactive').with({
        user: 'certbot'
      })
      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite2.dev,js.mysite2.dev,css.mysite2.dev --expand --agree-tos --non-interactive').with({
        user: 'certbot'
      })
    end

    it "will create a group of certificates per san_group" do
      resource = chef_run.log('delayed certbot_certonly_webroot execution (mysite34)')
      expect(resource).to notify('certbot_certonly_webroot[mysite34]').to(:create).delayed
      chef_run.certbot_certonly_webroot('mysite34').old_run_action :create

      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite3.dev,mysite4.dev --expand --agree-tos --non-interactive').with({
        user: 'certbot'
      })
    end
  end
end
