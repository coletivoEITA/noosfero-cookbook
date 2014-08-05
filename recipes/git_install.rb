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
  enable_submodules true
  notifies :run, 'rvm_shell[noosfero-upgrade]'
  action :sync
end

# Directories
unless node[:noosfero][:paths_in_code]
  %w[ code_path data_path config_path log_path run_path tmp_path ].each do |path|
    directory node[:noosfero][path] do
      user node[:noosfero][:user]; group node[:noosfero][:group]
    end
  end
  %w[ log run tmp ].each do |dir|
    link "#{node[:noosfero][:code_path]}/#{dir}" do
      to node[:noosfero]["#{dir}_path"]
      not_if{ node[:noosfero]["#{dir}_path"].start_with? node[:noosfero][:code_path] }
    end
  end

  # data paths
  # recursive option is not used as it don't preserve user/group
  %w[ index solr public public/articles public/image_uploads public/thumbnails ].each do |dir|
    directory "#{node[:noosfero][:data_path]}/#{dir}" do
      user node[:noosfero][:user]; group node[:noosfero][:group]
    end
  end
  %w[ index solr public/articles public/image_uploads public/thumbnails ].each do |dir|
    link "#{node[:noosfero][:code_path]}/#{dir}" do
      to "#{node[:noosfero][:data_path]}/#{dir}"
      not_if{ node[:noosfero][:data_path].start_with? node[:noosfero][:code_path] }
    end
  end

  # TODO: link configurations??

end

# Upgrade
rvm_shell "noosfero-upgrade" do
  user node[:noosfero][:user]; group node[:noosfero][:group]
  cwd node[:noosfero][:code_path]
  ruby_string node[:noosfero][:ruby_string]
  code <<-EOH
    export RAILS_ENV=#{node[:noosfero][:rails_env]}
    rake noosfero:translations:compile
    #{node[:noosfero][:upgrade_script]}
  EOH
  notifies :run, 'rvm_shell[noosfero-bundle-install]' if node[:noosfero][:dependencies_with] == 'bundler'
  notifies :restart, "service[#{node[:noosfero][:service_name]}]"
  action :nothing
end
