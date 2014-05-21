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
