require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoBackup < NoosferoResource
    provides :noosfero_backup

    actions :configure
    default_action :configure

    property :host, String, default: nil, required: true
    property :port, Integer, default: 22
    property :user, String, default: 'backup'
    property :path, String, default: (lazy do |r|
      "/home/#{r.user}/#{node[:fqdn]}/#{r.service_name}/"
    end)
  end

  class Provider::NoosferoBackup < NoosferoProvider
    action :configure do
      run_context.include_recipe 'backup'

      backup_model r.service_name do
        description "Database and data files"
        schedule minute: 0, hour: 0

        template cookbook: 'noosfero', source: 'backup_model.rb.erb', variables: {
          site: r.site,
        }
      end
    end

  end
end
