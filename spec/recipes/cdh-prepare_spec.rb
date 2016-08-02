describe 'certbot::cdh-prepare' do
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
      end.converge(described_recipe)
    end

    it "will set the nginx ssl location attributes" do
      expect(chef_run.node['nginx']['sites']['mysite1']['ssl']['certfile']).to eq '/etc/letsencrypt/live/mysite1.dev/fullchain.pem'
      expect(chef_run.node['nginx']['sites']['mysite1']['ssl']['keyfile']).to eq '/etc/letsencrypt/live/mysite1.dev/privkey.pem'
    end
  end

  context 'with a shared apache site configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['apache']['sites']['mysite1'] = {
          server_name: 'mysite1.dev'
        }
        node.set['apache']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
        }
      end.converge(described_recipe)
    end

    it "will set the apache ssl location attributes" do
      expect(chef_run.node['apache']['sites']['mysite1']['ssl']['certfile']).to eq '/etc/letsencrypt/live/mysite1.dev/cert.pem'
      expect(chef_run.node['apache']['sites']['mysite1']['ssl']['keyfile']).to eq '/etc/letsencrypt/live/mysite1.dev/privkey.pem'
      expect(chef_run.node['apache']['sites']['mysite1']['ssl']['certchainfile']).to eq '/etc/letsencrypt/live/mysite1.dev/chain.pem'
    end
  end

  context 'with a split nginx site configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx']['sites']['mysite1'] = {
          server_name: 'mysite1.dev',
          ssl: {
            use_sni: true
          }
        }
        node.set['nginx']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
          ssl: {
            use_sni: true
          }
        }
        node.set['nginx']['sites']['mysite3'] = {
          server_name: 'mysite3.dev',
          ssl: {
            san_group: 'mysite34'
          }
        }
        node.set['nginx']['sites']['mysite4'] = {
          server_name: 'mysite4.dev',
          ssl: {
            san_group: 'mysite34'
          }
        }
      end.converge(described_recipe)
    end

    it "will set multiple nginx sni ssl certificate location attributes" do
      expect(chef_run.node['nginx']['sites']['mysite1']['ssl']['certfile']).to eq '/etc/letsencrypt/live/mysite1.dev/fullchain.pem'
      expect(chef_run.node['nginx']['sites']['mysite1']['ssl']['keyfile']).to eq '/etc/letsencrypt/live/mysite1.dev/privkey.pem'
      expect(chef_run.node['nginx']['sites']['mysite2']['ssl']['certfile']).to eq '/etc/letsencrypt/live/mysite2.dev/fullchain.pem'
      expect(chef_run.node['nginx']['sites']['mysite2']['ssl']['keyfile']).to eq '/etc/letsencrypt/live/mysite2.dev/privkey.pem'
    end

    it "will set location attributes for san certificate" do
      expect(chef_run.node['nginx']['sites']['mysite3']['ssl']['certfile']).to eq '/etc/letsencrypt/live/mysite3.dev/fullchain.pem'
      expect(chef_run.node['nginx']['sites']['mysite3']['ssl']['keyfile']).to eq '/etc/letsencrypt/live/mysite3.dev/privkey.pem'
      expect(chef_run.node['nginx']['sites']['mysite4']['ssl']['certfile']).to eq '/etc/letsencrypt/live/mysite3.dev/fullchain.pem'
      expect(chef_run.node['nginx']['sites']['mysite4']['ssl']['keyfile']).to eq '/etc/letsencrypt/live/mysite3.dev/privkey.pem'
    end
  end
end
