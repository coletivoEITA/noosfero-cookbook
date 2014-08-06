include_recipe 'rvm'

dependencies_with = node[:noosfero][:dependencies_with]

node[:noosfero]["packages_for_#{dependencies_with}"].each do |p|
  package p do
  end
end

if dependencies_with == 'bundler'
  rvm_shell 'noosfero-bundle-install' do
    user node[:noosfero][:user]; group node[:noosfero][:group] if node[:noosfero][:ruby_version]
    cwd node[:noosfero][:code_path]
    ruby_string node[:noosfero][:ruby_version]
    code <<-EOH
      bundle check || bundle install
    EOH
  end
elsif dependencies_with == 'quick_start'
  rvm_shell 'noosfero-quick-start' do
    user node[:noosfero][:user]; group node[:noosfero][:group] if node[:noosfero][:ruby_version]
    cwd node[:noosfero][:code_path]
    ruby_string node[:noosfero][:ruby_version]
    code <<-EOH
      script/quick-start
    EOH
  end
end

