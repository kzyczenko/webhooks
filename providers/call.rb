require 'net/http'
require 'uri'



#Get action
action :get do

  #Check if endpoint is accessable
  if @current_resource.accessable
    #Converge
    converge_by("Initiating Post of #{ @current_resource.operation_name }")
      execute_request("get")
    end
  else
    #Otherwise alert and do nothing
    Chef::Log.info "#{ @current_resource } does not have connectivity, please check connectivity."
  end


end



#Put action
action :put do

  #Check if endpoint is accessable
  if @current_resource.accessable
    #Converge
    converge_by("Initiating Post of #{ @current_resource.operation_name }")
      execute_request("put")
    end
  else
    #Otherwise alert and do nothing
    Chef::Log.info "#{ @current_resource } does not have connectivity, please check connectivity."
  end

end



#Post action
action :post do

  #Check if endpoint is accessable
  if @current_resource.accessable
    #Converge
    converge_by("Initiating Post of #{ @current_resource.operation_name }")
      execute_request("post")
    end
  else
    #Otherwise alert and do nothing
    Chef::Log.info "#{ @current_resource } does not have connectivity, please check connectivity."
  end

end



#Must load current resource state - nothing current
def load_current_resource
  @current_resource = Chef::Resource::WebhooksHttp.new(@new_resource.name)

  #Not Used
	@current_resource.operation_name(@new_resource.operation_name)
	#Base Required Options
	@current_resource.uri(@new_resource.uri)
	@current_resource.uri_port(@new_resource.uri_port)
	@current_resource.expected_response_codes(@new_resource.expected_response_codes)
	@current_resource.follow_redirect(@new_resource.follow_redirect)
	@current_resource.read_timeout(@new_resource.read_timeout)
	@current_resource.use_ssl(@new_resource.use_ssl)
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

  #Check that we have connectivity to the resource and set :accessable to true

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
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :read_timeout => @current_resource.read_timeout ) do |http| #Use ssl if scheme is set for it

      #Check what type of request
      case action
        when "post"
          req = Net::HTTP::Post.new(uri.path)   #let's post
        when "put"
          req = Net::HTTP::Put.new(uri.path)    #let's put
        when "get"
          req = Net::HTTP::Get.new(uri.path)    #let's get
      end

      #Check if we are going to use basic auth
      if @current_resource.use_basic_auth
        #Set username and password
        req.basic_auth(uri.user, uri.password)
      end

      #If we are posting or puting then check if we have post_data to put or post
      if (action == "post" || action == "put") && !@current_resource.post_data.nil?
        req.set_form_data( @current_resource.post_data )  #set the form data
      else
        #Else WTF?
        Chef::Log.info "You want to #{ action } but nothing is set in :post_data"
      end

      #Now we populate the headers, oh fun
      if !@current_resource.header_data.nil?
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
      @current_resource.uri = response['location']
      setup_uri  #Reset URI
      execute_request(action)  #Execute request again
    end

    #Check our response code and make sure it's in our array of expectations
    if @current_resource.expected_response_codes.include?( response.code ) #Check the array of response codes
      raise "Received an unexpected HTTP Response code #{ response.code }."
    else
      Chef::Log.info "Webhooks Operation Successful: #{ @current_resource.operation_name }!"
      node["webhooks"]["#{ action }_response"] = response['body']
    end

  #If we get an error, let's be nice and print it for people to ask why, oh why did my shit break
  rescue Exception => exception_msg #Throw execption
    Chef::Log.info "Error encountered: #{ exeception_msg.message }."
  end

end



#Method for settting up URI
def setup_uri

  #Start compiled uri
  compiled_uri = "http://"

  #Check if using ssl
  if @current_resource.use_ssl
    compiled_uri = "https://"
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
    compiled_uri = "#{ compiled_uri }@#{ @current_resource.uri }:#{ @current_resource.port }"
  end

  #Return the value
  return compiled_uri

end