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
    default['noosfero']["#{dir}_path"] = "#{node['noosfero']['path']}/#{dir}"
  end
else
  default['noosfero']['code_path'] = "/usr/share/#{service_name}"
  default['noosfero']['data_path'] = "/var/lib/#{service_name}"
  default['noosfero']['config_path'] = "/etc/#{service_name}"
  default['noosfero']['log_path'] = "/var/log/#{service_name}"
  default['noosfero']['run_path'] = "/var/run/#{service_name}"
  default['noosfero']['tmp_path'] = "/var/tmp/#{service_name}"
end

default['noosfero']['rails_env'] = "production"

default['noosfero']['user'] = "noosfero"
default['noosfero']['group'] = "noosfero"

default['noosfero']['git_url'] = "https://gitlab.com/noosfero/noosfero.git"
default['noosfero']['git_revision'] = "stable"

default['noosfero']['upgrade_script'] = ''

default['noosfero']['rvm_load'] = ''
default['noosfero']['dependencies_with'] = 'packages'

default['noosfero']['packages_for_packages'] = %w[ ruby rake po4a libgettext-ruby-util libgettext-ruby1.8 libsqlite3-ruby rcov librmagick-ruby libredcloth-ruby libhpricot-ruby libwill-paginate-ruby iso-codes libfeedparser-ruby libdaemons-ruby thin tango-icon-theme ]
default['noosfero']['packages_for_bundler'] = %w[ po4a iso-codes tango-icon-theme curl libmagickwand-dev libpq-dev libreadline-dev libsqlite3-dev libxslt1-dev ]

default['noosfero']['varnish'] = {}
default['noosfero']['varnish']['enable'] = true
default['noosfero']['proxy_server'] = 'apache'
default['noosfero']['server'] = {}
default['noosfero']['server']['backend'] = 'thin'
default['noosfero']['server']['workers'] = 4
default['noosfero']['server']['port'] = 50000
default['noosfero']['server']['timeout'] = 30

default['noosfero']['db'] = {}
default['noosfero']['db']['name'] = service_name
default['noosfero']['db']['hostname'] = 'localhost'
default['noosfero']['db']['port'] = ''
default['noosfero']['db']['username'] = node['noosfero']['user']
default['noosfero']['db']['password'] = ''

default['noosfero']['plugins'] = []

default['noosfero']['plugins_settings'] = {}
default['noosfero']['plugins_settings']['solr'] = {}
default['noosfero']['plugins_settings']['solr']['address'] = "127.0.0.1"
default['noosfero']['plugins_settings']['solr']['port'] = 8983
default['noosfero']['plugins_settings']['solr']['memory'] = 128
default['noosfero']['plugins_settings']['solr']['timeout'] = 0


