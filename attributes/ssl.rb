
default[:noosfero][:ssl] = {}
default[:noosfero][:ssl][:enable] = false
default[:noosfero][:ssl][:default] = true
default[:noosfero][:ssl][:spdy] = node[:noosfero][:ssl][:enable]
default[:noosfero][:ssl][:redirect_http] = true

