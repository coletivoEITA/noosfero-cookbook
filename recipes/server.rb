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

  template "#{node[:nginx][:dir]}/sites-available/#{node[:noosfero][:service_name]}" do
    source "nginx.conf.erb"
    owner node[:nginx][:user]
    group node[:nginx][:group]
    variables node[:noosfero]
    notifies :reload, "service[nginx]"
  end
  nginx_site node[:noosfero][:service_name] do
    enable true
  end
when 'apache'
  include_recipe 'apache2'

  template "#{node[:apache][:dir]}/sites-available/#{node[:noosfero][:service_name]}" do
    source "apache2.conf.erb"
    owner node[:apache][:user]
    group node[:apache][:group]
    variables node[:noosfero]
    notifies :reload, "service[apache]"
  end
  apache_site node[:noosfero][:service_name] do
    enable true
  end
end
