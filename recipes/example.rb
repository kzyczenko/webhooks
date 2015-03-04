#
# Cookbook Name:: webhooks
# Recipe:: example
#
# Copyright 2014, Brian Stajkowski
#
# All rights reserved - Do Not Redistribute
#

webhooks_request "Test Get" do
  uri "s1n4l2n5wulz.runscope.net/"
  use_ssl true
  ssl_validation false
  expected_response_codes [ 200, 201 ]
  action :get
end

webhooks_request "Test Post" do
  uri "s1n4l2n5wulz.runscope.net/"
  use_ssl true
  ssl_validation false
  post_data (
                { 'value1' => '1', 'value2' => '2'}
            )
  header_data (
                { 'header1' => '1', 'header2' => '2', 'User-Agent' => 'Mozilla/5.0'}
              )
  expected_response_codes [ 200, 201 ]
  action :post
end

webhooks_request "Test Put" do
  uri "s1n4l2n5wulz.runscope.net/"
  use_ssl true
  ssl_validation false
  use_basic_auth true
  basic_auth_username "test_username"
  basic_auth_password "test_password"
  post_data (
                { 'value1' => '1', 'value2' => '2'}
            )
  expected_response_codes [ 200, 201 ]
  action :put
end