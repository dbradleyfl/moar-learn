# gems
require 'rubygems'
require 'sinatra'
require 'shotgun'
require 'amazon/ecs'
require 'Unirest'

require_relative 'keys.rb'

#Models

class AmazonAPI
	Amazon::Ecs.configure do |options|
	  options[:associate_tag] = AMAZON_TRACKING_ID
	  options[:AWS_access_key_id] = AMAZON_ACCESS_KEY_CODE
	  options[:AWS_secret_key] = AMAZON_SECRET_KEY_CODE
	end

	def self.getBooks(topic)
		query_results = []
		res = Amazon::Ecs.item_search( topic, :search_index => 'Books')

		res.items.each do |item|
		  # retrieve string value using XML path
		query_results << {title: item.get('ItemAttributes/Title'), url: item.get('DetailPageURL')}
		end

		return query_results
	end
end


# controllers / routes

get '/' do
  erb :index
end

get '/search' do
	@query = params[:query]

	@query_results = AmazonAPI.getBooks(@query)

	erb :results
end