default[:noosfero][:server] = {}
default[:noosfero][:server][:proxy] = 'nginx'
default[:noosfero][:server][:backend] = 'thin'
default[:noosfero][:server][:workers] = 4
default[:noosfero][:server][:port] = 50000
default[:noosfero][:server][:proxy_to_cache] = node[:noosfero][:ssl][:enable] and node[:noosfero][:cache][:server] == 'varnish'
default[:noosfero][:server][:timeout] =
  case node[:noosfero][:server][:backend]
  when 'thin' then 30
  when 'unicorn'
    case node[:noosfero][:server][:proxy]
    when 'apache' then 20*60
    when 'nginx' then 60
    end
  end
default[:noosfero][:server][:proxy_port] =
  case node[:noosfero][:server][:proxy]
  when 'apache' then node[:apache][:listen_ports].first
  when 'nginx' then node[:nginx][:listen_ports].first
  end
default[:noosfero][:server][:proxy_backend_port] =
  if node[:noosfero][:server][:proxy_to_cache]
    node[:noosfero][:cache][:backend_port] || (node[:noosfero][:server][:proxy_port].to_i + 1)
  else
    node[:noosfero][:server][:proxy_port]
  end
default[:noosfero][:server][:block_bots] = ['msnbot', 'Purebot', 'Baiduspider', 'Lipperhey', 'Mail.Ru', 'scrapbot']

default[:noosfero][:server][:backlog] = 2048
default[:noosfero][:server][:restart_on_requests] = [200,300]
default[:noosfero][:server][:restart_on_memory] = [208,256]
default[:noosfero][:server][:warmup_time] = 1
default[:noosfero][:server][:warmup_urls] = ['/admin/plugins', '/', '/profile/content'].map{ |path| "http://#{node[:noosfero][:server_name]}/#{path}" }

default[:noosfero][:server][:feed_updater] = {}
default[:noosfero][:server][:feed_updater][:enable] = true
