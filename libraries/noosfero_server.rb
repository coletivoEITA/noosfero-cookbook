require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoServer < NoosferoResource
    self.resource_name = :noosfero_server
    actions :install
    default_action :install

    attribute :block_bots, kind_of: Array, default: %w[
      msnbot Purebot Baiduspider Lipperhey Mail.Ru scrapbot
      MJ12bot AhrefsBot YandexBot BDCbot MegaIndex UniLeipzigASV
      DotBot Typhoeus
    ]

    attribute :feed_updater_enabled, kind_of: Boolean, default: true

    attribute :backend, kind_of: String, default: 'thin', equal_to: ['thin', 'unicorn']
    attribute :workers, kind_of: Integer, default: 4
    attribute :port, kind_of: Integer, default: 50000
    attribute :timeout, kind_of: Integer, default: (lazy do |r|
      case r.backend
      when 'thin' then 30
      when 'unicorn'
        case r.proxy.with
        when 'apache' then 20*60
        when 'nginx' then 60
        end
      end
    end)

    attribute :backlog, kind_of: Integer, default: 2048
    attribute :restart_on_requests, kind_of: Array, default: [200,300]
    attribute :restart_on_memory, kind_of: Array, default: [172,208]
    attribute :warmup_time, kind_of: Integer, default: 1
    attribute :warmup_urls, kind_of: Array, default: (lazy do |r|
      ['/'].map{ |path| "http://#{r.server_name}#{path}" }
    end)

    attribute :unicorn_bin, kind_of: String, default: (lazy do |r|
      if r.version >= '1.0' then 'unicorn' else 'unicorn_rails' end
    end)

    def unicorn?
      backend == 'unicorn'
    end
    def thin?
      backend == 'thin'
    end

    # disabled by default
    attribute :proxy, kind_of: NoosferoResource, default: nil
    attribute :cache, kind_of: NoosferoResource, default: nil
    attribute :ssl, kind_of: NoosferoResource, default: nil

  end

  class Provider::NoosferoServer < NoosferoProvider

    action :install do
      r.cache.run_action :install if r.cache
      r.proxy.run_action :install if r.proxy
      r.ssl.run_action :install if r.ssl

      if r.backend == 'unicorn'
        template "#{r.code_path}/config/unicorn.conf.rb" do
          variables site: r.site
          cookbook 'noosfero'

          action :create
          notifies :restart, resources(service: r.service_name)
        end
      end
      template "#{r.code_path}/config/thin.yml" do
        variables site: r.site
        cookbook 'noosfero'

        action :create
        notifies :restart, resources(service: r.service_name)
      end

    end

  end
end
