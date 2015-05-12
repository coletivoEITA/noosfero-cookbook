require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoDependencies < NoosferoResource
    self.resource_name = :noosfero_dependencies
    actions :install
    default_action :install

    attribute :method, kind_of: String, default: 'quick_start', equal_to: %w[ quick_start packages bundler ]

    DebianBasePackages = %w[po4a iso-codes tango-icon-theme pidgin-data imagemagick]
    attribute :packages_for_quick_start, kind_of: Array, default: []
    attribute :packages_for_packages, kind_of: Array, default: (lazy do |r|
      case node[:platform_family]
      when 'debian', 'ubuntu'
        DebianBasePackages + %w[ ruby rake libgettext-ruby-util libgettext-ruby1.8 libsqlite3-ruby rcov librmagick-ruby libredcloth-ruby libhpricot-ruby libwill-paginate-ruby libfeedparser-ruby libdaemons-ruby thin ]
      end
    end)
    attribute :packages_for_bundler, kind_of: Array, default: (lazy do |r|
      case node[:platform_family]
      when 'debian', 'ubuntu'
        DebianBasePackages + %w[ curl libmagickwand-dev libpq-dev libreadline-dev libsqlite3-dev libxslt1-dev ]
      end
    end)

  end

  class Provider::NoosferoDependencies < NoosferoProvider

    action :install do
      # FIXME: r cannot be seen inside shell block
      r = new_resource

      packages = r.send "packages_for_#{r.method}"
      packages.each do |p|
        package p do
        end
      end

      case r.method
      when 'bundler'
        shell "#{r.service_name} bundle install" do
          code <<-EOH
bundle check || bundle install
          EOH
        end
      when 'quick_start'
        shell "#{r.service_name} script/quick-start" do
          code <<-EOH
script/quick-start
          EOH
        end
      end
    end

  end
end
