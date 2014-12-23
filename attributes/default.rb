
default[:noosfero][:service_name] = "noosfero"
service_name = node[:noosfero][:service_name]

default[:noosfero][:rails_env] = "production"

default[:noosfero][:version] = "1.0.0"

default[:noosfero][:install_from] = "git"

default[:noosfero][:user] = service_name
default[:noosfero][:group] = service_name

default[:noosfero][:server_name] = nil
default[:noosfero][:custom_domains] = []
default[:noosfero][:redirects] = {}

default[:noosfero][:git_url] = "https://gitlab.com/noosfero/noosfero.git"
default[:noosfero][:git_revision] = "stable"

default[:noosfero][:upgrade_script] = ''

default[:noosfero][:paths_in_code] = false
default[:noosfero][:path] = nil
default[:noosfero][:code_path] = node[:noosfero][:path] if node[:noosfero][:path]
default[:noosfero][:user_install] = !node[:noosfero][:path].empty?

if node[:noosfero][:paths_in_code]
  %w[ config log run tmp ].each do |dir|
    default[:noosfero]["#{dir}_path"] = "#{node[:noosfero][:code_path]}/#{dir}"
  end
elsif node[:noosfero][:user_install]
  %w[ data config log run tmp ].each do |dir|
    default[:noosfero]["#{dir}_path"] = "/home/#{node[:noosfero][:user]}/#{dir}"
  end
else
  default[:noosfero][:code_path] = "/usr/share/#{service_name}"
  default[:noosfero][:data_path] = "/var/lib/#{service_name}"
  default[:noosfero][:config_path] = "/etc/#{service_name}"
  default[:noosfero][:log_path] = "/var/log/#{service_name}"
  default[:noosfero][:run_path] = "/var/run/#{service_name}"
  default[:noosfero][:tmp_path] = "/var/tmp/#{service_name}"
end

default[:noosfero][:access_log_path] = "#{node[:noosfero][:log_path]}/access.log"
default[:noosfero][:error_log_path] = "#{node[:noosfero][:log_path]}/error.log"

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
default[:noosfero][:plugins_settings][:solr][:timeout] = 600

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


default[:noosfero][:logrotate] = {}
default[:noosfero][:logrotate][:rotate] = 100_000
default[:noosfero][:logrotate][:frequency] = 'daily'
default[:noosfero][:logrotate][:options] = ['copytruncate', 'compress', 'delaycompress', 'notifempty', 'missingok']

default[:backup][:version_from_git?] = true
default[:backup][:git_repo] = 'https://github.com/coletivoEITA/backup.git'

default[:noosfero][:backup] = {}
default[:noosfero][:backup][:enable] = false
default[:noosfero][:backup][:to] = {}
default[:noosfero][:backup][:to][:port] = 22
default[:noosfero][:backup][:to][:user] = "backup"
default[:noosfero][:backup][:to][:path] = "/home/#{node[:noosfero][:backup][:to][:user]}/#{node[:fqdn]}/#{node[:noosfero][:service_name]}/"

default[:noosfero][:awstats] = {}
default[:noosfero][:awstats][:enable] = false
default[:noosfero][:awstats][:cron_minute] = '*/15'
default[:noosfero][:awstats][:domain] = "stats.#{node[:noosfero][:server_name]}"
default[:noosfero][:awstats][:htpasswd] = {}
default[:noosfero][:awstats][:htpasswd][:enable] = true
default[:noosfero][:awstats][:htpasswd][:user] = node[:noosfero][:service_name]
default[:noosfero][:awstats][:htpasswd][:password] = node[:noosfero][:awstats][:htpasswd][:user].reverse

