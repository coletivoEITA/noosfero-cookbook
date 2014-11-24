
default[:noosfero][:rails][:runner] = if node[:noosfero][:version] > '1.0' then 'rails runner' else 'script/runner' end
default[:noosfero][:rails][:cache_store] = 'memcache'

