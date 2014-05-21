template "#{node['noosfero']['code_path']}/config/noosfero.yml" do
  variables node['noosfero']

  notifies :restart, "service[#{node['noosfero']['service_name']}]"
end
