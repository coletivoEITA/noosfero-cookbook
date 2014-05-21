dependencies_with = node[:noosfero][:dependencies_with]

node[:noosfero]["packages_for_#{dependencies_with}"].each do |p|
  package p
end

if dependencies_with == 'bundler'
  bash 'bundle-install' do
    user node[:noosfero][:user]; group node[:noosfero][:group]
    cwd node[:noosfero][:code_path]
    command <<-EOH
      #{gems_load}
      bundle check || bundle install
    EOH
  end
elsif dependencies_with == 'quick_start'
  execute 'Run quick-start' do
    cwd node[:noosfero][:code_path]
    environment environment_variables
    command 'sh script/quick-start'
  end
end

