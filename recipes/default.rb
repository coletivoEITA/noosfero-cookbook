#
# Cookbook Name:: noosfero
# Recipe:: default
#
# Copyright 2014, Bráulio Bhavamitra <braulio@eita.org.br>
#
# GPLv3+
#

Noosfero::Helpers.init
::Chef::Resource::Bash.send :include, Noosfero::Helpers

include_recipe 'noosfero::install'
include_recipe 'noosfero::settings'
include_recipe 'noosfero::plugins'
include_recipe 'noosfero::varnish' if node[:noosfero][:cache][:server] == 'varnish'
include_recipe 'noosfero::proxy_server'
include_recipe 'noosfero::server'
include_recipe 'noosfero::init'

