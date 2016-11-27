require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoRuby < NoosferoResource
    provides :noosfero_ruby

    actions :configure
    default_action :configure

    # TODO: manage system-wide install for rbenv and rvm
    property :from, String, default: 'system', equal_to: ['system', 'rbenv', 'rvm']

    property :version, String, default: 'system'

    property :env, Hash, default: {
      RUBY_GC_MALLOC_LIMIT: 90000000,
      # don't really help
      #RUBY_HEAP_SLOTS_GROWTH_FACTOR: 1.25,
      #RUBY_HEAP_MIN_SLOTS: 800000,
      #RUBY_FREE_MIN: 600000,
    }

    property :allocator, String, default: 'jemalloc'

    def rbenv?
      self.from == 'rbenv'
    end
    def rvm?
      self.from == 'rvm'
    end

    def switch
      case self.from
      when 'rvm'
        "rvm use #{self.version}"
      when 'rbenv'
        "rbenv shell #{self.version}"
      else
        "true"
      end
    end

  end

  class Provider::NoosferoRuby < NoosferoProvider
    action :configure do
      case r.from
      when 'rbenv'
        run_context.include_recipe 'ruby_build'
        run_context.include_recipe 'rbenv'
        rbenv_ruby r.version do
          user r.user
        end
        rbenv_gem 'bundler' do
          rbenv_version r.version
          user r.user
          action :install
        end
      when 'rvm'
        run_context.include_recipe 'rvm'
        # FIXME: crash, see: https://github.com/martinisoft/chef-rvm/issues/322
        #rvm_ruby r.version
        rvm_gem 'bundler' do
          ruby_string r.version
          user r.user
          action :install
        end
      else
        # packages are installed by noosfero_dependencies
      end

      case r.allocator
      when 'jemalloc'
        package 'libjemalloc1'
        r.env[:LD_PRELOAD] = `sh -c "ldconfig -p | grep jemalloc | cut -d' ' -f 4"`.split("\n").first
      when 'tcmalloc'
        package 'libtcmalloc-minimal4'
        r.env[:LD_PRELOAD] = '/usr/lib/libtcmalloc_minimal.so.4'
      end
    end

  end

end
