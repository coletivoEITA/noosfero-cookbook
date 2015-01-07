
default[:nginx][:default][:modules] = ["http_spdy_module"]
default[:nginx][:source][:modules] = ["nginx::http_spdy_module"]

default[:backup][:version_from_git?] = true
default[:backup][:git_repo] = 'https://github.com/coletivoEITA/backup.git'

## varnish default vcl template
default[:varnish][:vcl_cookbook] = 'noosfero'

varnish_site = node[:noosfero][:sites].select do |site, values|
  cache = values[:server][:cache]
  cache and cache[:with] == 'varnish'
end.values.first

default[:noosfero][:varnish] = {}
if varnish_site
  # code replicated from noosfero_server LWRP
  code_path = varnish_site[:code_path] || varnish_site[:path] || '/usr/share/noosfero'
  default[:noosfero][:varnish][:backend_port] =
    if varnish_site[:server][:cache][:backend_port]
      varnish_site[:server][:cache][:backend_port]
    elsif varnish_site[:server][:proxy][:to_cache]
      varnish_site[:server][:proxy][:backend_port]
    else
      varnish_site[:server][:port] || 50000
    end

  default[:noosfero][:varnish][:includes] = [
    "#{code_path}/etc/noosfero/varnish-noosfero.vcl",
    "#{code_path}/etc/noosfero/varnish-accept-language.vcl",
  ]
end

