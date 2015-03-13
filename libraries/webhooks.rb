class Chef::Provider::LWRPBase

  class WebhooksNS

    require 'net/http'
    require 'uri'

    extend Chef::Mixin::ShellOut

    #Method for post action
    def self.execute_request(action=get, url_uri=nil, uri_port=80, expected_response_codes=[200], follow_redirect=false, read_timeout=60, use_ssl=false,
                        ssl_validation=true, post_data=nil, post_json=false, post_xml=false, header_data=nil, use_basic_auth=false, basic_auth_username=nil, basic_auth_password=nil)

      #Complete URI
      return_uri = setup_uri(url_uri, use_ssl, use_basic_auth, basic_auth_username, basic_auth_password)

      #Create URI
      uri = URI.parse(return_uri)
      if url_uri.include? "?" #if our original uri contains parameters, extract and encode
        Chef::Log.info("Encoding parameters for: #{ url_uri }")
        new_query_ar = URI.decode_www_form(uri.query || '') #extract our parameters
        uri.query = URI.encode_www_form(new_query_ar) #encode our findings
      end

      #Check if we have get params to send off
      if action == "get" && !post_data.nil?
        #Set the parameters
        uri.query = URI.encode_www_form( post_data )
      end

      #Check for port scheme match
      if uri.scheme == 'https' && uri_port == 80
        uri_port = 443
      end

      begin

        #Begin the request and grab the response
        response = Net::HTTP.start(uri.host, uri_port, :use_ssl => uri.scheme == 'https', :verify_mode => (!ssl_validation && uri.scheme == 'https') ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER, :read_timeout => read_timeout ) do |http| #Use ssl if scheme is set for it

          #If we are using ssl, check for disable of verification (self-signed certs)
          if http.use_ssl? && !ssl_validation
            Chef::Log.info "Disabled SSL Validation."
          end

          Chef::Log.info "Setting up request for #{ uri.scheme }://#{ uri.host }#{ uri.path }."
          #Check what type of request
          case action
            when "post"
              Chef::Log.info "Setting up action #{ action }: #{ uri.path + ( uri.query != nil ? ('?' + uri.query) : '' )  }."
              req = Net::HTTP::Post.new(uri + ( uri.query != nil ? ('?' + uri.query) : '' ) )   #let's post
            when "put"
              Chef::Log.info "Setting up action #{ action }: #{ uri.path + ( uri.query != nil ? ('?' + uri.query) : '' ) }."
              req = Net::HTTP::Put.new(uri.path + ( uri.query != nil ? ('?' + uri.query) : '' ) )    #let's put
            when "get"
              Chef::Log.info "Setting up action #{ action }: #{ uri.path + ( uri.query != nil ? ('?' + uri.query) : '' ) }."
              req = Net::HTTP::Get.new(uri.path + ( uri.query != nil ? ('?' + uri.query) : '' ))    #let's get
          end

          #Check if we are going to use basic auth
          if use_basic_auth
            #Set username and password
            Chef::Log.info "Setting up basic authentication."
            req.basic_auth(uri.user, uri.password)
          end

          #If we are posting or puting then check if we have post_data to put or post
          if (action == "post" || action == "put") && !post_data.nil?
            Chef::Log.info "Setting form data for #{ action }."
            if post_json
              #if we need to post JSON
              Chef::Log.info("Setting body to JSON")
              req.body = JSON.dump(post_data)
            else
              #else normal form data
              req.set_form_data( post_data )  #set the form data
            end
          elsif action == "get"  #Do Nothing
            #Don't do anything
          else
            #Else WTF?
            Chef::Log.info "You want to #{ action } but nothing is set in :post_data"
          end

          #Now we populate the headers, oh fun
          if !header_data.nil?
            Chef::Log.info "Populating headers."
            header_data.each do |header,value|
              req["#{ header }"] = value
            end
          end

          #Start the request
          http.request(req)

        end

        #Check if we received a redirect
        if response == Net::HTTPRedirection && follow_redirect
          #If so, let's reset the uri and follow it if :follow_redirect is on
          Chef::Log.info "Redirection detected and following redirection."
          url_uri = response.location
          setup_uri(url_uri, use_ssl, use_basic_auth, basic_auth_username, basic_auth_password)  #Reset URI
          execute_request(action, url_uri, uri_port, expected_response_codes, follow_redirect, read_timeout, use_ssl, ssl_validation, post_data, post_json, post_xml, header_data, use_basic_auth, basic_auth_username, basic_auth_password)  #Execute request again
        end

        #Check our response code and make sure it's in our array of expectations
        if !expected_response_codes.to_s.include?( "#{ response.code }" ) #Check the array of response codes
          raise "Received an unexpected HTTP Response code #{ response.code }."
        else
          Chef::Log.info "Webhooks Operation Successful! Response Code #{ response.code }."
          return response
        end

          #If we get an error, let's be nice and print it for people to ask why, oh why did my shit break
      rescue Exception => exception_msg #Throw exception
        Chef::Log.fatal "Error encountered: #{ exception_msg.message }."
        exit 1
      end

    end


    #Method for setting up the URI
    def self.setup_uri(uri, use_ssl, use_basic_auth, basic_auth_username, basic_auth_password)

      #Start compiled uri
      compiled_uri = "http://"

      #Check if using ssl
      if use_ssl
        compiled_uri = "https://"
      end

      #Check if we are using authentication
      if use_basic_auth

        #Check if everything is there to process the request
        if basic_auth_username == nil || basic_auth_password == nil
          Chef::Log.info "You set :use_basic_auth to true but did not supply any credentials."
        else
          compiled_uri = "#{ compiled_uri }#{ basic_auth_username }:#{ basic_auth_password }@"
        end

      end

      #Now finish up, check if the uri is there as there is no default
      if uri == nil
        Chef::Log.info "You did not supply any value for URI. Please change and re-run."
      else
        compiled_uri = "#{ compiled_uri }#{ uri }"
        Chef::Log.info "Complete URI: #{ compiled_uri}"
      end

      #Return the value
      return compiled_uri

    end

  end

end


#Extend our methods to the Recipe NS
class Chef::Recipe::WebhooksNS < Chef::Provider::LWRPBase::WebhooksNS

end