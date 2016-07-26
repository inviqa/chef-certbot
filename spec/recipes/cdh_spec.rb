describe 'certbot::cdh' do
  context 'with a shared nginx site configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx']['sites']['mysite1'] = {
          server_name: 'mysite1.dev'
        }
        node.set['nginx']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
        }
        node.set['certbot']['cert-owner']['email'] = 'root@localhost'
      end.converge(described_recipe)
    end

    it "will create a single shared certificate" do
      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite1.dev,mysite2.dev,js.mysite2.dev,css.mysite2.dev --expand --agree-tos --non-interactive').with({
        user: 'certbot'
      })
    end
  end

  context 'with a split nginx site configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx']['sites']['mysite1'] = {
          server_name: 'mysite1.dev',
          certbot: {
            split: true
          }
        }
        node.set['nginx']['sites']['mysite3'] = {
          server_name: 'mysite3.dev',
          certbot: {
            split: true
          }
        }
        node.set['nginx']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
          certbot: {
            split: true
          }
        }
        node.set['certbot']['cert-owner']['email'] = 'root@localhost'
      end.converge(described_recipe)
    end

    it "will create a separate certificate per site" do
      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite1.dev --expand --agree-tos --non-interactive').with({
        user: 'certbot'
      })
      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite2.dev,js.mysite2.dev,css.mysite2.dev --expand --agree-tos --non-interactive').with({
        user: 'certbot'
      })
    end
  end
end
