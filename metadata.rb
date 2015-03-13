name             'webhooks'
maintainer       'Brian Stajkowski'
maintainer_email 'stajkowski'
license          'Apache v2.0'
description      'LWRP Providers for API Calls'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

supports 'ubuntu', ">= 10.04"
supports 'debian', ">= 6.0"
supports 'centOS', ">= 6.5"
supports 'Redhat'
supports 'Fedora', ">= 20.0"

attribute 'webhooks/get_response',
          :display_name => "Webhooks GET Response",
          :description => "Stores response from GET request",
          :type => "string",
          :required => false,
          :recipes => [ 'webhooks::default' ],
          :default => ""

attribute 'webhooks/put_response',
          :display_name => "Webhooks PUT Response",
          :description => "Stores response from PUT request",
          :type => "string",
          :required => false,
          :recipes => [ 'webhooks::default' ],
          :default => ""

attribute 'webhooks/get_response',
          :display_name => "Webhooks POST Response",
          :description => "Stores response from POST request",
          :type => "string",
          :required => false,
          :recipes => [ 'webhooks::default' ],
          :default => ""