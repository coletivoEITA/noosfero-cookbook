plugins = node[:noosfero][:plugins].dup

include_recipe 'java' if plugins.include? 'solr'

enabled_plugins = []
ruby_block "find-enabled-plugins" do
  block do
    plugins = `sh -c 'cd #{node[:noosfero][:code_path]}/config/plugins && echo */'`
    enabled_plugins = plugins.split '/ '
  end
end
plugins.sort!
enabled_plugins.sort!
if plugins != enabled_plugins
  bash "disable-all-plugins" do
    user node[:noosfero][:user]; group node[:noosfero][:group]
    cwd node[:noosfero][:code_path]
    command "script/noosfero-plugins disableall"
  end
  bash "enabled-selected-plugins" do
    user node[:noosfero][:user]; group node[:noosfero][:group]
    cwd node[:noosfero][:code_path]
    command "script/noosfero-plugins enable #{plugins}"
    notifies :restart, "service[#{node[:noosfero][:service_name]}]"
  end
end

# Plugin: solr
template "#{node[:noosfero][:code_path]}/plugins/solr/config/solr.yml" do
  variables node[:noosfero]

  action :create
end if node[:noosfero][:plugins].include? 'solr'
