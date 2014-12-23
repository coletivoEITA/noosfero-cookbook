default[:noosfero][:ruby_version] = "system"
default[:noosfero][:dependencies_with] = 'quick_start'

case node[:platform_family]
when 'debian', 'ubuntu'
  default[:noosfero][:base_packages] = %w[po4a iso-codes tango-icon-theme pidgin-data imagemagick]
  default[:noosfero][:packages_for_packages] = default[:noosfero][:base_packages] + %w[ ruby rake libgettext-ruby-util libgettext-ruby1.8 libsqlite3-ruby rcov librmagick-ruby libredcloth-ruby libhpricot-ruby libwill-paginate-ruby libfeedparser-ruby libdaemons-ruby thin  ]
  default[:noosfero][:packages_for_bundler] = default[:noosfero][:base_packages] + %w[ curl libmagickwand-dev libpq-dev libreadline-dev libsqlite3-dev libxslt1-dev ]
  default[:noosfero][:packages_for_quick_start] = %w[]
end

