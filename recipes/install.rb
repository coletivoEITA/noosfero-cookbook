if node[:noosfero][:install_from] == 'git'
  include_recipe 'noosfero::git_install'
  include_recipe 'noosfero::dependencies'
  include_recipe 'noosfero::database'
elsif node[:noosfero][:install_from] == 'package'
  include_recipe 'noosfero::package_install'
end
