
if node[:noosfero][:backup][:enable]
  include_recipe 'backup'

  backup_model node[:noosfero][:service_name] do
    description "Database and data files"
    schedule :minute => 0, :hour => 0

    template :cookbook => 'noosfero', :source => 'backup_model.rb.erb', :variables => node[:noosfero]
  end
end
