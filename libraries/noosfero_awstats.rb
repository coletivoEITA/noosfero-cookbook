require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoAwstats < NoosferoResource
    self.resource_name = :noosfero_awstats
    actions :configure
    default_action :configure

    attribute :domain, kind_of: String, default: lazy{ |r| "stats.#{r.server_name}" }

    attribute :cron_minute, kind_of: String, default: '*/15'

    attribute :htpasswd_enabled, kind_of: Boolean, default: true
    attribute :htpasswd_user, kind_of: String, default: lazy{ |r| r.service_name }
    attribute :htpasswd_password, kind_of: String, default: lazy{ |r| r.service_name.reverse }

  end

  class Provider::NoosferoAwstats < NoosferoProvider

    action :configure do
      run_context.include_recipe 'awstats'

      skip_urls = Dir.chdir("#{r.code_path}/public"){ Dir.glob('*/').map{ |d| "^/#{d[0..-2]}" } }

      awstats_domain_statistics r.server_name do
        domain_name r.server_name
        host_aliases r.custom_domains.join(' ')

        log_location r.access_log_path
        log_type 'web'
        log_format 'combined'
        skipped_files skip_urls.map{ |u| "REGEX[#{u}]" }.join(' ')
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
