require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoCache < NoosferoResource
    provides :noosfero_cache

    actions :install
    default_action :install

    property :with, String, default: 'varnish', equal_to: %w[ varnish proxy ]

    property :address, String, default: (lazy do |r|
      case r.with
      when 'varnish' then node[:varnish][:listen_address]
      else '127.0.0.1'
      end
    end)
    property :port, String, default: (lazy do |r|
      case r.with
      when 'varnish' then node[:varnish][:listen_port]
      when 'proxy' then r.server.proxy.port
      end
    end)

    property :backend_port, Integer, default: (lazy do |r|
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
    property :key_zone, String, default: 'main'
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
