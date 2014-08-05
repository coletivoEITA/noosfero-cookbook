
if node[:noosfero][:awstats][:enable]
  include_recipe 'awstats'

  awstats_domain_statistics node[:noosfero][:server_name] do
    domain_name node[:noosfero][:server_name]
    host_aliases node[:noosfero][:custom_domains].join(' ')

    log_location node[:noosfero][:access_log_path]
    log_type 'web'
    log_format 'combined'

    overides = JSON.parse node[:noosfero][:awstats].to_json
    overides.reject!{ |k,v| %w[domain enable htpasswd].include? k.to_s }
    overides.each do |key, value|
      send key, value
    end
  end

  if node[:noosfero][:awstats][:htpasswd][:enable]
    htpasswd '/etc/apache2/htpasswd_awstats' do
      user node[:noosfero][:awstats][:htpasswd][:user]
      password node[:noosfero][:awstats][:htpasswd][:password]
    end
  end

  if node[:noosfero][:awstats][:domain]
    site = "#{node[:noosfero][:service_name]}_awstats.conf"
    template "#{node[:apache][:dir]}/sites-available/#{site}" do
      source "awstats_apache.conf.erb"
      owner node[:apache][:user]
      group node[:apache][:group]
      variables node[:noosfero][:awstats]
    end
    apache_site site do
      enable true
    end
  end
end
