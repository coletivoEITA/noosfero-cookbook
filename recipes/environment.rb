bash "create-environment-if-needed" do
  user node[:noosfero][:user]; group node[:noosfero][:group]
  cwd node[:noosfero][:code_path]
  code <<-EOH
    #{gems_load}
    RAILS_ENV=#{node[:noosfero][:rails_env]} script/runner '
      if (e = Environment.default).blank?
        e = Environment.create! :name => "#{node[:noosfero][:environment][:name]}"
        e.domains.create! :name => "#{node[:noosfero][:environment][:domain]}", :is_default => true
      end
    '
  EOH
  action :nothing # run by database creation
end
