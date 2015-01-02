noosfero Cookbook
========================
Install/configure Noosfero social-economic network (see http://noosfero.org) 

Attributes
----------
#### noosfero::default

The default recipe runs others recipes according to the settings

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:service_name]</tt>  | The Noosfero's service name, which defines the init.d script name and paths | <tt>"noosfero"</tt> |
| <tt>node[:noosfero][:rails_env]</tt> | The Rails environment to be used | <tt>"production"</tt> |
| <tt>node[:noosfero][:rvm_load]</tt> | The ruby string to be load (e.g. "ree@noosfero") | <tt>"system"</tt> |

#### noosfero::install

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:install_from]</tt> | What is used to install noosfero: "git" (default) to fetch code from git and "package" to install noosfero from debian repository | <tt>"git"</tt> |

#### noosfero::git\_install (on install\_from == "git")

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:user]</tt> | The user to create and to run noosfero | <tt>default[:noosfero][:service_name]</tt> |
| <tt>node[:noosfero][:group]</tt> | The group to create and to run noosfero | <tt>default[:noosfero][:service_name]</tt> |
| <tt>node[:noosfero][:git_url]</tt> | The git repo containing Noosfero to be used | <tt>https://gitlab.com/noosfero/noosfero.git</tt> |
| <tt>node[:noosfero][:git_revision]</tt> | The branch, tag or commit to be used | <tt>"stable"</tt> |
| <tt>node[:noosfero][:upgrade_script]</tt> | A script to be run on git sync | <tt>''</tt> |
|  Paths  |
| <tt>node[:noosfero][:path]</tt> | Set the path to clone the git repo to be the base path for code, log, tmp and others noosfero directories | <tt>nil</tt> (use default system dirs, see below) |
| <tt>node[:noosfero][:code_path]</tt> | Overwrite the code's path | <tt>node[:noosfero][:path]</tt> (with node[:noosfero][:path]) or <tt>"/usr/share/#{service_name}"</tt> (without node[:noosfero][:path]) |
| <tt>node[:noosfero][:data_path]</tt> | Overwrite the data path | <tt>node[:noosfero][:path]</tt> (with node[:noosfero][:path]) or <tt>"/var/lib/#{service_name}"</tt> (without node[:noosfero][:path]) |
| <tt>node[:noosfero][:config_path]</tt> | Overwrite the config path | <tt>"#{node[:noosfero][:path]}/config"</tt> (with node[:noosfero][:path]) or <tt>"/etc/#{service_name}"</tt> (without node[:noosfero][:path]) |
| <tt>node[:noosfero][:log_path]</tt> | Overwrite the log path | <tt>"#{node[:noosfero][:path]}/log"</tt> (with node[:noosfero][:path]) or <tt>"/var/log/#{service_name}"</tt> (without node[:noosfero][:path]) |
| <tt>node[:noosfero][:run_path]</tt> | Overwrite the run path | <tt>"#{node[:noosfero][:path]}/run"</tt> (with node[:noosfero][:path]) or <tt>"/var/run/#{service_name}"</tt> (without node[:noosfero][:path]) |
| <tt>node[:noosfero][:tmp_path]</tt> | Overwrite the tmp path | <tt>"#{node[:noosfero][:path]}/tmp"</tt> (with node[:noosfero][:path]) or <tt>"/var/tmp/#{service_name}"</tt> (without node[:noosfero][:path]) |


#### noosfero::package\_install (on install\_from == "package")

Install noosfero using the Colivre's apt repository

| Attribute | Description | Default |
| --------  | --------    | ------- |
|  |  |  |

#### noosfero::dependencies (on install\_from == "git")

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:dependencies_with]</tt> | How to install dependencies: "quick_start", "bundler" or "packages" | <tt>"quick_start"</tt> |

#### noosfero::database (on install\_from == "git")

Generate Rails' database.yml

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:db][:name]</tt> | Database name | <tt>node[:noosfero][:service_name]</tt> |
| <tt>node[:noosfero][:db][:hostname]</tt> | Database hostname | <tt>"locahost"</tt> |
| <tt>node[:noosfero][:db][:port]</tt> | Database port | <tt>""</tt> |
| <tt>node[:noosfero][:db][:username]</tt> | Database username | <tt>node[:noosfero][:user]</tt> |
| <tt>node[:noosfero][:db][:password]</tt> | Database password | <tt>nil</tt> |
| <tt>node[:noosfero][:db][:create_from_dump]</tt> | Load speficied dump file after database creation (if it don't exist yet) | <tt>nil</tt> |

#### noosfero::environment (on install\_from == "git")

Create, if there isn't any default yet, a default Noosfero Environment, after database creation.

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:environment]</tt> | A hash with the config of the default environment. If nil, skip environment check and creation | <tt>nil</tt> |
| <tt>node[:noosfero][:environment][:name]</tt> | The name of the environment. This is used in all pages' &lttitle&gt | <tt>-</tt> |
| <tt>node[:noosfero][:environment][:domain]</tt> | The default domain associated with the environment. | <tt>-</tt> |
| <tt>node[:noosfero][:environment][:default_language]</tt> | Set default language | <tt>-</tt> |

