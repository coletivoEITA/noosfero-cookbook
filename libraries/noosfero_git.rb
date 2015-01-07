require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoGit < NoosferoResource
    self.resource_name = :noosfero_git
    actions :install
    default_action :install

    attribute :repository, kind_of: String, default: "https://gitlab.com/noosfero/noosfero.git"
    attribute :revision, kind_of: String, default: 'master'

    attribute :timeout, kind_of: Integer, default: 100_000_000
  end

  class Provider::NoosferoGit < NoosferoProvider

    action :install do
      git r.code_path do
        user r.user; group r.user
        repository r.repository
        revision r.revision
        enable_submodules true
        timeout r.timeout
        notifies :run, r.upgrade if r.upgrade
        action :sync
      end
    end

  end
end
