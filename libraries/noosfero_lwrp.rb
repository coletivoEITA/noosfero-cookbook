require 'chef/resource/lwrp_base'
require 'chef/provider/lwrp_base'

class NoosferoResource < Chef::Resource::LWRPBase
  Cookbook = :noosfero

  # shortcut to boolean type
  Boolean  = [TrueClass, FalseClass]

  # override on subclasses
  actions :nothing

  # top level reference for child resources
  property :site, NoosferoResource

  # identifier for all childs
  property :service_name, String, name_property: true, default: (lazy do |r|
    r.site.service_name if r.site
  end)

  def child_resource attr, &block
    res = instance_variable_get "@#{attr}"

    unless res
      class_name = camelize("#{Cookbook}_#{attr}").to_sym
      klass      = Chef::Resource::const_get class_name
      res        = klass.new self.service_name, self.run_context
    end
    res.class.run_context = self.run_context

    site = if self.is_a? Chef::Resource::NoosferoSite then self else @site end
    res.instance_variable_set :@site, site

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

  # Translate hash attributes into child resources
  # So that we can just import node attributes as follow
  #   node[:noosfero][:sites].each do |site, attrs|
  #     noosfero_site site do
  #       attrs.each do |attr, attrs|
  #         send attr, attrs
  #       end
  #     end
  #   end
  def self.property name, type, options = {}
    resource_type = type.is_a?(Class) && type <= Chef::Resource::LWRPBase

    super

    return unless resource_type

    define_method name do |attrs=nil|
      resource   = instance_variable_get :"@#{name}"
      resource ||= child_resource name do
        attrs.each{ |a, v| send a, v }
      end if attrs.present?
      resource ||= if options[:default].respond_to? :call then options[:default].call self else options[:default] end

      instance_variable_set :"@#{name}", resource

      resource
    end

    define_method "#{name}=" do |attrs|
      send name, attrs
    end
  end

  protected

  # delegate missing methods to site
  def method_missing method, *args, &block
    return if self.is_a? Chef::Resource::NoosferoSite
    return unless @site
    @site.send method, *args, &block
  end

  private

  # from activesupport
  def camelize lower_case_and_underscored_word
    lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end

end

class NoosferoProvider < Chef::Provider::LWRPBase

  def whyrun_supported?
    true
  end

  # shortcut
  alias_method :r, :new_resource

  def shell name=nil, &block
    # FIXME: r cannot be seen inside shell block
    r = new_resource

    noosfero_shell name do
      @site = r.site
      name name
      instance_exec &block
    end
  end

end

