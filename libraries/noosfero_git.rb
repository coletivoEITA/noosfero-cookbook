require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoGit < NoosferoResource
    provides :noosfero_git

    actions :install
    default_action :install

    property :repository, String, default: "https://gitlab.com/noosfero/noosfero.git"
    property :revision, String, default: 'master'

    property :timeout, Integer, default: 100_000_000
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
