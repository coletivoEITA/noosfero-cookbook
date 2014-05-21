server_backend = node[:noosfero][:server][:backend]

if server_backend == 'unicorn'
  template "#{node['noosfero']['code_path']}/config/unicorn.conf.rb" do
    variables node['noosfero']

    action :create
  end
end
template "#{node['noosfero']['code_path']}/config/thin.yml" do
  vars = node['noosfero'].to_hash
  vars['server']['workers'] = 0 if server_backend == 'unicorn'
  variables vars

  action :create
end

