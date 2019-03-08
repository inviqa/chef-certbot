#
# Cookbook Name:: certbot
# Recipe:: server-webroots
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

directory node['certbot']['sandbox']['webroot_path'] do
  recursive true
end

template "#{node['nginx']['dir']}/certbot.conf" do
  source 'certbot-nginx.conf.erb'
  only_if { node['certbot']['services']['nginx'] }
end if node['nginx']

template "#{node['apache']['conf_dir'] || node['apache']['dir']}/certbot.conf" do
  source 'certbot-apache.conf.erb'
  only_if { node['certbot']['services']['apache2'] }
end if node['apache']
