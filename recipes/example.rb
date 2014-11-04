#
# Cookbook Name:: webhooks
# Recipe:: example
#
# Copyright 2014, Brian Stajkowski
#
# All rights reserved - Do Not Redistribute
#

webhooks_request "Test Call" do
  uri "s1n4l2n5wulz.runscope.net/"
  use_ssl true
  expected_response_codes [ 200, 201 ]
  action :get
end