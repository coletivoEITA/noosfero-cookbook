group node[:noosfero][:group] do
  action :create
end
user node[:noosfero][:user] do
  supports :manage_home => true
  home "/home/#{node[:noosfero][:user]}"
  gid node[:noosfero][:group]
  action :create
end

git node[:noosfero][:code_path] do
  user node[:noosfero][:user]; group node[:noosfero][:group]
  repository node[:noosfero][:git_url]
  revision node[:noosfero][:git_revision]
  enable_submodules
  notifies :run, 'bash[noosfero-upgrade]'
  #action :sync
  action :nothing
end

# Directories
%w[ code_path data_path config_path log_path run_path tmp_path ].each do |path|
  directory node[:noosfero][path] do
    user node[:noosfero][:user]; group node[:noosfero][:group]
  end
end
if not node[:noosfero][:path]
  %w[ log run tmp ].each do |dir|
    link node[:noosfero][dir] do
      to "#{node[:noosfero][:code_path]}/#{dir}"
    end
  end
end

# Upgrade
bash "noosfero-upgrade" do
  user node[:noosfero][:user]; group node[:noosfero][:group]
  cwd node[:noosfero][:code_path]
  code <<-EOH
    #{gems_load}
    rake noosfero:translations:compile
    #{node[:noosfero][:upgrade_script]}
  EOH
  notifies :run, 'bash[bundle-install]' if node[:noosfero][:dependencies_with] == 'bundler'
  action :nothing
end
