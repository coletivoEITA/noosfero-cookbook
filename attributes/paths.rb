
default[:noosfero][:paths_in_code] = false
default[:noosfero][:path] = nil
default[:noosfero][:code_path] = node[:noosfero][:path] if node[:noosfero][:path]
default[:noosfero][:user_install] = !node[:noosfero][:path].empty?

if node[:noosfero][:paths_in_code]
  %w[ config log run tmp ].each do |dir|
    default[:noosfero]["#{dir}_path"] = "#{node[:noosfero][:code_path]}/#{dir}"
  end
  default[:noosfero]["pids_path"] = "#{node[:noosfero][:tmp_path]}/pids"
elsif node[:noosfero][:user_install]
  %w[ data config log run tmp ].each do |dir|
    default[:noosfero]["#{dir}_path"] = "/home/#{node[:noosfero][:user]}/#{dir}"
  end
  default[:noosfero]["pids_path"] = "#{node[:noosfero][:tmp_path]}/pids"
else
  default[:noosfero][:code_path] = "/usr/share/#{service_name}"
  default[:noosfero][:data_path] = "/var/lib/#{service_name}"
  default[:noosfero][:config_path] = "/etc/#{service_name}"
  default[:noosfero][:log_path] = "/var/log/#{service_name}"
  default[:noosfero][:run_path] = "/var/run/#{service_name}"
  default[:noosfero][:tmp_path] = "/var/tmp/#{service_name}"
  default[:noosfero][:pids_path] = "/var/tmp/#{service_name}/pids"
end

default[:noosfero][:access_log_path] = "#{node[:noosfero][:log_path]}/access.log"
default[:noosfero][:error_log_path] = "#{node[:noosfero][:log_path]}/error.log"

