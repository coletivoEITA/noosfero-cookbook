require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoRails < NoosferoResource
    self.resource_name = :noosfero_rails
    actions :configure
    default_action :configure

    attribute :env, kind_of: String, default: 'production'

    attribute :runner, kind_of: String, default: lazy{ |r| if r.version > '1.0' then 'rails runner' else 'script/runner' end }

    attribute :cache_store, kind_of: String, default: 'memcache'

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
