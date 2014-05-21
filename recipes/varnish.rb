raise "node[:varnish][:version] not using version 2.1!" if node[:varnish][:version] != '2.1'
raise "node[:varnish][:vcl_cookbook] not using noosfero!" if node[:varnish][:vcl_cookbook] != 'noosfero'

include_recipe 'varnish'

