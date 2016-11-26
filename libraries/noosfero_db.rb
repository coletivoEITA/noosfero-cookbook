require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoDb < NoosferoResource
    self.resource_name = :noosfero_db
    actions :create
    default_action :create

    attribute :dbname, kind_of: String, default: lazy{ |r| r.service_name }

    attribute :hostname, kind_of: String, default: 'localhost'
    attribute :port, kind_of: String, default: lazy{ |r| node[:postgresql][:config][:port] }

    attribute :username, kind_of: String, default: lazy{ |r| r.user }
    attribute :password, kind_of: String, default: ''

    attribute :create_from_dump, kind_of: String, default: nil

  end

  class Provider::NoosferoDb < NoosferoProvider
    provides :noosfero_db

    action :create do
      if Chef::Config[:solo] and r.password.nil?
        Chef::Application.fatal! "The db password is necessary when using Chef::Solo"
      else
        # FIXME: how to save if we not using node attributes?
        #r.password secure_password
        #node.save
      end

      run_context.include_recipe 'postgresql::server'
      package 'libpq-dev'
      chef_gem 'pg'
      postgresql_connection = {
        host: '127.0.0.1',
        port: node[:postgresql][:config][:port],
        username: 'postgres',
        password: node[:postgresql][:password][:postgres],
      }

      postgresql_database_user r.username do
        password r.password

        connection postgresql_connection
        action :create
      end

      postgresql_database r.dbname do
        owner r.username
        if r.create_from_dump.present?
          notifies :load_dump, r, :immediately
        else
          notifies :schema_load, r, :immediately
          notifies :create, r.environment, :immediately if r.environment
        end

        connection postgresql_connection
        action :create
      end

      postgresql_database_user r.username do
        password r.password
        database_name r.dbname

        connection postgresql_connection
        action :grant
      end

      template "#{r.code_path}/config/database.yml" do
        variables site: r.site
        cookbook 'noosfero'

        notifies :restart, resources(service: r.service_name)
      end

    end

    action :load_dump do
      # FIXME: r cannot be seen inside shell block
      r = new_resource

      shell "#{r.service_name} db load dump" do
        code <<-EOH
psql #{r.dbname} < #{r.create_from_dump}
        EOH
      end
    end

    action :schema_load do
      # FIXME: r cannot be seen inside shell block
      r = new_resource

      shell "#{r.service_name} db schema load" do
        code <<-EOH
export RAILS_ENV=#{r.rails.env}
rake db:schema:load
        EOH
      end
    end

    action :nothing do
    end

  end

end
