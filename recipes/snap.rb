#
# Cookbook Name:: certbot
# Recipe:: snap
#
# Copyright 2021 anynines GmbH
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

package node['certbot']['package'] do
  action :purge
end

remote_file node['certbot']['bin'] do
  action :delete
end

package 'snapd'

execute 'install certbot snap' do
  command 'snap install --classic certbot'
  creates '/snap/bin/certbot'
  only_if { ::File.exist?('/usr/bin/snap') }
end

link '/usr/bin/certbot' do
  to '/snap/bin/certbot'
  action :create
end
