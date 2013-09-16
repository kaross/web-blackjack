require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  erb :get_name
end


