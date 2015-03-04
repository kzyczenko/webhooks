require 'net/http'
require 'uri'

use_inline_resources

#Get action
action :get do

  #Converge
  converge_by("Completed GET of #{ @new_resource.operation_name }") do

    execute_request("get")

    @new_resource.updated_by_last_action(true)
  end

end



#Put action
action :put do

  #Converge
  converge_by("Completed PUT of #{ @new_resource.operation_name }") do

    execute_request("put")

    @new_resource.updated_by_last_action(true)
  end

end



#Post action
action :post do

  #Converge
  converge_by("Completed POST of #{ @new_resource.operation_name }") do

    execute_request("post")

    @new_resource.updated_by_last_action(true)
  end

end



#Must load current resource state - nothing current
def load_current_resource
  @current_resource = Chef::Resource::WebhooksRequest.new(@new_resource.name)

  #Not Used
	@current_resource.operation_name(@new_resource.operation_name)
	#Base Required Options
	@current_resource.uri(@new_resource.uri)
	@current_resource.uri_port(@new_resource.uri_port)
	@current_resource.expected_response_codes(@new_resource.expected_response_codes)
	@current_resource.follow_redirect(@new_resource.follow_redirect)
	@current_resource.read_timeout(@new_resource.read_timeout)
	@current_resource.use_ssl(@new_resource.use_ssl)
  @current_resource.ssl_validation(@new_resource.ssl_validation)
	@current_resource.post_data(@new_resource.post_data)
  @current_resource.header_data(@new_resource.header_data)
	@current_resource.save_response(@new_resource.save_response)
	#Basic Authentication
	@current_resource.use_basic_auth(@new_resource.use_basic_auth)
	@current_resource.basic_auth_username(@new_resource.basic_auth_username)
	@current_resource.basic_auth_password(@new_resource.basic_auth_password)
	#Proxy Options
	@current_resource.use_proxy(@new_resource.use_proxy)
	@current_resource.proxy_address(@new_resource.proxy_address)
	@current_resource.proxy_port(@new_resource.proxy_port)
	@current_resource.proxy_username(@new_resource.proxy_username)
	@current_resource.proxy_password(@new_resource.proxy_password)

end



#Method for post action
def execute_request(action)

  #Complete URI
  return_uri = setup_uri

  #Create URI
  uri = URI.parse(return_uri)

  #Check if we have get params to send off
  if action == "get" && !@current_resource.post_data.nil?
    #Set the parameters
    uri.query = URI.encode_www_form( @current_resource.post_data )
  end

  begin

    #Begin the request and grab the response
    response = Net::HTTP.start(uri.host, @current_resource.uri_port, :use_ssl => uri.scheme == 'https', :verify_mode => (!@current_resource.ssl_validation && uri.scheme == 'https') ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER, :read_timeout => @current_resource.read_timeout ) do |http| #Use ssl if scheme is set for it

      #If we are using ssl, check for disable of verification (self-signed certs)
      if http.use_ssl? && !@current_resource.ssl_validation
        Chef::Log.info "Disabled SSL Validation."
      end

      Chef::Log.info "Setting up request for #{ uri.scheme }://#{ uri.host }#{ uri.path }."
      #Check what type of request
      case action
        when "post"
          Chef::Log.info "Setting up action #{ action }."
          req = Net::HTTP::Post.new(uri.path)   #let's post
        when "put"
          Chef::Log.info "Setting up action #{ action }."
          req = Net::HTTP::Put.new(uri.path)    #let's put
        when "get"
          Chef::Log.info "Setting up action #{ action }."
          req = Net::HTTP::Get.new(uri.path)    #let's get
      end

      #Check if we are going to use basic auth
      if @current_resource.use_basic_auth
        #Set username and password
        Chef::Log.info "Setting up basic authentication."
        req.basic_auth(uri.user, uri.password)
      end

      #If we are posting or puting then check if we have post_data to put or post
      if (action == "post" || action == "put") && !@current_resource.post_data.nil?
        Chef::Log.info "Setting form data for #{ action }."
        req.set_form_data( @current_resource.post_data )  #set the form data
      elsif action == "get"  #Do Nothing
        #Don't do anything
      else
        #Else WTF?
        Chef::Log.info "You want to #{ action } but nothing is set in :post_data"
      end

      #Now we populate the headers, oh fun
      if !@current_resource.header_data.nil?
        Chef::Log.info "Populating headers."
        @current_resource.header_data.each do |header,value|
          req["#{ header }"] = value
        end
      end

      #Start the request
      http.request(req)

    end

    #Check if we received a redirect
    if response == Net::HTTPRedirection && @current_resource.follow_redirect
      #If so, let's reset the uri and follow it if :follow_redirect is on
      Chef::Log.info "Redirection detected and following redirection."
      @current_resource.uri = response.location
      setup_uri  #Reset URI
      execute_request(action)  #Execute request again
    end

    #Check our response code and make sure it's in our array of expectations
    if !@current_resource.expected_response_codes.to_s.include?( "#{ response.code }" ) #Check the array of response codes
      raise "Received an unexpected HTTP Response code #{ response.code }."
    else
      Chef::Log.info "Webhooks Operation Successful: #{ @current_resource.operation_name }! Response Code #{ response.code }."
      #If we are to save the response, let's do it
      if @current_resource.save_response
        Chef::Log.info "Saving Response."
        node.override["webhooks"]["#{ action }_response"] = response.body
      end
    end

  #If we get an error, let's be nice and print it for people to ask why, oh why did my shit break
  rescue Exception => exception_msg #Throw exception
    Chef::Log.fatal "Error encountered: #{ exception_msg.message }."
    exit 1
  end

end



#Method for setting up the URI
def setup_uri

  #Start compiled uri
  compiled_uri = "http://"

  #Check if using ssl
  if @current_resource.use_ssl
    compiled_uri = "https://"
    if @current_resource.uri_port == 80
      @current_resource.uri_port(443)
    end
  end

  #Check if we are using authentication
  if @current_resource.use_basic_auth

    #Check if everything is there to process the request
    if @current_resource.basic_auth_username == nil || @current_resource.basic_auth_password == nil
      Chef::Log.info "You set :use_basic_auth to true but did not supply any credentials."
    else
      compiled_uri = "#{ compiled_uri }#{ @current_resource.basic_auth_username }:#{ @current_resource.basic_auth_password }@"
    end

  end

  #Now finish up, check if the uri is there as there is no default
  if @current_resource.uri == nil
    Chef::Log.info "You did not supply any value for URI. Please change and re-run."
  else
    compiled_uri = "#{ compiled_uri }#{ @current_resource.uri }"
  end

  #Return the value
  return compiled_uri

end