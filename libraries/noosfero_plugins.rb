require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoPlugins < NoosferoResource
    self.resource_name = :noosfero_plugins
    actions :enable
    default_action :enable

    BasePlugins = %w[ people_block statistics ]

    attribute :list, kind_of: [Array, String], default: BasePlugins
    attribute :settings, kind_of: Hash, default: {
      solr: {
        address: '127.0.0.1',
        port: 8983,
        memory: 128,
        timeout: 600,
      },
    }

  end

  class Provider::NoosferoPlugins < NoosferoProvider

    action :enable do
      plugins = r.list
      if plugins == 'all'
        cmd = Mixlib::ShellOut.new "sh -c 'cd #{r.code_path}/plugins && echo */'"
        overview = cmd.run_command
        plugins = overview.stdout.split("\n").first.gsub('/', '').split(' ').sort
      else
        plugins = plugins.sort
      end

      # FIXME: why r is not visible? on r.service_name
      r = new_resource
      shell "#{r.service_name}-enable-selected-plugins" do
        code <<-EOH
script/noosfero-plugins disableall
script/noosfero-plugins enable #{plugins.join ' '}
        EOH

        notifies :restart, "service[#{r.service_name}]"
        # install plugins' Gemfile
        notifies :install, "noosfero_dependencies[#{r.service_name}]"

        only_if do
          cmd = Mixlib::ShellOut.new "sh -c 'cd #{r.code_path}/config/plugins && echo */'"
          overview = cmd.run_command
          current_enabled_plugins = overview.stdout.split("\n").first.gsub('/', '').split(' ').sort
          plugins != current_enabled_plugins
        end
      end

    end

    action :config do
      if r.list.include? 'solr'
        run_context.include_recipe 'java'

        template "#{r.code_path}/plugins/solr/config/solr.yml" do
          variables site: r.site
          cookbook 'noosfero'

          action :create
        end
      end
    end

  end
end