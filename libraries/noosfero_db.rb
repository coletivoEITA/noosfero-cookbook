require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoDb < NoosferoResource
    self.resource_name = :noosfero_db
    actions :create
    default_action :create

    attribute :name, kind_of: String, default: lazy{ |r| r.service_name }

    attribute :hostname, kind_of: String, default: 'localhost'
    attribute :port, kind_of: String, default: lazy{ |r| node[:postgresql][:config][:port] }

    attribute :username, kind_of: String, default: lazy{ |r| r.user }
    attribute :password, kind_of: String, default: ''

    attribute :create_from_dump, kind_of: String, default: nil

  end

  class Provider::NoosferoDb < NoosferoProvider

    action :create do
      if Chef::Config[:solo] and r.password.nil?
        Chef::Application.fatal! "The db password is necessary when using Chef::Solo"
      else
        # FIXME: how to save if we not using node attributes?
        #r.password secure_password
        #node.save
      end

      run_context.include_recipe 'postgresql'
      package 'libpq-dev'
      chef_gem 'pg'
      postgresql_connection = {
        host: '127.0.0.1',
        port: node[:postgresql][:config][:port],
        username: 'postgres',
        password: node[:postgresql][:password][:postgres],
      }

      postgresql_database_user r.username do
        connection postgresql_connection
        password r.password
        action :create
      end
      postgresql_database r.name do
        connection postgresql_connection
        action :create
        if r.create_from_dump
          notifies :load_dump, "noosfero_db[#{r.service_name}]"
        else
          notifies :schema_load, "noosfero_db[#{r.service_name}]"
          notifies :create, "noosfero_environment[#{r.service_name}]"
        end
      end
      postgresql_database_user r.username do
        connection postgresql_connection
        password r.password
        database_name r.name
        action :grant
      end

      template "#{r.code_path}/config/database.yml" do
        variables site: r.site
        cookbook 'noosfero'

        notifies :restart, "service[#{r.service_name}]"
      end

    end

    action :load_dump do
      shell "#{r.service_name}-db-load-dump" do
        code <<-EOH
psql #{r.name} < #{r.create_from_dump}
        EOH
      end
    end


    action :schema_load do
      shell "#{r.service_name}-db-schema-load" do
        code <<-EOH
export RAILS_ENV=#{r.rails.env}
rake db:schema:load
        EOH
      end
    end

  end

end
