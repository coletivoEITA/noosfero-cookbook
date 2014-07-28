
if node[:noosfero][:backup][:enable]
  include_recipe 'backup'

  backup_model "#{node[:noosfero][:service_name]}_db" do
    description "Database backup"
    schedule :minute => 0, :hour => 0

    definition <<-DEF
      database PostgreSQL do |db|
        db.name = "#{node[:noosfero][:db][:name]}"
        db.host = "#{node[:noosfero][:db][:hostname]}"
        db.port = "#{node[:noosfero][:db][:port]}"
        db.username = "#{node[:noosfero][:db][:username]}"
        db.password = "#{node[:noosfero][:db][:password]}"
      end

      store_with Hg do |hg|
        hg.ip = "#{node[:noosfero][:backup][:to][:host]}"
        hg.port = #{node[:noosfero][:backup][:to][:port]}
        hg.username = "#{node[:noosfero][:backup][:to][:user]}"
        hg.path = "#{node[:noosfero][:backup][:to][:path]}"
        hg.syncer.add "#{node[:noosfero][:code_path]}"
      end
    DEF
  end
end
