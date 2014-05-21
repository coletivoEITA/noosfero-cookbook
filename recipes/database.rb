include_recipe 'postgresql'

if Chef::Config[:solo]
  if node[:noosfero][:db][:password].nil?
    Chef::Application.fatal! "The db password is necessary when using Chef::Solo"
  end
else
  node.set_unless[:noosfero][:db][:password] = secure_password
  node.save
end

postgresql_connection = {
  :host => '127.0.0.1',
  :port => node[:postgresql][:config][:port],
  :username => 'postgres',
  :password => node[:postgresql][:password][:postgres],
}

postgresql_database_user node[:noosfero][:db][:username] do
  connection postgresql_connection
  password node[:noosfero][:db][:password]
  action :create
end
postgresql_database node[:noosfero][:db][:name] do
  connection postgresql_connection
  action :create
  notifies :run, 'bash[create-environment-if-needed]'
end
postgresql_database_user node[:noosfero][:db][:username] do
  connection postgresql_connection
  password node[:noosfero][:db][:password]
  database_name node[:noosfero][:db][:name]
  action :grant
end

template "#{node[:noosfero][:code_path]}/config/database.yml" do
  variables node[:noosfero]

  notifies :restart, "service[#{node[:noosfero][:service_name]}]"
end

#execute 'create-database' do
#  cwd node[:noosfero][:code_path]
#  command <<-EOH
#    sudo -u postgres createuser #{node[:noosfero][:db][:username]} --no-superuser --createdb --no-createrole
#    sudo -u #{node[:noosfero][:user]} createdb #{node[:noosfero][:db][:name]}
#    #{gems_load}
#    RAILS_ENV=#{rails_env} rake db:schema:load
#  EOH
#end

