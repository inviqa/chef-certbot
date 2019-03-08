#
# Cookbook:: certbot
# Recipe:: configure
#
# Copyright 2016 Inviqa UK Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ruby_block 'detect web server services in use' do
  block do
    if node['certbot']['services']['nginx']
      node.default['certbot']['renew_post_services']['nginx'] = 'reload'
    end
    if node['certbot']['services']['apache2']
      service_name = node['apache']['service_name']
      node.default['certbot']['renew_post_services'][service_name] = 'reload'
    end
  end
end

include_recipe 'certbot::create-sandbox' if node['certbot']['sandbox']['enabled']
include_recipe 'certbot::server-webroots'
include_recipe 'certbot::cron'
