require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoAwstats < NoosferoResource
    provides :noosfero_awstats

    actions :configure
    default_action :configure

    property :domain, String, default: lazy{ |r| "stats.#{r.server_name}" }

    property :cron_minute, String, default: '*/15'

    property :htpasswd_enabled, Boolean, default: true
    property :htpasswd_user, String, default: lazy{ |r| r.service_name }
    property :htpasswd_password, String, default: lazy{ |r| r.service_name.reverse }

  end

  class Provider::NoosferoAwstats < NoosferoProvider
    action :configure do
      run_context.include_recipe 'awstats'

      awstats_domain_statistics r.server_name do
        domain_name r.server_name
        host_aliases r.custom_domains.join(' ')

        log_location r.access_log_path
        log_type 'web'
        log_format 'combined'
      end

      if r.htpasswd_enabled
        htpasswd '/etc/apache2/htpasswd_awstats' do
          user r.htpasswd_user
          password r.htpasswd_password
        end
      end

      if r.domain
        site = "#{r.service_name}_awstats"
        template "#{node[:apache][:dir]}/sites-available/#{site}.conf" do
          source "awstats_apache.conf.erb"
          cookbook 'noosfero'
          owner node[:apache][:user]
          group node[:apache][:group]
          variables site: r.site
        end
        apache_site site do
          enable true
        end
      end
    end

  end
end
