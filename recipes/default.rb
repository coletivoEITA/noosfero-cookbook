
Noosfero::Helpers.init
extend Noosfero::Helpers

node[:noosfero][:sites].each do |site, values|
  noosfero_site site do
    values.each do |attr, value|
      send attr, value
    end
  end
end

