require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoSite < NoosferoResource
    provides :noosfero_site

    actions :configure
    default_action :configure

    property :user,  String, default: lazy{ |r| r.service_name }
    property :group, String, default: lazy{ |r| r.service_name }

    property :version, String, default: '1.0.0'
    property :upgrade_script, String, default: ''

    property :server_name, String, default: 'example.com'
    property :custom_domains, Array, default: []
    property :redirects, Hash, default: {}

    property :paths_in_code, Boolean, default: false
    property :path, String, default: nil
    property :user_install, Boolean, default: lazy{ |r| r.path.present? }

    Paths = %w[ code data config log run tmp pids ]
    SystemPaths = {
      code: proc{ |service_name| "/usr/share/#{service_name}" },
      data: proc{ |service_name| "/var/lib/#{service_name}" },
      config: proc{ |service_name| "/etc/#{service_name}" },
      log: proc{ |service_name| "/var/log/#{service_name}" },
      run: proc{ |service_name| "/var/run/#{service_name}" },
      tmp: proc{ |service_name| "/var/tmp/#{service_name}" },
    }

    property :code_path, String, default: lazy{ |r| r.path }
    %w[ data config log run tmp ].each do |dir|
      property "#{dir}_path".to_sym, String, default: (lazy do |r|
        if r.paths_in_code
          if dir == 'data' then r.code_path else "#{r.code_path}/#{dir}" end
        elsif r.user_install
          "/home/#{r.user}/#{dir}"
        else
          SystemPaths[dir.to_sym]
        end
      end)
    end
    property :pids_path, String, default: lazy{ |r| "#{r.tmp_path}/pids" }

    property :access_log_path, String, default: lazy{ |r| "#{r.log_path}/access.log" }
    property :error_log_path, String, default: lazy{ |r| "#{r.log_path}/error.log" }

    property :settings, Hash, default: {}

    ### Resources initialized by default run by default

    property :ruby, NoosferoResource, default: lazy{ |r| r.child_resource :ruby }
    property :rails, NoosferoResource, default: lazy{ |r| r.child_resource :rails }

    # use one of these to install noosfero
    property :git, NoosferoResource, default: nil
    property :package, NoosferoResource, default: nil

    property :db, NoosferoResource, default: lazy{ |r| r.child_resource :db }
    property :dependencies, NoosferoResource, default: lazy{ |r| r.child_resource :dependencies }

    # called by db on new db creation
    property :environment, NoosferoResource, default: nil

    property :plugins, NoosferoResource, default: nil
    property :server, NoosferoResource, default: lazy{ |r| r.child_resource :server }

    property :chat, NoosferoResource, default: nil

    property :logrotate, NoosferoResource, default: nil
    property :awstats, NoosferoResource, default: nil
    property :backup, NoosferoResource, default: nil

  end

  class Provider::NoosferoSite < NoosferoProvider
    action :configure do
      create_user if r.user_install
      define_base_resources

      r.ruby.run_action :configure
      r.rails.run_action :configure

      Chef::Application.fatal! "Use git or package, not both" if r.git and r.package
      r.git.run_action :install if r.git
      r.package.run_action :install if r.package
      # after code: other directories needs code already installed
      create_directories

      r.db.run_action :create if r.db
      #r.dependencies.run_action :install if r.dependencies

      save_settings
      r.plugins.run_action :enable if r.plugins
      r.plugins.run_action :config if r.plugins
      r.server.run_action :install if r.server

      r.chat.run_action :configure if r.chat

      r.logrotate.run_action :configure if r.logrotate
      r.backup.run_action :configure if r.backup
      r.awstats.run_action :configure if r.awstats

      configure_service
    end

    def define_base_resources
      service r.service_name do
        supports restart: true, reload: false, status: true
        action :nothing
      end
    end

    # FIXME: methods bellow should become child LWRPs

    def create_user
      group r.group do
        action :create
      end
      user r.user do
        supports manage_home: true
        home "/home/#{r.user}"
        gid r.group
        action :create
      end
    end

    def create_directories
      # Directories
      Resource::NoosferoSite::Paths.each do |path|
        directory r.send("#{path}_path") do
          user r.user; group r.group
        end
      end

      # data paths
      # recursive option is not used as it don't preserve user/group
      %w[ index solr public public/articles public/image_uploads public/thumbnails ].each do |dir|
        directory "#{r.data_path}/#{dir}" do
          user r.user; group r.group
        end
      end

      %w[ log run tmp ].each do |dir|
        link "#{r.code_path}/#{dir}" do
          to r.send("#{dir}_path")
          not_if{ r.paths_in_code }
        end
      end

      %w[ index solr public/articles public/image_uploads public/thumbnails ].each do |dir|
        link "#{r.code_path}/#{dir}" do
          to "#{r.data_path}/#{dir}"
          not_if{ r.paths_in_code }
        end
      end

      # TODO: link configurations to /etc/#{service_name}

    end

    def configure_service
      template "/etc/init.d/#{r.service_name}" do
        source "init.d.erb"
        cookbook 'noosfero'
        mode "755"
        variables site: r
        action :create
      end
      service r.service_name do
        action [:enable, :start]
        subscribes :restart, "template[/etc/init.d/#{r.service_name}]"
      end
    end

    def save_settings
      template "#{r.code_path}/config/noosfero.yml" do
        variables site: r
        cookbook 'noosfero'

        notifies :restart, resources(service: r.service_name)
      end
    end

  end

end
