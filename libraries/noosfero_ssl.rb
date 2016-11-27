require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoSsl < NoosferoResource
    provides :noosfero_ssl

    actions :install
    default_action :install

    property :default, Boolean, default: true
    property :spdy, Boolean, default: false
    property :redirect_http, Boolean, default: true

    # default to only safe protocols
    property :protocols, String, default: "TLSv1 TLSv1.1 TLSv1.2"

    property :certificate, String, default: nil
    property :certificate_key, String, default: nil
    property :certificate_chain, String, default: nil
  end

  class Provider::NoosferoSsl < NoosferoProvider
    action :install do
    end

  end
end
