require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoRuby < NoosferoResource
    self.resource_name = :noosfero_ruby
    actions :configure
    default_action :configure

    attribute :from, kind_of: String, default: 'system', equal_to: ['rvm', 'system']

    attribute :version, kind_of: String, default: 'system'

    attribute :env, kind_of: Hash, default: {
      RUBY_GC_MALLOC_LIMIT: 90000000,
      # don't really help
      #RUBY_HEAP_SLOTS_GROWTH_FACTOR: 1.25,
      #RUBY_HEAP_MIN_SLOTS: 800000,
      #RUBY_FREE_MIN: 600000,
    }

    attribute :allocator, kind_of: String, default: nil

    def rvm?
      self.from == 'rvm'
    end

  end

  class Provider::NoosferoRuby < NoosferoProvider

    action :configure do
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
