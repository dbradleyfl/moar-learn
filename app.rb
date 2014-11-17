# gems
require 'rubygems'
require 'sinatra'
require 'shotgun'
require 'amazon/ecs'


#config
Amazon::Ecs.configure do |options|
  options[:associate_tag] = 'dbradleyfl-20'
  options[:AWS_access_key_id] = 'AKIAJSO6UUPWHVNGORKA'
  options[:AWS_secret_key] = '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'
end


# routes

get '/' do
  erb :index
end

get '/search' do
	@query = params[:query]

	res = Amazon::Ecs.item_search( @query, :search_index => 'Books')

	@query_results = []

	res.items.each do |item|
	  # retrieve string value using XML path
	  @query_results << {title: item.get('ItemAttributes/Title'), url: item.get('DetailPageURL')}
	end

	erb :results
end