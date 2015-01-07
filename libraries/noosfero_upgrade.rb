require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoUpgrade < NoosferoResource
    self.resource_name = :noosfero_upgrade
    actions :run
    default_action :run
  end

  class Provider::NoosferoUpgrade < NoosferoProvider

    action :run do
      # FIXME: r cannot be seen inside shell block
      r = new_resource

      shell "#{r.service_name} upgrade" do
        code <<-EOH
export RAILS_ENV=#{r.rails.env}
rake noosfero:translations:compile
#{r.upgrade_script}
        EOH
        # a new dependency may appear on upgrade
        notifies :install, r.dependencies if r.dependencies
        notifies :restart, resources(service: r.service_name)
      end
    end
  end
end
