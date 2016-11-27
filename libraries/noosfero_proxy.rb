require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoProxy < NoosferoResource
    provides :noosfero_proxy

    actions :install
    default_action :install

    property :with, String, default: 'nginx', equal_to: ['nginx', 'apache']
    property :to_cache, Boolean, default: (lazy do |r|
      r.server.ssl.enabled and r.server.cache.server == 'varnish' rescue true
    end)
    property :port, Integer, default: (lazy do |r|
      case r.with
      when 'apache' then node[:apache][:listen_ports].first
      when 'nginx' then node[:nginx][:listen_ports].first
      end
    end)
    property :backend_port, Integer, default: (lazy do |r|
      if r.to_cache
        r.server.cache.backend_port || (r.port + 1)
      else
        r.port
      end
    end)

  end

  class Provider::NoosferoProxy < NoosferoProvider
    action :install do
      case r.with
      when 'nginx'
        run_context.include_recipe 'nginx'

        template "#{node[:nginx][:dir]}/sites-available/#{r.service_name}" do
          source "nginx.conf.erb"
          cookbook 'noosfero'
          owner node[:nginx][:user]
          group node[:nginx][:group]
          variables site: r.site
          notifies :reload, "service[nginx]"
        end
        nginx_site r.service_name do
          enable true
        end
      when 'apache'
        run_context.include_recipe 'apache2'

        template "#{node[:apache][:dir]}/sites-available/#{r.service_name}.conf" do
          source "apache2.conf.erb"
          cookbook 'noosfero'
          owner node[:apache][:user]
          group node[:apache][:group]
          variables site: r.site
          notifies :reload, "service[apache]"
        end
        apache_site r.service_name do
          enable true
        end
      end
    end

  end
end

