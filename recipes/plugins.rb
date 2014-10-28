if node[:noosfero][:plugins] == 'all'
  cmd = Mixlib::ShellOut.new "sh -c 'cd #{node[:noosfero][:code_path]}/plugins && echo */'"
  overview = cmd.run_command
  plugins = overview.stdout.split("\n").first.gsub('/', '').split(' ').sort
else
  plugins = node[:noosfero][:plugins].sort
end

rvm_shell "noosfero-enabled-selected-plugins" do
  user node[:noosfero][:user]; group node[:noosfero][:group]
  cwd node[:noosfero][:code_path]
  ruby_string node[:noosfero][:ruby_version]
  code <<-EOH
    script/noosfero-plugins disableall
    script/noosfero-plugins enable #{plugins.join ' '}
  EOH

  notifies :restart, "service[#{node[:noosfero][:service_name]}]"
  # install plugins' Gemfile
  notifies :run, "rvm_shell[noosfero-bundle-install]"

  only_if do
    cmd = Mixlib::ShellOut.new "sh -c 'cd #{node[:noosfero][:code_path]}/config/plugins && echo */'"
    overview = cmd.run_command
    current_enabled_plugins = overview.stdout.split("\n").first.gsub('/', '').split(' ').sort
    plugins != current_enabled_plugins
  end
end

# Plugin: solr
if plugins.include? 'solr'
  include_recipe 'java'

  template "#{node[:noosfero][:code_path]}/plugins/solr/config/solr.yml" do
    variables node[:noosfero]

    action :create
  end
end
