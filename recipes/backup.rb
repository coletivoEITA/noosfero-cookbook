
include_recipe 'backup'

backup_model "#{node[:noosfero][:service_name]}_db" do
  description "Database backup"

  definition <<-DEF
    split_into_chunks_of 4000

    compress_with Gzip do
      gzip.rsyncable = true
    end
    schedule :minute => 0, :hour => 0

    database PostgreSQL do |db|
      db.name = "#{node[:noosfero][:db][:name]}"
      db.host = "#{node[:noosfero][:db][:hostname]}"
      db.port = "#{node[:noosfero][:db][:port]}"
      db.username = "#{node[:noosfero][:db][:username]}"
      db.password = "#{node[:noosfero][:db][:password]}"
    end

    store_with RSync do |storage|
      storage.mode = :ssh
      storage.compress = true
      storage.host = "#{node[:noosfero][:backup][:to][:host]}"
      storage.port = #{node[:noosfero][:backup][:to][:port]}
      storage.ssh_user = "#{node[:noosfero][:backup][:to][:user]}"
      storage.path = "~/#{node[:noosfero][:service_name]}/db"
    end
  DEF
end
