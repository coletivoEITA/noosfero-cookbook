#
# Cookbook Name:: noosfero
# Recipe:: default
#
# Copyright 2014, Bráulio Bhavamitra <braulio@eita.org.br>
#
# GPLv3+
#

# User/group
noosfero_user = node['noosfero']['user']
noosfero_group = node['noosfero']['group']

user noosfero_user do
  supports :manage_home => true
  home (if noosfero_user == 'noosfero' then noosfero['code_path'] else "/home/#{noosfero_user}" end)
  gid noosfero_group
  action :create
end

# Directories
path = node['noosfero']['path']
%w[ code_path data_path config_path log_path run_path tmp_path ].each do |path|
  directory node['noosfero'][path] do
    owner noosfero_user; group noosfero_group
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
  cwd node['noosfero']['code_path']
  owner noosfero_user; group noosfero_group
  code <<-EOH
    rake noosfero:translations:compile
  EOH
end

# Code
git node['noosfero']['code_path'] do
  user noosfero_user; group noosfero_group
  repository node['noosfero']['git_url']
  revision node['noosfero']['git_revision']
  action :sync
  notifies :run, 'bash[noosfero-upgrade]'
end

# Dependencies

dependencies_with = node['noosfero']['dependencies_with']
if dependencies_with == 'packages'
  %w[ ruby rake po4a libgettext-ruby-util libgettext-ruby1.8 libsqlite3-ruby rcov librmagick-ruby libredcloth-ruby libhpricot-ruby libwill-paginate-ruby iso-codes libfeedparser-ruby libdaemons-ruby thin tango-icon-theme ].each do |p|
    package p
  end
elsif dependencies_with == 'bundler'
  %w[ po4a iso-codes tango-icon-theme curl libmagickwand-dev libpq-dev libreadline-dev libsqlite3-dev libxslt1-dev ].each do |p|
    package p
  end
  execute 'bundle install' do
    cwd node['noosfero']['code_path']
    command "bundle check || bundle install"
  end
end

# Database
template "#{node['noosfero']['code_path']}/config/database.yml" do
  variables node['noosfero']

  notifies :restart, "service[#{node['noosfero']['service_name']}]"
end

postgresql_database_user node['noosfero']['db']['username'] do
  connection node['noosfero']['db']
  action :create
end
postgresql_database node['noosfero']['db']['name'] do
  connection node['noosfero']['db']
  action :create
  notifies :run, 'bash[create-environment-if-needed]'
end

# Environment
bash "create-environment-if-needed" do
  cwd node['noosfero']['code_path']
  code <<-EOH
  script/runner '
  if (e = Environment.default).blank?
    e = Environment.create! :name => "#{node['noosfero']['environment']['name']}"
    e.domains.create! :name => "#{node['noosfero']['environment']['domain']}", :is_default => true
  end
  '
  EOH
end

# Settings
template "#{node['noosfero']['code_path']}/config/noosfero.yml" do
  variables({:settings => node['noosfero']['settings']})

  notifies :restart, "service[#{node['noosfero']['service_name']}]"
end

# Plugins
plugins = node['noosfero']['plugins']
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
  execute "disable-all-plugins" do
    cwd node['noosfero']['code_path']
    command "script/noosfero-plugins disableall"
  end
  execute "enabled-selected-plugins" do
    cwd node['noosfero']['code_path']
    command "script/noosfero-plugins enable #{plugins}"
    notifies :restart, "service[#{node['noosfero']['service_name']}]"
  end
end

# Server backend
server_backend = node['noosfero']['server']['backend']
template "#{node['noosfero']['code_path']}/config/thin.yml" do
  vars = node['noosfero']
  vars['server'].merge! :workers => 0 if server_backend == 'unicorn'
  variables vars

  action :create
end
if server_backend == 'unicorn'
  template "#{node['noosfero']['code_path']}/config/unicorn.conf.rb" do
    variables node['noosfero']

    action :create
  end
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
  node['varnish']['version'] = '2.1'
  include_recipe 'varnish'
end

# Init service
service node['noosfero']['service_name'] do
  init_command "/etc/init.d/#{node['noosfero']['service_name']}"
  action :enable
end
template "/etc/init.d/#{node['noosfero']['service_name']}" do
  source "init.d.erb"
  owner user
  group group
  variables node['noosfero']
  notifies :restart, "service[#{node['noosfero']['service_name']}]"
end

