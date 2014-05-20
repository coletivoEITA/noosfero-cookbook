#
# Cookbook Name:: noosfero
# Recipe:: default
#
# Copyright 2014, Bráulio Bhavamitra <braulio@eita.org.br>
#
# GPLv3+
#

Noosfero::Helpers.init
::Chef::Resource::Bash.send :include, Noosfero::Helpers

noosfero_user = node['noosfero']['user']
noosfero_group = node['noosfero']['group']
rails_env = node['noosfero']['rails_env']
dependencies_with = node['noosfero']['dependencies_with']
path = node['noosfero']['path']
server_backend = node['noosfero']['server']['backend']
plugins = node['noosfero']['plugins'].dup

# User/group
user noosfero_user do
  supports :manage_home => true
  home (if noosfero_user == 'noosfero' then noosfero['code_path'] else "/home/#{noosfero_user}" end)
  gid noosfero_group
  action :create
end

# Directories
%w[ code_path data_path config_path log_path run_path tmp_path ].each do |path|
  directory node['noosfero'][path] do
    user noosfero_user; group noosfero_group
  end
end
if not path
  %w[ log run tmp ].each do |dir|
    link node['noosfero'][path] do
      to "#{node['noosfero']['code_path']}/#{dir}"
    end
  end
end

# Upgrade
bash "noosfero-upgrade" do
  user noosfero_user; group noosfero_group
  cwd node['noosfero']['code_path']
  code <<-EOH
    #{rvm_load}
    rake noosfero:translations:compile
    #{node['noosfero']['upgrade_script']}
  EOH
  notifies :run, 'bash[bundle-install]' if dependencies_with == 'bundler'
end

# Code
git node['noosfero']['code_path'] do
  user noosfero_user; group noosfero_group
  repository node['noosfero']['git_url']
  revision node['noosfero']['git_revision']
  enable_submodules
  action :sync
  notifies :run, 'bash[noosfero-upgrade]'
end

# Dependencies

node['noosfero']["packages_for_#{dependencies_with}"].each do |p|
  package p
end
if dependencies_with == 'bundler'
  bash 'bundle-install' do
    user noosfero_user; group noosfero_group
    cwd node['noosfero']['code_path']
    command <<-EOH
      #{rvm_load}
      bundle check || bundle install
    EOH
  end
end

# Database
template "#{node['noosfero']['code_path']}/config/database.yml" do
  variables node['noosfero']

  notifies :restart, "service[#{node['noosfero']['service_name']}]"
end

# FIXME
#postgresql_database_user node['noosfero']['db']['username'] do
#  owner noosfero_user
#  action :create
#end
#postgresql_database node['noosfero']['db']['name'] do
#  connection node['noosfero']['db']
#  owner noosfero_user
#  action :create
#  notifies :run, 'bash[create-environment-if-needed]'
#end
#execute 'create-database' do
#   cwd node['noosfero']['code_path']
#  command <<-EOH
#    sudo -u postgres createuser #{node['noosfero']['db']['username']} --no-superuser --createdb --no-createrole
#    sudo -u #{noosfero_user} createdb #{node['noosfero']['db']['name']}
#    #{rvm_load}
#    RAILS_ENV=#{rails_env} rake db:schema:load
#  EOH
#end

# Environment
#bash "create-environment-if-needed" do
#  user noosfero_user; group noosfero_group
#  cwd node['noosfero']['code_path']
#  code <<-EOH
#    #{rvm_load}
#    RAILS_ENV=#{rails_env} script/runner '
#    if (e = Environment.default).blank?
#      e = Environment.create! :name => "#{node['noosfero']['environment']['name']}"
#      e.domains.create! :name => "#{node['noosfero']['environment']['domain']}", :is_default => true
#    end
#    '
#  EOH
#end

# Settings
template "#{node['noosfero']['code_path']}/config/noosfero.yml" do
  variables node['noosfero']

  notifies :restart, "service[#{node['noosfero']['service_name']}]"
end

# Plugins
include_recipe 'java' if plugins.include? 'solr'

enabled_plugins = []
ruby_block "find-enabled-plugins" do
  block do
    plugins = `sh -c 'cd #{node['noosfero']['code_path']}/config/plugins && echo */'`
    enabled_plugins = plugins.split '/ '
  end
end
plugins.sort!
enabled_plugins.sort!
if plugins != enabled_plugins
  bash "disable-all-plugins" do
    user noosfero_user; group noosfero_group
    cwd node['noosfero']['code_path']
    command "script/noosfero-plugins disableall"
  end
  bash "enabled-selected-plugins" do
    user noosfero_user; group noosfero_group
    cwd node['noosfero']['code_path']
    command "script/noosfero-plugins enable #{plugins}"
    notifies :restart, "service[#{node['noosfero']['service_name']}]"
  end
end

# Plugin: solr
template "#{node['noosfero']['code_path']}/plugins/solr/config/solr.yml" do
  variables node['noosfero']

  action :create
end if node['noosfero']['plugins'].include? 'solr'

# Server backend
if server_backend == 'unicorn'
  template "#{node['noosfero']['code_path']}/config/unicorn.conf.rb" do
    variables node['noosfero']

    action :create
  end
end
template "#{node['noosfero']['code_path']}/config/thin.yml" do
  vars = node['noosfero'].to_hash
  vars['server']['workers'] = 0 if server_backend == 'unicorn'
  variables vars

  action :create
end

# Web Server
if node['noosfero']['proxy_server'] == 'nginx'
  include_recipe 'nginx'

  template "#{node['nginx']['dir']}/sites-enabled/#{node['noosfero']['service_name']}" do
    source "nginx.conf.erb"
    owner node['nginx']['user']
    group node['nginx']['group']
    variables node['noosfero']
    notifies :reload, "service[nginx]"
    action :create
  end
elsif node['noosfero']['proxy_server'] == 'apache'
  include_recipe 'apache2'

  web_app node['noosfero']['service_name'] do
    enable true

    node['noosfero'].each do |key, value|
      send key, value
    end
  end
  notifies :reload, "service[apache2]"
end

# TODO
if varnish = node['noosfero']['use_varnish']
  include_recipe 'varnish'
  node['varnish']['version'] = '2.1'
end

# Init service
template "/etc/init.d/#{node['noosfero']['service_name']}" do
  source "init.d.erb"
  owner user
  group group
  mode "755"
  variables node['noosfero']
  notifies :restart, "service[#{node['noosfero']['service_name']}]"
  action :create
end
service node['noosfero']['service_name'] do
  init_command "/etc/init.d/#{node['noosfero']['service_name']}"
  action :enable
end
