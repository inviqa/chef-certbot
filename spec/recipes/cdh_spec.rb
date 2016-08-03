require 'util'

describe 'certbot::cdh' do
  context 'with a shared nginx site configuration' do
    cached(:chef_run) do
      allow(Certbot::Util).to receive(:'self_signed_certificate?').with('/etc/letsencrypt/live/mysite1.dev/fullchain.pem').and_return(true)
      allow(Certbot::Util).to receive(:'self_signed_certificate?').with('/etc/letsencrypt/live/mysite2.dev/fullchain.pem').and_return(true)
      ChefSpec::SoloRunner.new(step_into: ['log']) do |node|
        node.set['nginx']['sites']['mysite1'] = {
          server_name: 'mysite1.dev',
          protocols: ['http', 'https'],
          ssl: {
            certfile: '/etc/letsencrypt/live/mysite1.dev/fullchain.pem'
          }
        }
        node.set['nginx']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
          protocols: ['http', 'https'],
          ssl: {
            certfile: '/etc/letsencrypt/live/mysite2.dev/fullchain.pem'
          }
        }
        node.set['certbot']['cert-owner']['email'] = 'root@localhost'
      end.converge(described_recipe)
    end

    it "will set the nginx ssl location attributes" do
      expect(chef_run.node['nginx']['sites']['mysite1']['ssl']['certfile']).to eq '/etc/letsencrypt/live/mysite1.dev/fullchain.pem'
      expect(chef_run.node['nginx']['sites']['mysite1']['ssl']['keyfile']).to eq '/etc/letsencrypt/live/mysite1.dev/privkey.pem'
    end

    it "will create a single shared certificate" do
      resource = chef_run.log('delayed certbot_certonly_webroot execution (shared) further')
      expect(resource).to notify('certbot_certonly_webroot[shared]').to(:create).delayed

      expect(chef_run).to create_certbot_certonly_webroot('shared').with(
        webroot_path: '/var/www/certbot',
        email: 'root@localhost',
        domains: ['mysite1.dev', 'mysite2.dev', 'js.mysite2.dev', 'css.mysite2.dev'],
        expand: true,
        agree_tos: true,
      )
    end
  end

  context 'with a split nginx site configuration' do
    cached(:chef_run) do
      allow(Certbot::Util).to receive(:'self_signed_certificate?').with('/etc/letsencrypt/live/mysite1.dev/fullchain.pem').and_return(true)
      allow(Certbot::Util).to receive(:'self_signed_certificate?').with('/etc/letsencrypt/live/mysite2.dev/fullchain.pem').and_return(true)
      allow(Certbot::Util).to receive(:'self_signed_certificate?').with('/etc/letsencrypt/live/mysite3.dev/fullchain.pem').and_return(true)
      ChefSpec::SoloRunner.new(step_into: ['log']) do |node|
        node.set['nginx']['sites']['mysite1'] = {
          server_name: 'mysite1.dev',
          protocols: ['http', 'https'],
          ssl: {
            use_sni: true,
            certfile: '/etc/letsencrypt/live/mysite1.dev/fullchain.pem'
          }
        }
        node.set['nginx']['sites']['mysite2'] = {
          server_name: 'mysite2.dev',
          server_aliases: ['js.mysite2.dev', 'css.mysite2.dev'],
          protocols: ['http', 'https'],
          ssl: {
            use_sni: true,
            certfile: '/etc/letsencrypt/live/mysite2.dev/fullchain.pem'
          }
        }
        node.set['nginx']['sites']['mysite3'] = {
          server_name: 'mysite3.dev',
          protocols: ['http', 'https'],
          ssl: {
            san_group: 'mysite34',
            certfile: '/etc/letsencrypt/live/mysite3.dev/fullchain.pem'
          }
        }
        node.set['nginx']['sites']['mysite4'] = {
          server_name: 'mysite4.dev',
          protocols: ['http', 'https'],
          ssl: {
            san_group: 'mysite34',
            certfile: '/etc/letsencrypt/live/mysite3.dev/fullchain.pem'
          }
        }
        node.set['certbot']['cert-owner']['email'] = 'root@localhost'
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

    it "will create a separate certificate per site when use_sni is on" do
      resource = chef_run.log('delayed certbot_certonly_webroot execution (mysite1) further')
      expect(resource).to notify('certbot_certonly_webroot[mysite1]').to(:create).delayed
      expect(resource).to notify('directory[/etc/letsencrypt/live/mysite1.dev]').to(:delete).delayed

      expect(chef_run).to create_certbot_certonly_webroot('mysite1').with(
        webroot_path: '/var/www/certbot',
        email: 'root@localhost',
        domains: ['mysite1.dev', ],
        expand: true,
        agree_tos: true,
      )

      resource = chef_run.log('delayed certbot_certonly_webroot execution (mysite2) further')
      expect(resource).to notify('directory[/etc/letsencrypt/live/mysite2.dev]').to(:delete).delayed
      expect(resource).to notify('certbot_certonly_webroot[mysite2]').to(:create).delayed

      expect(chef_run).to create_certbot_certonly_webroot('mysite2').with(
        webroot_path: '/var/www/certbot',
        email: 'root@localhost',
        domains: ['mysite2.dev', 'js.mysite2.dev', 'css.mysite2.dev'],
        expand: true,
        agree_tos: true,
      )
    end

    it "will create a group of certificates per san_group" do
      resource = chef_run.log('delayed certbot_certonly_webroot execution (mysite34) further')
      expect(resource).to notify('directory[/etc/letsencrypt/live/mysite3.dev]').to(:delete).delayed
      expect(resource).to notify('certbot_certonly_webroot[mysite34]').to(:create).delayed

      expect(chef_run).to create_certbot_certonly_webroot('mysite34').with(
        webroot_path: '/var/www/certbot',
        email: 'root@localhost',
        domains: ['mysite3.dev', 'mysite4.dev'],
        expand: true,
        agree_tos: true,
      )
    end
  end
end
