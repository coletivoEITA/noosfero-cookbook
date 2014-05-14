#
# Cookbook Name:: noosfero
# Recipe:: default
#
# Copyright 2014, Bráulio Bhavamitra <braulio@eita.org.br>
#
# GPLv3+
#

default['noosfero']['service_name'] = "noosfero"
service_name = node['noosfero']['service_name']

default['noosfero']['path'] = "/usr/share/noosfero"
if node['noosfero']['path']
  default['noosfero']['code_path'] = node['noosfero']['path']
  default['noosfero']['data_path'] = node['noosfero']['path']
  %w[ config log run tmp ].each do |dir|
    default['noosfero']['code_path'] = "#{node['noosfero']['path']}/#{dir}"
  end
else
  default['noosfero']['code_path'] = "/usr/share/#{service_name}"
  default['noosfero']['data_path'] = "/var/lib/#{service_name}"
  default['noosfero']['config_path'] = "/etc/#{service_name}"
  default['noosfero']['log_path'] = "/var/log/#{service_name}"
  default['noosfero']['run_path'] = "/var/run/#{service_name}"
  default['noosfero']['tmp_path'] = "/var/tmp/#{service_name}"
end

default['noosfero']['user'] = "noosfero"
default['noosfero']['group'] = "noosfero"

default['noosfero']['git_url'] = "https://gitlab.com/noosfero/noosfero.git"
default['noosfero']['git_revision'] = "stable"

default['noosfero']['dependencies_with'] = 'packages'

default['noosfero']['use_varnish'] = true
default['noosfero']['proxy_server'] = 'apache'
default['noosfero']['server'] = {}
default['noosfero']['server']['backend'] = 'thin'
default['noosfero']['server']['workers'] = 4
default['noosfero']['server']['port'] = 50000

default['noosfero']['db'] = {}
default['noosfero']['db']['name'] = service_name
default['noosfero']['db']['hostname'] = 'localhost'
default['noosfero']['db']['port'] = ''
default['noosfero']['db']['username'] = node['noosfero']['user']
default['noosfero']['db']['password'] = ''

default['noosfero']['plugins'] = []

