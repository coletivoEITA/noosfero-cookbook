name             'noosfero'
maintainer       'Bráulio Bhavamitra'
maintainer_email 'braulio@eita.org.br'
license          'GPLv3+'
description      'Install/configure Noosfero social-economic network'
long_description File.read("#{File.dirname __FILE__}/README.md")
version          '2.2.2'

%w{ debian ubuntu }.each do |os|
  supports os
end

depends         'rvm'
depends         'java'

depends         'postfix'

depends         'database'
depends         'postgresql'

depends         'nginx'
depends         'apache2'

depends         'varnish'
depends         'memcached'

depends         'logrotate'

depends         'backup'

