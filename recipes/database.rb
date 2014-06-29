if Chef::Config[:solo]
  if node[:noosfero][:db][:password].nil?
    Chef::Application.fatal! "The db password is necessary when using Chef::Solo"
  end
else
  node.set_unless[:noosfero][:db][:password] = secure_password
  node.save
end

include_recipe 'postgresql'
package 'libpq-dev'
chef_gem 'pg'
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
  if node[:noosfero][:db][:create_from_dump]
    notifies :run, 'rvm_shell[noosfero-load-dump]'
  else
    notifies :run, 'rvm_shell[noosfero-schema-load]'
    notifies :run, 'rvm_shell[noosfero-create-environment]'
  end
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

rvm_shell "noosfero-load-dump" do
  user node[:noosfero][:user]; group node[:noosfero][:group]
  cwd node[:noosfero][:code_path]
  ruby_string node[:noosfero][:rvm_load]
  code <<-EOH
    psql #{node[:noosfero][:db][:name]} < #{node[:noosfero][:db][:create_from_dump]}
  EOH
  action :nothing # run by database creation
end

rvm_shell "noosfero-schema-load" do
  user node[:noosfero][:user]; group node[:noosfero][:group]
  cwd node[:noosfero][:code_path]
  ruby_string node[:noosfero][:rvm_load]
  code <<-EOH
    RAILS_ENV=#{node[:noosfero][:rails_env]}
    rake db:schema:load
  EOH
  action :nothing # run by database creation
end

include_recipe 'noosfero::environment'

