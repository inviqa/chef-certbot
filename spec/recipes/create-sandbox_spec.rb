describe 'certbot::create-sandbox' do
  context 'with default configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it "will create a sandbox user and group" do
      expect(chef_run).to create_user('certbot').with({
        gid: 'certbot'
      })
      expect(chef_run).to create_group('certbot')
    end

    it "will set up access to certbot's folders" do
      %w{
        /var/www/certbot
        /etc/letsencrypt
        /var/lib/letsencrypt
        /var/log/letsencrypt
      }.each do |path|
        expect(chef_run).to create_directory(path).with({
          owner: 'certbot',
          group: 'certbot',
        })
      end

    end
  end
end
