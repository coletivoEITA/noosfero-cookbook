require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoEnvironment < NoosferoResource
    self.resource_name = :noosfero_environment
    actions :create
    default_action :create

    attribute :name, kind_of: String, default: lazy{ |r| r.service_name }
    attribute :domain, kind_of: String, default: lazy{ |r| r.server_name }
    attribute :default_language, kind_of: String, default: 'pt'
  end

  class Provider::NoosferoEnvironment < NoosferoProvider

    action :create do
      shell "#{r.service_name}-create-environment" do
        code <<-EOH
export RAILS_ENV=#{r.rails.env}
  #{r.rails.runner} '
  if (e = Environment.default).blank?
    e = Environment.create! :name => "#{r.environment.name}", :is_default => true, :default_language => "#{r.environment.default_language}"
    e.domains.create! :name => "#{r.environment.domain}", :is_default => true
  end
'
        EOH
      end

    end

  end

end
