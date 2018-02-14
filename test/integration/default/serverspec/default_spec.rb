require 'spec_helper'

describe 'Certbot' do
  let(:install_method) { $node['certbot']['install_method'] }
  let(:certbot_bin) { $node['certbot']['bin'] }

  let(:webroot_path) { $node['certbot']['sandbox']['webroot_path'] }
  let(:certbot_user) { $node['certbot']['sandbox']['user'] }
  let(:certbot_group) { $node['certbot']['sandbox']['group'] }
  let(:config_dir) { $node['certbot']['config_dir'] }
  let(:work_dir) { $node['certbot']['work_dir'] }
  let(:logs_dir) { $node['certbot']['logs_dir'] }
  let(:nginx_dir) { $node['nginx']['dir'] }
  let(:apache_conf_dir) { $node['apache']['conf_dir'] || $node['default']['apache']['dir'] }

  it 'should be installed' do
    case install_method
    when 'package'
      expect(package(certbot_bin)).to be_installed
    when 'certbot-auto'
      expect(file(certbot_bin)).to be_a_file
      expect(file(certbot_bin)).to be_mode 755
    end
  end

  it 'should be configured' do
    if $node['certbot']['sandbox']['enabled']
      expect(group(certbot_group)).to exist
      expect(user(certbot_user)).to exist
      expect(user(certbot_user)).to belong_to_group certbot_group

      [webroot_path, config_dir, work_dir, logs_dir].each do |dir|
        expect(file(dir)).to be_directory
        expect(file(dir)).to be_owned_by certbot_user
        expect(file(dir)).to be_grouped_into certbot_group
      end
    end

    if $node['certbot']['services']['nginx']
      expect(file(nginx_dir)).to be_directory
      expect(file("#{nginx_dir}/certbot.conf")).to be_file
    end

    if $node['certbot']['services']['apache2']
      expect(file(apache_dir)).to be_directory
      expect(file("#{apache_dir}/certbot.conf")).to be_file
    end
  end
end