#### noosfero::settings

Write noosfero.yml settings file. Use key/value pairs from `node[:noosfero][:settings]` hash.

#### noosfero::plugins

Enable and configure plugins.

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:plugins]</tt> | An array of plugins to enable with script/noosfero-plugins | <tt>[]</tt> |
| <tt>node[:noosfero][:plugins_settings]</tt> | Configure each plugin' settings | See <tt>attributes/default.rb</tt> |

#### noosfero::server

Configure proxy and backend (rails app) servers

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:server][:proxy]</tt> | Proxy server to use. Choose between nginx or apache | <tt>nginx</tt> |
| <tt>node[:noosfero][:server][:backend]</tt> | Rails application server. Choose between unicorn and thin | <tt>thin</tt> |
| <tt>node[:noosfero][:server][:workers]</tt> | Number of workers to start | <tt>4</tt> |
| <tt>node[:noosfero][:server][:port]</tt> | Backend port | <tt>50000</tt> |
| <tt>node[:noosfero][:server][:timeout]</tt> | Backend timeout | <tt>60</tt> if backend is nginx and <tt>1200</tt> if apache is used |
| <tt>node[:noosfero][:server][:proxy_port]</tt> | Proxy port to listen | <tt>node[:nginx][:listen_ports].first</tt> or <tt>node[:apache][:listen_ports].first</tt> |

#### noosfero::cache

Configure cache options

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:cache][:server]</tt> | Cache server to use. Supports `varnish` or set to empty to disable | <tt>varnish</tt> |
| <tt>node[:noosfero][:cache][:backend_port]</tt> | Backend port | <tt>node[:noosfero][:server][:proxy_port]</tt> |

#### noosfero::logrotate

Rotate logs

| Attribute | Description | Default |
| --------  | --------    | ------- |
| <tt>node[:noosfero][:logrotate][:rotate]</tt> | Number of maximum rotated logs | <tt>100_000</tt> |
| <tt>node[:noosfero][:logrotate][:frequency]</tt> | Frequency to rotate logs | <tt>daily</tt> |

Usage
-----

Just include `noosfero` in your node's `run_list`, the below configuration is an example:

```json
{
  "rvm": {
    "user_installs": [
      {
        "user": "noosfero",
        "rubies": [ "ree" ],
        "default_ruby": "ree",
        "gems": {
          "ree@noosfero": []
        }
      }
    ]
  },

  "postgresql": {
    "version": "9.3",
    "password": {
      // needed for chef-solo
      "postgres": "iqHDDo1o"
    },
  },

  "memcached": {
    "memory": 128,
    "listen": "127.0.0.1"
  },

  "varnish": {
    "version": "2.1",
    "listen_address": "0.0.0.0",
    "listen_port": 80,
    "storage": "file",
    "storage_size": "1G",
    "vcl_cookbook": "noosfero"
  },

  "nginx": {
    "listen_ports": [81],
    "keepalive_timeout": 20,
    "default_site_enabled": false
  },

  "apache": {
    "version": "2.4",
    "listen_addresses": ["127.0.0.1"],
    "listen_ports": [82],
    "keepalivetimeout": 20,
    "keepaliverequests": 1000
  },

  "noosfero": {
    "service_name": "noosfero",
    "path": "/home/braulio/escambo.org.br",
    "user": "braulio",
    "group": "braulio",

    "git_url": "https://github.com/ESCAMBO/noosfero-ecosol.git",
    "git_revision": "master",

    "dependencies_with": "bundler",
    "rvm_load": "ree@noosfero",

    "server_name": "escambo.org.br",
    "custom_domains": [
      "escambo.org"
    ],

    "server": {
      "proxy": "nginx",
      "backend": "unicorn",
      "workers": 1
    },
    "cache": {
      "server": "varnish"
    },

    "db": {
      "name": "noosfero_escambo.org.br_production",
      "port": 5433
    },

    "environment": {
      "name": "ESCAMBO",
      "domain": "escambo.org.br"
    },
    "plugins": ["cms_learning", "currency", "escambo", "evaluation", "exchange", "sniffer", "solr"],

    "settings": {
      "exception_recipients": ["alantygel@gmail.com", "brauliobo@gmail.com"]
    },

    "plugin_settings": {
      "solr": {
        "port": 8983,
        "memory": 128
      }

    }
  }
  "run_list": [
    "recipe[noosfero]"
  ]
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

After 3 consistent patches you become a commiter :)
