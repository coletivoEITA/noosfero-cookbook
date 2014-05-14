noosfero Cookbook
========================
Install/configure Noosfero social-economic network (see http://noosfero.org) 

Attributes
----------
#### noosfero::default
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node['noosfero']['nginx_port']</tt></td>
    <td>The main port Nginx is listening</td>
    <td><tt>node['nginx']['listen_ports'].first</tt></td>
  </tr>
  <tr>
    <td><tt>node['noosfero']['apache_port']</tt></td>
    <td>The main port Apache is listening</td>
    <td><tt>node['apache']['listen_ports'].first</tt></td>
  </tr>
</table>

Usage
-----
#### noosfero::default
Just include `noosfero` in your node's `run_list`:

```json
{
  "name":"my_node",
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

