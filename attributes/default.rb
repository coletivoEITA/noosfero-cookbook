
default[:nginx][:default][:modules] = ["http_spdy_module"]
default[:nginx][:source][:modules] = ["nginx::http_spdy_module"]

default[:varnish][:vcl_cookbook] = 'noosfero'

default[:backup][:version_from_git?] = true
default[:backup][:git_repo] = 'https://github.com/coletivoEITA/backup.git'
