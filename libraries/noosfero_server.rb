require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoServer < NoosferoResource
    provides :noosfero_server

    actions :install
    default_action :install

    property :block_bots, Array, default: %w[
      msnbot Purebot Baiduspider Lipperhey Mail.Ru scrapbot
      MJ12bot AhrefsBot YandexBot BDCbot MegaIndex UniLeipzigASV
      DotBot Typhoeus
    ]

    property :feed_updater_enabled, Boolean, default: true

    property :backend, String, default: 'thin', equal_to: ['thin', 'unicorn']
    property :workers, Integer, default: 4
    property :port, Integer, default: 50000
    property :timeout, Integer, default: (lazy do |r|
      case r.backend
      when 'thin' then 30
      when 'unicorn'
        case r.proxy.with
        when 'apache' then 20*60
        when 'nginx' then 60
        end
      end
    end)

    # unicorn conf
    property :backlog, Integer, default: 2048
    property :worker_killer, Boolean, default: false
    property :restart_on_requests, Array, default: [200,300]
    property :restart_on_memory, Array, default: [172,208]
    property :warmup_time, Integer, default: 1
    property :warmup_urls, Array, default: (lazy do |r|
      ['/'].map{ |path| "http://#{r.server_name}#{path}" }
    end)

    property :unicorn_bin, String, default: (lazy do |r|
      if r.version >= '1.0' then 'unicorn' else 'unicorn_rails' end
    end)

    def unicorn?
      backend == 'unicorn'
    end
    def thin?
      backend == 'thin'
    end

    # disabled by default
    property :proxy, NoosferoResource, default: nil
    property :cache, NoosferoResource, default: nil
    property :ssl, NoosferoResource, default: nil

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
