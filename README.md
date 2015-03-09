Webhooks Cookbook
=====
<br />
Maybe you are using Chef-Solo and need an API to store node configuration or other configuration values.  Maybe you just want to access an API for whatever reason.  Maybe you don't need this because you are using Chef-Server.  I found a use for it, maybe you can to!

>#### Supported Platforms
>Debian(6.x+), Ubuntu(10.04+)
>CentOS(6.x+), RedHat, Fedora(20+)
>#### Tested Against
>Debian 6.x and above
>Ubuntu 10.04 and above
>CenOS 6.x and above
>Fedora 20
>#### Planned Improvements
>0.1.2 - Enable Proxy

No additional cookboks are required.
<br />
<br />
<br />
#Attributes
_____
### webhooks::default
<br />
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>["webhooks"]["get_response"]</tt></td>
    <td>String</td>
    <td>Store GET Response and Parse it Later.</td>
    <td><tt>Empty</tt></td>
  </tr>
  <tr>
      <td><tt>["webhooks"]["post_response"]</tt></td>
      <td>String</td>
      <td>Store POST Response and Parse it Later.</td>
      <td><tt>Empty</tt></td>
  </tr>
  <tr>
      <td><tt>["webhooks"]["put_response"]</tt></td>
      <td>String</td>
      <td>Store PUT Response and Parse it Later.</td>
      <td><tt>Empty</tt></td>
  </tr>
</table>
<br />
<br />
<br />
# Resource/Provider
______
## webhooks_request
<br />
### Actions

- :get
- :post
- :put
<br />
<br />
### Attribute Parameters

```
#Default name for operation.  Not used for other than resource name.
attribute :operation_name, :name_attribute => true, :kind_of => String, :required => true

#Base Required Options
attribute :uri, :kind_of => String, :required => true, :default => nil
attribute :uri_port, :kind_of => Integer, :required => false, :default => 80
attribute :expected_response_codes, :kind_of => Array, :required => false, :default => [200]
attribute :follow_redirect, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :read_timeout, :kind_of => Integer, :required => false, :default => 60
attribute :use_ssl, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :ssl_validation, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :post_data, :kind_of => Hash, :required => false, :default => nil
attribute :header_data, :kind_of => Hash, :required => false, :default => nil
attribute :save_response, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :post_json, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :post_xml, :kind_of => [ TrueClass, FalseClass ], :default => false

#Basic Authentication
attribute :use_basic_auth, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :basic_auth_username, :kind_of => String, :required => false, :default => nil
attribute :basic_auth_password, :kind_of => String, :required => false, :default => nil

#Proxy Options
attribute :use_proxy, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :proxy_address, :kind_of => String, :required => false, :default => nil
attribute :proxy_port, :kind_of => Integer, :required => false, :default => nil
attribute :proxy_username, :kind_of => String, :required => false, :default => nil
attribute :proxy_password, :kind_of => String, :required => false, :default => nil
```
<br />
<br />
### Example

```
webhooks_request "Test Get" do
  uri "s1n4l2z.runscope.net/"
  use_ssl true
  expected_response_codes [ 200, 201 ]
  action :get
end
```

```
webhooks_request "Test Post" do
  uri "s1n4l2z.runscope.net/gethosts?api_key=123"
  use_ssl true
  post_json true
  post_data (
                { 'value1' => '1', 'value2' => '2'}
            )
  header_data (
                { 'header1' => '1', 'header2' => '2', 'User-Agent' => 'Mozilla/5.0'}
              )
  expected_response_codes [ 200, 201 ]
  action :post
end
```
<br />
<br />
<br />
# Recipe Usage

### N/A NONE
<br />
<br />
<br />
# License and Authors
___
Authors: Brian Stajkowski

Copyright 2014 Brian Stajkowski

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
