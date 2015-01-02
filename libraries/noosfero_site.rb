require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoSite < NoosferoResource
    self.resource_name = :noosfero_site
    actions :configure
    default_action :configure

    attribute :user, kind_of: String, default: lazy{ |r| r.service_name }
    attribute :group, kind_of: String, default: lazy{ |r| r.service_name }

    attribute :version, kind_of: String, default: '1.0.0'
    attribute :upgrade_script, kind_of: String, default: ''

    attribute :server_name, kind_of: String, default: 'example.com'
    attribute :custom_domains, kind_of: Array, default: []
    attribute :redirects, kind_of: Hash, default: {}

    attribute :paths_in_code, kind_of: Boolean, default: false
    attribute :path, kind_of: String, default: nil
    attribute :user_install, kind_of: Boolean, default: lazy{ |r| r.path.present? }

    Paths = %w[ code data config log run tmp pids ]
    SystemPaths = {
      code: proc{ |service_name| "/usr/share/#{service_name}" },
      data: proc{ |service_name| "/var/lib/#{service_name}" },
      config: proc{ |service_name| "/etc/#{service_name}" },
      log: proc{ |service_name| "/var/log/#{service_name}" },
      run: proc{ |service_name| "/var/run/#{service_name}" },
      tmp: proc{ |service_name| "/var/tmp/#{service_name}" },
    }

    attribute :code_path, kind_of: String, default: lazy{ |r| r.path }
    %w[ data config log run tmp ].each do |dir|
      attribute "#{dir}_path".to_sym, kind_of: String, default: (lazy do |r|
        if r.paths_in_code
          "#{r.code_path}/#{dir}"
        elsif r.user_install
          "/home/#{r.user}/#{dir}"
        else
          SystemPaths[dir.to_sym]
        end
      end)
    end
    attribute :pids_path, kind_of: String, default: lazy{ |r| "#{r.tmp_path}/pids" }

    attribute :access_log_path, kind_of: String, default: lazy{ |r| "#{r.log_path}/access.log" }
    attribute :error_log_path, kind_of: String, default: lazy{ |r| "#{r.log_path}/error.log" }

    attribute :settings, kind_of: Hash, default: {}

    ### Resources initialized by default run by default

    attribute :ruby, kind_of: NoosferoResource, default: lazy{ |r| r.child_resource :ruby }
    attribute :rails, kind_of: NoosferoResource, default: lazy{ |r| r.child_resource :rails }

    attribute :server, kind_of: NoosferoResource, default: lazy{ |r| r.child_resource :server }
    attribute :db, kind_of: NoosferoResource, default: lazy{ |r| r.child_resource :db }
    attribute :plugins, kind_of: NoosferoResource, default: nil

    # use one of these to install noosfero
    attribute :git, kind_of: NoosferoResource, default: nil
    attribute :package, kind_of: NoosferoResource, default: nil

    attribute :dependencies, kind_of: NoosferoResource, default: lazy{ |r| r.child_resource :dependencies }

    attribute :environment, kind_of: NoosferoResource, default: nil
    attribute :logrotate, kind_of: NoosferoResource, default: nil
    attribute :awstats, kind_of: NoosferoResource, default: nil
    attribute :backup, kind_of: NoosferoResource, default: nil

  end

  class Provider::NoosferoSite < NoosferoProvider

    action :configure do
      create_user if r.user_install
      create_directories
      define_base_resources

      r.ruby.run_action :configure
      r.rails.run_action :configure

      Chef::Application.fatal! "Use git or package, not both" if r.git and r.package
      r.git.run_action :install if r.git
      r.package.run_action :install if r.package

      #r.db.run_action :create if r.db
      r.dependencies.run_action :install if r.dependencies

      save_settings
      r.plugins.run_action :enable if r.plugins
      r.plugins.run_action :config if r.plugins
      r.server.run_action :install if r.server

      r.logrotate.run_action :configure if r.logrotate
      r.backup.run_action :configure if r.backup
      r.awstats.run_action :configure if r.awstats

      configure_service
    end

    def define_base_resources
      site = r
      service r.service_name do
        supports restart: true, reload: false, status: true
        action :nothing
      end
      noosfero_dependencies r.service_name do
        site site
        action :nothing
      end
      noosfero_upgrade r.service_name do
        site site
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
      unless r.paths_in_code
        Resource::NoosferoSite::Paths.each do |path|
          directory r.send("#{path}_path") do
            user r.user; group r.group
          end
        end
        %w[ log run tmp ].each do |dir|
          link "#{r.code_path}/#{dir}" do
            to r.send("#{dir}_path")
            not_if{ r.send("#{dir}_path").start_with? r.code_path }
          end
        end

        # data paths
        # recursive option is not used as it don't preserve user/group
        %w[ index solr public public/articles public/image_uploads public/thumbnails ].each do |dir|
          directory "#{r.data_path}/#{dir}" do
            user r.user; group r.group
          end
        end
        %w[ index solr public/articles public/image_uploads public/thumbnails ].each do |dir|
          link "#{r.code_path}/#{dir}" do
            to "#{r.data_path}/#{dir}"
            not_if{ r.data_path.start_with? r.code_path }
          end
        end

        # TODO: link configurations to /etc/noosfero

      end
    end

    def configure_service
      template "/etc/init.d/#{r.service_name}" do
        source "init.d.erb"
        cookbook 'noosfero'
        mode "755"
        variables site: r
        action :create
        notifies :restart, "service[#{r.service_name}]"
      end
      service r.service_name do
        action [:enable, :start]
      end
    end

    def save_settings
      template "#{r.code_path}/config/noosfero.yml" do
        variables site: r
        cookbook 'noosfero'

        notifies :restart, "service[#{r.service_name}]"
      end
    end

  end

end
