if node[:noosfero][:cache][:server] == 'varnish'
  raise "node[:varnish][:vcl_cookbook] not using noosfero!" if node[:varnish][:vcl_cookbook] != 'noosfero'

  include_recipe 'varnish'
end
