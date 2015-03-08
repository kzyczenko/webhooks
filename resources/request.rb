#Actions
actions :get, :post, :put
default_action :get if defined?(default_action)

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