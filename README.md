noosfero Cookbook
========================
Install/configure Noosfero social-economic network (see http://noosfero.org) 

Attributes
----------
#### noosfero::default
The default recipe runs others recipes according to the settings
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:service_name]</tt></td>
    <td>The Noosfero's service name, which define the init.d script name and paths</td>
    <td><tt>"noosfero"</tt></td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:rails_env]</tt></td>
    <td>The Rails environment to be used</td>
    <td><tt>"production"</tt></td>
  </tr>
</table>
#### noosfero::install
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:install_from]</tt></td>
    <td>What is used to install noosfero: "git" (default) to fetch code from git and "package" to install noosfero from debian repository</td>
    <td><tt>"git"</tt></td>
  </tr>
</table>

#### noosfero::git\_install (on install\_from == "git")
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:user]</tt></td>
    <td>The user to create and to run noosfero</td>
    <td><tt>default[:noosfero][:service_name]</tt></td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:group]</tt></td>
    <td>The group to create and to run noosfero</td>
    <td><tt>default[:noosfero][:service_name]</tt></td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:git_url]</tt></td>
    <td>The git repo containing Noosfero to be used</td>
    <td><tt>https://gitlab.com/noosfero/noosfero.git</tt></td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:git_revision]</tt></td>
    <td>The branch, tag or commit to be used</td>
    <td><tt>"stable"</tt></td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:upgrade_script]</tt></td>
    <td>A script to be run on git sync</td>
    <td><tt>''</tt></td>
  </tr>
  <tr>
    <th colspan=3>Paths</th>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:path]</tt></td>
    <td>Set the path to clone the git repo to be the base path for code, log, tmp and others noosfero directories</td>
    <td><tt>nil</tt> (use default system dirs, see below)</td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:code_path]</tt></td>
    <td>Overwrite the code's path</td>
    <td>
      <tt>node[:noosfero][:path]</tt> (with node[:noosfero][:path])
      <br>
      <tt>"/usr/share/#{service_name}"</tt> (without node[:noosfero][:path])
    </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:data_path]</tt></td>
    <td>Overwrite the data path</td>
    <td>
      <tt>node[:noosfero][:path]</tt> (with node[:noosfero][:path])
      <br>
      <tt>"/var/lib/#{service_name}"</tt> (without node[:noosfero][:path])
    </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:config_path]</tt></td>
    <td>Overwrite the config path</td>
    <td>
      <tt>"#{node[:noosfero][:path]}/config"</tt> (with node[:noosfero][:path])
      <br>
      <tt>"/etc/#{service_name}"</tt> (without node[:noosfero][:path])
    </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:log_path]</tt></td>
    <td>Overwrite the log path</td>
    <td>
      <tt>"#{node[:noosfero][:path]}/log"</tt> (with node[:noosfero][:path])
      <br>
      <tt>"/var/log/#{service_name}"</tt> (without node[:noosfero][:path])
    </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:run_path]</tt></td>
    <td>Overwrite the run path</td>
    <td>
      <tt>"#{node[:noosfero][:path]}/run"</tt> (with node[:noosfero][:path])
      <br>
      <tt>"/var/run/#{service_name}"</tt> (without node[:noosfero][:path])
    </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:tmp_path]</tt></td>
    <td>Overwrite the tmp path</td>
    <td>
      <tt>"#{node[:noosfero][:path]}/tmp"</tt> (with node[:noosfero][:path])
      <br>
      <tt>"/var/tmp/#{service_name}"</tt> (without node[:noosfero][:path])
    </td>
  </tr>
</table>

#### noosfero::package\_install (on install\_from == "package")
Install noosfero using the Colivre's apt repository
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
</table>

#### noosfero::dependencies (on install\_from == "git")
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:dependencies_with]</tt></td>
    <td>How to install dependencies: "quick_start", "bundler" or "packages" </td>
    <td> <tt>"quick_start"</tt> </td>
  </tr>
</table>

#### noosfero::database (on install\_from == "git")
Generate Rails' database.yml
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:db][:name]</tt></td>
    <td>Database name</td>
    <td> <tt>node[:noosfero][:service_name]</tt> </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:db][:hostname]</tt></td>
    <td>Database host</td>
    <td> <tt>"localhost"</tt> </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:db][:port]</tt></td>
    <td>Database port</td>
    <td> <tt>""</tt> </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:db][:username]</tt></td>
    <td>Database username</td>
    <td> <tt>node[:noosfero][:user]</tt> </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:db][:password]</tt></td>
    <td>Database password</td>
    <td> <tt>""</tt> </td>
  </tr>
</table>

#### noosfero::environment (on install\_from == "git")
Create, if there isn't any default yet, a default Noosfero Environment
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:environment]</tt></td>
    <td>A hash with the config. If nil, skip environment check and creation</td>
    <td> <tt>nil</tt> </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:environment][:name]</tt></td>
    <td>The name of the environment. This is used in all pages' &lttitle&gt</td>
    <td> <tt>-</tt> </td>
  </tr>
  <tr>
    <td><tt>node[:noosfero][:environment][:domain]</tt></td>
    <td>The name of the environment. This is used in all pages' &lttitle&gt</td>
    <td> <tt>-</tt> </td>
  </tr>
</table>


Usage
-----
#### noosfero::default
Just include `noosfero` in your node's `run_list`, the below configuration is an example:
```json
{
  "noosfero": {
    "service_name": "noosfero",
    "path": "/home/braulio/escambo.org.br",
    "user": "braulio",
    "group": "braulio",

    "git_url": "https://github.com/ESCAMBO/noosfero-ecosol.git",
    "git_revision": "master",

    "dependencies_with": "bundler",
    "rvm_load": "ree@cirandas",

    "server_name": "escambo.org.br",
    "custom_domains": [
      "escambo.org"
    ],

    "proxy_server": "nginx",
    "server": {
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

