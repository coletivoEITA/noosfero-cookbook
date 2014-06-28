env = node[:noosfero][:environment]

rvm_shell "noosfero-create-environment" do
  user node[:noosfero][:user]; group node[:noosfero][:group]
  cwd node[:noosfero][:code_path]
  ruby_string node[:noosfero][:rvm_load]
  if env
    code <<-EOH
    RAILS_ENV=#{node[:noosfero][:rails_env]} script/runner '
        e = Environment.create! :name => "#{env[:name]}", :is_default => true, :default_language => "#{env[:default_language]}"
        e.domains.create! :name => "#{env[:domain]}", :is_default => true
      end
    '
    EOH
  end

  action :nothing # run by database creation
  not_if{ env.nil? }
end

