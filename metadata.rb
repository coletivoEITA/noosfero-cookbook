name             'noosfero'
maintainer       'Braulio Bhavamitra'
maintainer_email 'braulio@eita.org.br'
license          'GPLv3+'
description      'Install/configure Noosfero social-economic network'
long_description File.read("#{File.dirname __FILE__}/README.md")
version          '3.2.0'

%w{ debian ubuntu }.each do |os|
  supports os
end

depends         'rvm'
depends         'ruby_build'
# use from git at https://github.com/fnichol/chef-rbenv
depends         'rbenv'

depends         'java'

depends         'postfix'

depends         'database'
depends         'postgresql'

depends         'nginx'
depends         'apache2', ">= 2.0.0"

depends         'varnish'
depends         'memcached'
depends         'redis2'

# chat
depends         'limits', '>= 1.0.0'

depends         'logrotate'

# use fork at https://github.com/coletivoEITA/backup-cookbook
depends         'backup'

# use fork at https://github.com/coletivoEITA/awstats-cookbook
depends         'awstats'

