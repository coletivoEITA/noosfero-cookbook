require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoChat < NoosferoResource
    self.resource_name = :noosfero_chat
    actions :configure
    default_action :configure

    attribute :packages, kind_of: Array, default: %w[ejabberd odbc-postgresql unixodbc pidgin-data]

    attribute :port, kind_of: Fixnum, default: 5280

    attribute :ejabberd_user, kind_of: String, default: 'ejabberd'
    attribute :ejabberd_group, kind_of: String, default: 'ejabberd'

    attribute :schema_sql_path, kind_of: String, default: (lazy do |r|
      "#{r.site.code_path}/util/chat/postgresql/ejabberd.sql"
    end)

    attribute :odbc_dsn, kind_of: String, default: 'PostgreSQLEjabberdNoosfero'
    attribute :odbc_driver, kind_of: String, default: 'PostgreSQL Unicode'
  end

  class Provider::NoosferoChat < NoosferoProvider
    provides :noosfero_chat

    action :configure do
      # FIXME
      r = new_resource

      r.packages.each do |p|
        package p
      end

      template "/etc/ejabberd/ejabberd.cfg" do
        source "ejabberd.cfg.erb"
        cookbook 'noosfero'
        owner r.ejabberd_user
        group r.ejabberd_group
        variables site: r.site
      end
      template "/etc/default/ejabberd" do
        source "ejabberd_default.erb"
        cookbook 'noosfero'
        owner r.ejabberd_user
        group r.ejabberd_group
        variables site: r.site
      end

      template "/etc/odbc.ini" do
        source "ejabberd_odbc.ini.erb"
        cookbook 'noosfero'
        owner r.ejabberd_user
        group r.ejabberd_group
        mode '0640'
        variables site: r.site
      end
      template "/etc/odbcinst.ini" do
        source "ejabberd_odbcinst.ini.erb"
        cookbook 'noosfero'
        owner r.ejabberd_user
        group r.ejabberd_group
        variables site: r.site
      end

      shell "#{r.service_name} chat load schema" do
        code <<-EOH
if [[ `psql #{r.site.db.dbname} -tAc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'ejabberd' AND table_name = 'users');"` = 'f' ]]; then
  psql #{r.site.db.dbname} < #{r.schema_sql_path}
fi
        EOH
      end

      set_limit 'ejabberd' do
        type 'hard'
        item 'nofile'
        value 65536
      end
      set_limit 'ejabberd' do
        type 'soft'
        item 'nofile'
        value 65536
      end
      pam_config = "/etc/pam.d/su"
      commented_limits = /^#\s+(session\s+\w+\s+pam_limits\.so)\b/m
      ruby_block "#{r.service_name} chat add pam_limits to su" do
        block do
          sed = Chef::Util::FileEdit.new pam_config
          sed.search_file_replace commented_limits, '\1'
          sed.write_file
        end
        only_if { ::File.readlines(pam_config).grep(commented_limits).any? }
      end

      service 'ejabberd' do
        action :start
        supports restart: true
        subscribes :restart, 'template[/etc/default/ejabberd]'
        subscribes :restart, 'template[/etc/ejabberd/ejabberd.cfg]'
        subscribes :restart, 'template[/etc/odbcinst.ini]'
        subscribes :restart, 'template[/etc/odbc.ini]'
      end

    end

  end

end
