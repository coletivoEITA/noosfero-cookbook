require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoSsl < NoosferoResource
    self.resource_name = :noosfero_ssl
    actions :install
    default_action :install

    attribute :default, kind_of: Boolean, default: true
    attribute :spdy, kind_of: Boolean, default: true
    attribute :redirect_http, kind_of: Boolean, default: true
    # default to only safe protocols
    attribute :protocols, kind_of: String, default: "TLSv1 TLSv1.1 TLSv1.2"
  end

  class Provider::NoosferoSsl < NoosferoProvider

    action :install do
    end

  end
end
