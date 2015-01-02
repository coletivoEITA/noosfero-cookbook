module Noosfero

  module Helpers

    def self.init
      Chef::Node::ImmutableMash.class_eval do
        def to_hash
          h = {}
          self.each do |k,v|
            if v.respond_to? :to_hash
              h[k] = v.to_hash
            else
              h[k] = v
            end
          end
          h
        end
      end
    end
  end
end

class Object
  def blank?
    self.nil?
  end
end
class String
  def blank?
    self.nil? or self.empty?
  end
  def present?
    !self.blank?
  end
end
