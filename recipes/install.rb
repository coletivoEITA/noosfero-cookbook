if node[:noosfero][:install_from] == 'git'
  include_recipe 'noosfero::git_install'
  include_recipe 'noosfero::dependencies'
  include_recipe 'noosfero::database'
  include_recipe 'noosfero::environment' if node[:noosfero][:environment]
elsif node[:noosfero][:install_from] == 'package'
  include_recipe 'noosfero::package_install'
end
