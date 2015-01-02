require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoProxy < NoosferoResource
    self.resource_name = :noosfero_proxy
    actions :install
    default_action :install

    attribute :with, kind_of: String, default: 'nginx', equal_to: ['nginx', 'apache']
    attribute :to_cache, kind_of: Boolean, default: (lazy do |r|
      r.server.ssl.enabled and r.server.cache.server == 'varnish' rescue true
    end)
    attribute :port, kind_of: Integer, default: (lazy do |r|
      case r.proxy
      when 'apache' then node[:apache][:listen_ports].first
      when 'nginx' then node[:nginx][:listen_ports].first
      end
    end)
    attribute :backend_port, kind_of: Integer, default: (lazy do |r|
      if r.to_cache
        r.server.cache.backend_port || (r.port + 1)
      else
        r.port
      end
    end)

  end

  class Provider::NoosferoProxy < NoosferoProvider

    action :install do
    end

  end
end

