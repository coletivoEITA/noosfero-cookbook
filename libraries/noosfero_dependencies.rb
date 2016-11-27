require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoDependencies < NoosferoResource
    provides :noosfero_dependencies

    actions :install
    default_action :install

    property :method, String, default: 'quick_start', equal_to: %w[ quick_start packages bundler ]

    DebianBasePackages = %w[po4a iso-codes tango-icon-theme pidgin-data imagemagick]
    property :packages_for_quick_start, Array, default: []
    property :packages_for_packages, Array, default: (lazy do |r|
      case node[:platform_family]
      when 'debian', 'ubuntu'
        DebianBasePackages + %w[ ruby rake libgettext-ruby-util libgettext-ruby1.8 libsqlite3-ruby rcov librmagick-ruby libredcloth-ruby libhpricot-ruby libwill-paginate-ruby libfeedparser-ruby libdaemons-ruby thin ]
      end
    end)
    property :packages_for_bundler, Array, default: (lazy do |r|
      case node[:platform_family]
      when 'debian', 'ubuntu'
        DebianBasePackages + %w[ curl libmagickwand-dev libpq-dev libreadline-dev libsqlite3-dev libxslt1-dev ]
      end
    end)

    property :nodejs_from, Array, default: 'package', equal_to: %w[ package binary source ]

  end

  class Provider::NoosferoDependencies < NoosferoProvider
    action :install do
      # for asset pipeline
      run_context.include_recipe "nodejs::nodejs_from_#{r.nodejs_from}"

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
