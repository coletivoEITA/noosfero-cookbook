module Noosfero

  module Helpers

    def self.init
      Chef::Node::ImmutableMash.class_eval do
        def to_hash
          h = {}
          self.each do |k,v|
            if v.respond_to?('to_hash')
              h[k] = v.to_hash
            else
              h[k] = v
            end
          end
          h
        end
      end
    end

    def gems_load
      if node[:noosfero][:rvm_load]
        code <<-EOH
          source "$HOME/.rvm/scripts/rvm"
          rvm use #{node['noosfero']['rvm_load']}
        EOH
      else
        code <<-EOH
          export PATH=$PATH:/var/lib/gems/1.8/bin
        EOH
      end
    end
  end
end

