require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoCache < NoosferoResource
    self.resource_name = :noosfero_cache
    actions :install
    default_action :install

    attribute :with, kind_of: String, default: 'varnish', equal_to: %w[ varnish proxy ]

    attribute :address, kind_of: String, default: (lazy do |r|
      case r.with
      when 'varnish' then node[:varnish][:listen_address]
      else '127.0.0.1'
      end
    end)
    attribute :port, kind_of: String, default: (lazy do |r|
      case r.with
      when 'varnish' then node[:varnish][:listen_port]
      when 'proxy' then r.server.proxy.port
      end
    end)

    attribute :backend_port, kind_of: Integer, default: (lazy do |r|
      if r.server.proxy
        if r.server.proxy.to_cache
          r.server.proxy.port
        else
          r.server.port
        end
      else
        node[:varnish][:backend_port]
      end
    end)

    # for nginx
    attribute :key_zone, kind_of: String, default: 'main'
  end

  class Provider::NoosferoCache < NoosferoProvider

    action :install do
      case r.with
      when 'varnish'
        raise "node[:varnish][:vcl_cookbook] not using noosfero!" if node[:varnish][:vcl_cookbook] != 'noosfero'

        run_context.include_recipe 'varnish'
      end
    end

  end
end
