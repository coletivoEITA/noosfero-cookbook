
if node[:noosfero][:backup][:enable]
  include_recipe 'backup'

  backup_model "#{node[:noosfero][:service_name]}_db" do
    description "Database backup"
    schedule :minute => 0, :hour => 0

    template :cookbook => 'noosfero', :source => 'backup_model.rb.erb', :variables => nnod[:noosfero]
  end
end
