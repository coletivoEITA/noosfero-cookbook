
default[:noosfero][:ssl] = {}
default[:noosfero][:ssl][:enable] = false
default[:noosfero][:ssl][:default] = true
default[:noosfero][:ssl][:spdy] = node[:noosfero][:ssl][:enable]
default[:noosfero][:ssl][:redirect_http] = true
# only safe protocols
default[:noosfero][:ssl][:protocols] = "TLSv1 TLSv1.1 TLSv1.2"

if node[:noosfero][:ssl][:spdy]
  default[:nginx][:default][:modules] = "http_spdy_module"
  default[:nginx][:source][:modules] = "nginx::http_spdy_module"
end

