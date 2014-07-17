
default[:noosfero][:service_name] = "noosfero"
service_name = node[:noosfero][:service_name]

default[:noosfero][:rails_env] = "production"

default[:noosfero][:install_from] = "git"

default[:noosfero][:user] = service_name
default[:noosfero][:group] = service_name

default[:noosfero][:git_url] = "https://gitlab.com/noosfero/noosfero.git"
default[:noosfero][:git_revision] = "stable"

default[:noosfero][:upgrade_script] = ''

default[:noosfero][:path] = nil
if node[:noosfero][:path]
  default[:noosfero][:code_path] = node[:noosfero][:path]
  default[:noosfero][:data_path] = node[:noosfero][:path]
  %w[ config log run tmp ].each do |dir|
    default[:noosfero]["#{dir}_path"] = "#{node[:noosfero][:path]}/#{dir}"
  end
else
  default[:noosfero][:code_path] = "/usr/share/#{service_name}"
  default[:noosfero][:data_path] = "/var/lib/#{service_name}"
  default[:noosfero][:config_path] = "/etc/#{service_name}"
  default[:noosfero][:log_path] = "/var/log/#{service_name}"
  default[:noosfero][:run_path] = "/var/run/#{service_name}"
  default[:noosfero][:tmp_path] = "/var/tmp/#{service_name}"
end

default[:noosfero][:rvm_load] = "system"
default[:noosfero][:dependencies_with] = 'quick_start'

case node[:platform_family]
when 'debian', 'ubuntu'
  default[:noosfero][:packages_for_packages] = %w[ ruby rake po4a libgettext-ruby-util libgettext-ruby1.8 libsqlite3-ruby rcov librmagick-ruby libredcloth-ruby libhpricot-ruby libwill-paginate-ruby iso-codes libfeedparser-ruby libdaemons-ruby thin tango-icon-theme ]
  default[:noosfero][:packages_for_bundler] = %w[ po4a iso-codes tango-icon-theme curl libmagickwand-dev libpq-dev libreadline-dev libsqlite3-dev libxslt1-dev ]
  default[:noosfero][:packages_for_quick_start] = %w[]
end

default[:noosfero][:db] = {}
default[:noosfero][:db][:name] = service_name
default[:noosfero][:db][:hostname] = 'localhost'
default[:noosfero][:db][:port] = node[:postgresql][:config][:port]
default[:noosfero][:db][:username] = node[:noosfero][:user]
default[:noosfero][:db][:password] = nil
default[:noosfero][:db][:create_from_dump] = nil

default[:noosfero][:environment] = nil

default[:noosfero][:settings] = {}

default[:noosfero][:plugins] = []

default[:noosfero][:plugins_settings] = {}
default[:noosfero][:plugins_settings][:solr] = {}
default[:noosfero][:plugins_settings][:solr][:address] = "127.0.0.1"
default[:noosfero][:plugins_settings][:solr][:port] = 8983
default[:noosfero][:plugins_settings][:solr][:memory] = 128
default[:noosfero][:plugins_settings][:solr][:timeout] = 0

default[:varnish][:vcl_cookbook] = 'noosfero'
default[:noosfero][:cache] = {}
default[:noosfero][:cache][:server] = 'varnish'
default[:noosfero][:cache][:backend_port] = node[:noosfero][:server][:proxy_port]
default[:noosfero][:cache][:address] =
  case node[:noosfero][:cache][:server]
  when 'varnish' then node[:varnish][:listen_address]
  else '127.0.0.1'
  end
default[:noosfero][:cache][:port] =
  case node[:noosfero][:cache][:server]
  when 'varnish' then node[:varnish][:listen_port]
  when 'proxy' then node[:noosfero][:server][:proxy_port]
  end
default[:noosfero][:cache][:key_zone] = 'main'

default[:noosfero][:ssl] = {}
default[:noosfero][:ssl][:enable] = false
default[:noosfero][:ssl][:default] = true
default[:noosfero][:ssl][:redirect_http] = true

default[:noosfero][:server] = {}
default[:noosfero][:server][:proxy] = 'nginx'
default[:noosfero][:server][:backend] = 'thin'
default[:noosfero][:server][:workers] = 4
default[:noosfero][:server][:port] = 50000
default[:noosfero][:server][:proxy_to_cache] = node[:noosfero][:ssl][:enable] and node[:noosfero][:cache][:server] == 'varnish'
default[:noosfero][:server][:timeout] =
  case node[:noosfero][:server][:backend]
  when 'thin' then 30
  when 'unicorn' then 1200
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

default[:noosfero][:logrotate] = {}
default[:noosfero][:logrotate][:rotate] = 100_000
default[:noosfero][:logrotate][:frequency] = 'daily'

default[:noosfero][:backup] = {}
default[:noosfero][:backup][:enable] = false
default[:noosfero][:backup][:to] = {}
default[:noosfero][:backup][:to][:port] = 22
default[:noosfero][:backup][:to][:user] = "backup"
default[:noosfero][:backup][:to][:path] = "/home/#{node[:noosfero][:backup][:to][:user]}/#{node[:noosfero][:service_name]}/db"

