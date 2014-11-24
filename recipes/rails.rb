
case node[:noosfero][:rails][:cache_store]
when'memcache'
  include_recipe 'memcached'
when 'redis'
  include_recipe 'redis'
end

