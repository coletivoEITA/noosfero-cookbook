
default[:noosfero][:unicorn] = {}
default[:noosfero][:unicorn][:bin] = if node[:noosfero][:version] >= '1.0' then 'unicorn' else 'unicorn_rails' end

