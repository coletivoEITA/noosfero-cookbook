require 'chef/resource/lwrp_base'
require 'chef/provider/lwrp_base'

class NoosferoResource < Chef::Resource::LWRPBase
  Cookbook = 'noosfero'
  # shortcut to boolean type
  Boolean = [TrueClass, FalseClass]

  # override on subclasses
  self.resource_name = nil
  actions :nothing

  # top level reference for child resources
  attribute :site, kind_of: NoosferoResource

  # identifier for all childs
  attribute :service_name, name_attribute: true, kind_of: String, default: (lazy do |r|
    r.site.service_name if r.site
  end)

  def child_resource attr, &block
    res = instance_variable_get "@#{attr}"
    unless res
      resource = "#{Cookbook}_#{attr}"
      klass = Chef::Resource::const_get camelize(resource).to_sym
      res = klass.new self.service_name, self.run_context
    end
    res.class.run_context = self.run_context
    res.site (if self.is_a?(Chef::Resource::NoosferoSite) then self else self.site end)
    # may be recursive
    res.instance_exec &block if block_given?
    res
  end

  # avoid infinite recursion between parent/child
  HIDDEN_IVARS += [:@site, :@_visited]
  %w[ to_text inspect as_json to_hash ].each do |method|
    define_method method do |*args|
      return if @_visited
      @_visited = true
      r = super *args
      @_visited = false
      r
    end
  end

  protected

  # Translate hash attributes into child resources
  # So that we can just import node attributes as follow
  #   node[:noosfero][:sites].each do |site, values|
  #     noosfero_site site do
  #       values.each do |attr, value|
  #         send attr, value
  #       end
  #     end
  #   end
  def set_or_return symbol, arg, validation
    kind_of = validation[:kind_of]
    resource_type = kind_of.is_a?(Class) && kind_of <= Chef::Resource::LWRPBase

    unless resource_type
      # deep merge attributes, as done with node attributes
      default = validation[:default]
      if arg and default and (arg.is_a? Hash or arg.is_a? Array)
        default = default.call self if default.is_a? Chef::DelayedEvaluator
        # uses to_hash from helpers.rb as arg may come from node attributes which is immutable
        arg = arg.to_hash if arg.is_a? Hash
        arg = Chef::Mixin::DeepMerge.deep_merge default, arg
      end
    end

    if arg and arg.is_a? Hash and resource_type
      res = self.child_resource symbol do
        arg.each{ |a, v| send a, v }
      end
      super symbol, res, validation
    else
      super symbol, arg, validation
    end
  end

  # delegate missing methods to site
  def method_missing method, *args, &block
    if self.site
      self.site.send method, *args, &block
    end
  end

  private

  # from activesupport
  def camelize lower_case_and_underscored_word
    lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end

end

class NoosferoProvider < Chef::Provider::LWRPBase
  # as an application we need notifies
  #use_inline_resources if defined? use_inline_resources

  def whyrun_supported?
    true
  end

  # shortcut
  alias_method :r, :new_resource

  def shell name=nil, &block
    # FIXME: r cannot be seen inside shell block
    r = new_resource

    noosfero_shell name do
      name name
      site r.site
      instance_exec &block
    end
  end

end

