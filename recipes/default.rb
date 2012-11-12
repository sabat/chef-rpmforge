#
# Cookbook Name:: rpmforge
# Recipe:: default
#
# Copyright 2012, xforty technologies
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
#

platform_version = node['platform_version'].match(/^(\d)/)[1].to_i
host_arch = node['kernel']['machine']

rpmforge_path_arch = host_arch
rpmforge_pkg_arch = if host_arch == 'i686' && platform_version <= 5
    'i386'
  else
    host_arch
  end

rpmforge_pkg_url = node['rpmforge']['rpm_url']
  .gsub(/__PATH_ARCH__/, rpmforge_path_arch)
  .gsub(/__PKG_ARCH__/, rpmforge_pkg_arch)
  .gsub(/__PLATFORM_VERSION__/, platform_version.to_s)

# Add the rpmforge repo so we can install common packages on redhat
# distros later in the run list.  http://dag.wieers.com/rpm/FAQ.php#B2
case node["platform"]
when "centos", "redhat", "fedora"
  execute "add_rpmforge_repo" do
    command "rpm -Uhv #{rpmforge_pkg_url}"
    not_if { File.exists?("/etc/yum.repos.d/rpmforge.repo") }
  end
end
