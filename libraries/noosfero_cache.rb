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

    # varnish
    attribute :backend_port, kind_of: Integer, default: lazy{ |r| r.server.proxy_port }

    # nginx
    attribute :key_zone, kind_of: String, default: 'main'
  end

  class Provider::NoosferoCache < NoosferoProvider

    action :install do
      if r.server == 'varnish'
        raise "node[:varnish][:vcl_cookbook] not using noosfero!" if node[:varnish][:vcl_cookbook] != 'noosfero'

        run_context.include_recipe 'varnish'
      end
    end

  end
end
