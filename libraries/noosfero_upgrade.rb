require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoUpgrade < NoosferoResource
    self.resource_name = :noosfero_upgrade
    actions :run
    default_action :run
  end

  class Provider::NoosferoUpgrade < NoosferoProvider

    action :run do
      shell "#{r.service_name}-upgrade" do
        code <<-EOH
export RAILS_ENV=#{r.rails.env}
rake noosfero:translations:compile
#{r.upgrade_script}
        EOH
        # a new dependency may appear on upgrade
        notifies :install, "noosfero_dependencies[#{r.service_name}]"
        notifies :restart, "service[#{r.service_name}]"
      end
    end
  end
end
