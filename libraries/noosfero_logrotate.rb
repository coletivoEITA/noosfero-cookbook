require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoLogrotate < NoosferoResource
    self.resource_name = :noosfero_logrotate
    actions :configure
    default_action :configure

    attribute :rotate, kind_of: Integer, default: 100_000
    attribute :frequency, kind_of: String, default: 'daily'
    attribute :options, kind_of: String, default: ['copytruncate', 'compress', 'delaycompress', 'notifempty', 'missingok']
  end

  class Provider::NoosferoLogrotate < NoosferoProvider
    provides :noosfero_logrotate

    action :configure do
      # FIXME: r cannot be seen inside blocks
      r = new_resource

      run_context.include_recipe 'logrotate'

      logs = [
        "#{r.rails.env}.log",
        "#{r.rails.env}_memory_consumption.log",
        "#{r.rails.env}_spammers.log",
        'delayed_job.log',
        'unicorn.stdout.log', 'unicorn.stderr.log',
      ]

      logrotate_app r.service_name do
        enable true
        template_mode '0644'
        su "#{r.user} #{r.group}"
        create "644 #{r.user} #{r.group}"

        path logs.map{ |l| "#{r.log_path}/#{l}" }
        rotate r.rotate
        frequency r.frequency
        options r.options

        # not needed copytruncate used
        #postrotate <<-EOD
        #  sudo service #{r.service_name} restart
        #EOD
      end

      logrotate_app "#{r.service_name}_proxy" do
        enable true
        template_mode '0644'
        su "root root"
        create "644 #{r.user} #{r.group}"

        path [r.access_log_path, r.error_log_path]
        rotate r.rotate
        frequency r.frequency
        options r.options

        # not needed copytruncate used
        #postrotate <<-EOD
        #  sudo service #{proxy_service} reload
        #EOD
      end

    end

  end

end
