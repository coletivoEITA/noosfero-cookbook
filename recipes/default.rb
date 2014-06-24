
Noosfero::Helpers.init

include_recipe 'memcached'

include_recipe 'noosfero::install'
include_recipe 'noosfero::settings'
include_recipe 'noosfero::plugins'
include_recipe 'noosfero::init'
include_recipe 'noosfero::logrotate'
include_recipe 'noosfero::varnish' if node[:noosfero][:cache][:server] == 'varnish'
include_recipe 'noosfero::server'

