require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoRails < NoosferoResource
    provides :noosfero_rails

    actions :configure
    default_action :configure

    property :env, String, default: 'production'

    property :runner, String, default: lazy{ |r| if r.version > '1.0' then 'rails runner' else 'script/runner' end }

    property :cache_store, String, default: 'memcache'

  end

  class Provider::NoosferoRails < NoosferoProvider
    action :configure do
      case r.cache_store
      when'memcache'
        run_context.include_recipe 'memcached'
      when 'redis'
        run_context.include_recipe 'redis2'
      end
    end

  end

end
