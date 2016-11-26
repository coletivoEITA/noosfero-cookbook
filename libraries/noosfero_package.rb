require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoPackage < NoosferoResource
    self.resource_name = :noosfero_package
    actions :install
    default_action :install

  end

  class Provider::NoosferoPackage < NoosferoProvider
    provides :noosfero_package

    action :create do
      r = new_resource

      apt_repository 'noosfero' do
        if r.version < '1.0'
          uri 'http://download.noosfero.org/debian/squeeze'
          components ['./']
        else
          uri 'http://download.noosfero.org/debian/wheezy'
          components ['./']
        end
      end

      package 'noosfero'
      package 'noosfero-apache'
      package 'libapache2-mod-rpaf'
    end

  end
end
