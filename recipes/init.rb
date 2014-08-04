template "/etc/init.d/#{node[:noosfero][:service_name]}" do
  source "init.d.erb"
  mode "755"
  variables node[:noosfero]
  action :create
  notifies :restart, "service[#{node[:noosfero][:service_name]}]"
end
service node[:noosfero][:service_name] do
  supports :restart => true, :reload => false, :status => true
  action :start
end
