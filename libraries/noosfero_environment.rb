require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoEnvironment < NoosferoResource
    provides :noosfero_environment

    actions :create
    default_action :create

    property :name, String, default: lazy{ |r| r.service_name }
    property :domain, String, default: lazy{ |r| r.server_name }
    property :default_language, String, default: 'pt'
  end

  class Provider::NoosferoEnvironment < NoosferoProvider
    action :create do
      # FIXME: r cannot be seen inside shell block
      r = new_resource

      shell "#{r.service_name} create environment" do
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
