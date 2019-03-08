#
# Cookbook Name:: certbot
# Recipe:: cron
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

template '/usr/local/sbin/certbot-renew.sh' do
  variables(
    lazy do
      { services: node['certbot']['renew_post_services'] }
    end
  )
  mode 0755
end

cron_d node['certbot']['cron_name'] do
  command '/usr/local/sbin/certbot-renew.sh'
  user 'root'
  (node['certbot']['cron'] || node['certbot']['default_cron']).each do |key, value|
    send key, value
  end
end
