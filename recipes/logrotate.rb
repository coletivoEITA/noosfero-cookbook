include_recipe 'logrotate'

logs = [
  "#{node[:noosfero][:rails_env]}.log",
  "#{node[:noosfero][:rails_env]}_memory_consumption.log",
  "#{node[:noosfero][:rails_env]}_spammers.log",
  'delayed_job.log',
]

logrotate_app node[:noosfero][:service_name] do
  path logs.map{ |l| "#{node[:noosfero][:log_path]}/#{l}" }
  rotate node[:noosfero][:logrotate][:rotate]
  frequency node[:noosfero][:logrotate][:frequency]

  su "#{node[:noosfero][:user]} #{node[:noosfero][:group]}"
  create "644 #{node[:noosfero][:user]} #{node[:noosfero][:group]}"
end

proxy_logs = [
  'access.log',
  'error.log',
]
proxy = node[:noosfero][:server][:proxy]

logrotate_app "#{node[:noosfero][:service_name]}_proxy" do
  path proxy_logs.map{ |l| "#{node[:noosfero][:log_path]}/#{l}" }
  rotate node[:noosfero][:logrotate][:rotate]
  frequency node[:noosfero][:logrotate][:frequency]

  su "root root"
  create "644 #{node[:noosfero][:user]} #{node[:noosfero][:group]}"
end
