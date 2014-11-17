# gems
require 'sinatra'
require 'shotgun'

# routes

get '/' do
  erb :index
end

get '/search' do
	@query = params[:query]

	"You want to learn about things related to #{@query}"
end