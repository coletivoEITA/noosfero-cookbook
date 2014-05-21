if node['noosfero']['kind'] =~ /rails3/
  apt_repository 'noosfero-rails3-deps' do
    uri 'http://people.debian.org/~terceiro/noosfero-wheezy-backports/'
    components ['./']
    key 'noosfero-rails3.key'
  end
end

apt_repository 'noosfero' do
  case node['noosfero']['kind']
  when 'production'
    uri 'http://download.noosfero.org/debian/squeeze'
    components ['./']
  when 'alpha-rails2'
    uri 'http://staging.download.noosfero.org'
    components ['squeeze-test/']
  when 'alpha-rails3'
    uri 'http://staging.download.noosfero.org'
    components ['wheezy-test/']
  end
end

package 'noosfero'
package 'noosfero-apache'
package 'libapache2-mod-rpaf'

