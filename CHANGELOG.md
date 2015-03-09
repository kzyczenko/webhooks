webhooks CHANGELOG
==================

0.1.3
-----
- stajkowski - Fixed URI parse for parameters.  Now you can include www.mysite.com/gethosts?api_key=123 URL parameters and they will be passed.  Added post_json option to post post_data as json; default
is set to false but just enable with true.  Moved the entire implementation to a Library WebhooksNS into Chef::Provider::LWRP and Chef::Recipe so you can access in either an LWRP or Recipe by WebhooksNS.execute_request

The defaults of the method follow the defaults of the LWRP Resource so if you don't include a parameter then it will default to what is described for the LWRP Resource.  Please see the Provider on how to use
this Library; basically, you get the full response back and can use it how you please.

- - -

0.1.25
-----
- stajkowski - Fix ssl validation disable.  Also adjusted exception message and exit status.

- - -

0.1.2
-----
- stajkowski - Add ssl_validation attribute.  It is set to enable by default; disable it for self signed certs.

- - -

0.1.1
-----
- stajkowski - Fix Documentation

- - -

0.1.0
-----
- stajkowski - Initial release of webhooks

- - -