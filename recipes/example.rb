#
# Cookbook Name:: example
# Recipe:: default
#
# Copyright 2014, Brian Stajkowski
#
# All rights reserved - Do Not Redistribute
#

webhooks_call "Test Call" do
  uri "1.1.1.1/examplecall"
  expected_response_codes [200,201]

  action :post
end