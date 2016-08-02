describe 'fake::certonly-webroot' do
  context 'with two certonly webroots' do
    cached(:chef_run) do
      solo = ChefSpec::SoloRunner.new(step_into: ['certbot_certonly_webroot']).converge(described_recipe)
    end

    it "will create a single domain certificate" do
      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite1.dev --agree-tos --non-interactive').with({
        user: 'certbot'
      })
    end

    it "will create a multi domain certificate" do
      expect(chef_run).to run_execute('certbot certonly --webroot --webroot-path /var/www/certbot --email root@localhost --domains mysite2.dev,js.mysite2.dev,css.mysite2.dev --expand --agree-tos --non-interactive').with({
        user: 'certbot'
      })
    end
  end

  context 'with a certonly webroot that has not agreed TOS' do
    cached(:chef_run) do
      solo = ChefSpec::SoloRunner.new(step_into: ['certbot_certonly_webroot']).converge('fake::certonly-webroot-disagree')
    end

    it "will raise an error" do
      expect{chef_run}.to raise_error
    end
  end
end
