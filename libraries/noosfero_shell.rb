require_relative 'noosfero_lwrp'

class Chef

  class Resource::NoosferoShell < NoosferoResource
    self.resource_name = :noosfero_shell
    actions :run
    default_action :run

    attribute :name, kind_of: String, name_attribute: true, default: nil
    attribute :code, kind_of: String, required: true, default: nil
  end

  class Provider::NoosferoShell < NoosferoProvider

    action :run do
      case r.ruby.from
      when 'rvm'
        rvm_shell r.name do
          user r.user; group r.group
          cwd r.code_path
          ruby_string r.ruby.version
          code r.code
        end
      when 'system'
        bash r.name do
          user r.user; group r.group
          cwd r.code_path
          code r.code
        end
      end
    end
  end
end
