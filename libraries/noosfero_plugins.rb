require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoPlugins < NoosferoResource
    provides :noosfero_plugins

    actions :enable
    default_action :enable

    BasePlugins = %w[ people_block statistics ]

    property :list, [Array, String], default: BasePlugins
    property :settings, Hash, default: {
      solr: {
        address: '127.0.0.1',
        port:    8983,
        memory:  192,
        timeout: 600,
      },
    }

  end

  class Provider::NoosferoPlugins < NoosferoProvider

    # FIXME: whyrun not supported if code is not yet fetched
    def whyrun_supported?
      false
    end

    action :enable do
      # FIXME: r cannot be seen inside shell block
      r = new_resource

      plugins = r.list
      if plugins == 'all'
        cmd = Mixlib::ShellOut.new "sh -c 'cd #{r.code_path}/plugins && echo */'"
        overview = cmd.run_command
        plugins = overview.stdout.split("\n").first.gsub('/', '').split(' ').sort
      else
        plugins = plugins.sort
      end

      install_command = if r.version >= '1.3' then 'install' else 'enable' end

      shell "#{r.service_name} enable selected plugins" do
        code <<-EOH
script/noosfero-plugins disableall
script/noosfero-plugins #{install_command} #{plugins.join ' '}
        EOH

        notifies :restart, resources(service: r.service_name)
        # install plugins' Gemfile
        notifies :install, r.dependencies if r.dependencies

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

        template "#{r.code_path}/config/solr.yml" do
          variables site: r.site
          cookbook 'noosfero'

          action :create
        end
      end
    end

  end
end
