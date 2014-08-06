include_recipe 'logrotate'

logs = [
  "#{node[:noosfero][:rails_env]}.log",
  "#{node[:noosfero][:rails_env]}_memory_consumption.log",
  "#{node[:noosfero][:rails_env]}_spammers.log",
  'delayed_job.log',
]

logrotate_app node[:noosfero][:service_name] do
  enable true
  template_mode '0644'
  su "#{node[:noosfero][:user]} #{node[:noosfero][:group]}"
  create "644 #{node[:noosfero][:user]} #{node[:noosfero][:group]}"

  options node[:noosfero][:logrotate][:options]
  path logs.map{ |l| "#{node[:noosfero][:log_path]}/#{l}" }
  rotate node[:noosfero][:logrotate][:rotate]
  frequency node[:noosfero][:logrotate][:frequency]

  # copytruncate used
  #postrotate <<-EOD
  #  sudo service #{node[:noosfero][:service_name]} restart
  #EOD
end

proxy_service = case node[:noosfero][:server][:proxy]
                when 'apache' then 'apache2'
                when 'nginx' then 'nginx'
                end

logrotate_app "#{node[:noosfero][:service_name]}_proxy" do
  enable true
  template_mode '0644'
  su "root root"
  create "644 #{node[:noosfero][:user]} #{node[:noosfero][:group]}"

  options node[:noosfero][:logrotate][:options]
  path [node[:noosfero][:access_log_path], node[:noosfero][:error_log_path]]
  rotate node[:noosfero][:logrotate][:rotate]
  frequency node[:noosfero][:logrotate][:frequency]

  # copytruncate used
  #postrotate <<-EOD
  #  sudo service #{proxy_service} reload
  #EOD
end
