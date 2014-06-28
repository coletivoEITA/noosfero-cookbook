# Backend
server_backend = node[:noosfero][:server][:backend]

if server_backend == 'unicorn'
  template "#{node[:noosfero][:code_path]}/config/unicorn.conf.rb" do
    variables node[:noosfero]

    action :create
    notifies :restart, "service[#{node[:noosfero][:service_name]}]"
  end
end
template "#{node[:noosfero][:code_path]}/config/thin.yml" do
  vars = node[:noosfero].to_hash
  vars['server']['workers'] = 0 if server_backend == 'unicorn'
  variables vars

  action :create
  notifies :restart, "service[#{node[:noosfero][:service_name]}]"
end

# Proxy
case node[:noosfero][:server][:proxy]
when 'nginx'
  include_recipe 'nginx'

  template "#{node[:nginx][:dir]}/sites-enabled/#{node[:noosfero][:service_name]}" do
    source "nginx.conf.erb"
    owner node[:nginx][:user]
    group node[:nginx][:group]
    variables node[:noosfero]
    notifies :reload, "service[nginx]"
    action :create
  end
when 'apache'
  include_recipe 'apache2'

  web_app node[:noosfero][:service_name] do
    enable true

    node[:noosfero].each do |key, value|
      send key, value
    end
  end
  notifies :reload, "service[apache2]"
end
