require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoShell < NoosferoResource
    provides :noosfero_shell

    actions :run
    default_action :run

    property :name, String, name_property: true, default: nil
    property :code, String, required: true, default: nil

  end

  class Provider::NoosferoShell < NoosferoProvider
    action :run do
      # FIXME: r cannot be seen inside shell block
      r = new_resource

      case r.ruby.from
      when 'system'
        bash r.name do
          user r.site.user; group r.site.group
          cwd  r.code_path
          code r.code
          action :run
        end
      when 'rbenv'
        rbenv_script r.name do
          user r.site.user; group r.site.group
          cwd  r.code_path
          code r.code
          rbenv_version r.ruby.version
          action :run
        end
      when 'rvm'
        rvm_shell r.name do
          user r.site.user; group r.site.group
          cwd  r.code_path
          code r.code
          ruby_string r.ruby.version
          action :run
        end
      end
    end
  end
end
