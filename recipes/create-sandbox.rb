#
# Cookbook Name:: certbot
# Recipe:: create-sandbox
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

group node['certbot']['sandbox']['group'] do
  gid node['certbot']['sandbox']['gid'] if node['certbot']['sandbox']['gid']
end

user node['certbot']['sandbox']['user'] do
  uid node['certbot']['sandbox']['uid'] if node['certbot']['sandbox']['uid']
  gid node['certbot']['sandbox']['group']
end

[
  node['certbot']['sandbox']['webroot_path'],
  node['certbot']['config_dir'],
  node['certbot']['work_dir'],
  node['certbot']['logs_dir'],
].each do |path|
  directory path do
    owner node['certbot']['sandbox']['user']
    group node['certbot']['sandbox']['group']
  end
  execute "chown #{path}" do
    command "chown -R #{node['certbot']['sandbox']['user']}:#{node['certbot']['sandbox']['group']} #{path}"
  end
end
