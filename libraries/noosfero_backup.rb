require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoBackup < NoosferoResource
    self.resource_name = :noosfero_backup
    actions :configure
    default_action :configure

    attribute :host, kind_of: String, default: nil, required: true
    attribute :port, kind_of: Integer, default: 22
    attribute :user, kind_of: String, default: 'backup'
    attribute :path, kind_of: String, default: (lazy do |r|
      "/home/#{r.user}/#{node[:fqdn]}/#{r.service_name}/"
    end)
  end

  class Provider::NoosferoBackup < NoosferoProvider
    provides :noosfero_backup

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
