describe 'certbot::nginx-webroot' do
  context 'with default configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it "will create a nginx configuration for certbot webroot plugin" do
      expect(chef_run).to create_template('/etc/nginx/certbot.conf')
    end
  end
end
