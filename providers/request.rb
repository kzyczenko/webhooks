require 'net/http'
require 'uri'

use_inline_resources

#Get action
action :get do

  #Converge
  converge_by("Completed GET of #{ @new_resource.operation_name }") do

    execute_nethttp("get")

    @new_resource.updated_by_last_action(true)
  end

end



#Put action
action :put do

  #Converge
  converge_by("Completed PUT of #{ @new_resource.operation_name }") do

    execute_nethttp("put")

    @new_resource.updated_by_last_action(true)
  end

end



#Post action
action :post do

  #Converge
  converge_by("Completed POST of #{ @new_resource.operation_name }") do

    execute_nethttp("post")

    @new_resource.updated_by_last_action(true)
  end

end



#Must load current resource state - nothing current
def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:webhooks_request,node).new(@new_resource.name)

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
  @current_resource.post_json(@new_resource.post_json)
  @current_resource.post_xml(@new_resource.post_xml)
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


#Execute our library helper
def execute_nethttp(action)

  #Store our body response
  response = WebhooksNS.execute_request(action, @current_resource.uri, @current_resource.uri_port, @current_resource.expected_response_codes, @current_resource.follow_redirect,
                             @current_resource.read_timeout, @current_resource.use_ssl, @current_resource.ssl_validation, @current_resource.post_data, @current_resource.post_json,
                             @current_resource.post_xml, @current_resource.header_data, @current_resource.use_basic_auth, @current_resource.basic_auth_username,
                             @current_resource.basic_auth_password)

  #If we are to save the response, let's do it
  if @current_resource.save_response
    Chef::Log.info "Saving Response."
    node.override["webhooks"]["#{ action }_response"] = response.body
  end

  node.override["webhooks"]["response_code"] = response.code
  node.override["webhooks"]["response_message"] = response.message

end
