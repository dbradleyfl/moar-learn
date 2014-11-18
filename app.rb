# gems
require 'rubygems'
require 'sinatra'
require 'shotgun'
require 'amazon/ecs'
require 'unirest'

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

class HPIdolAPI
	$apikey= HP_IDOL_KEY_CODE
	$url="http://api.idolondemand.com"

	def self.get_similar_topics(handler, data=Hash.new)
		similar_topics = []

	    data[:apikey]=$apikey
	    response=Unirest.post "#{$url}/1/api/sync/#{handler}/v1", 
	                        headers:{ "Accept" => "application/json" }, 
	                        parameters: data
	    response.body["entities"].each do |similar|
			similar_topics << similar["text"] unless similar["text"].downcase == data[:text].downcase
		end

		similar_topics
	end

end

# controllers / routes

get '/' do
  erb :index
end

get '/similar_topics' do
	@query = params[:query]

	@similar_topics = HPIdolAPI.get_similar_topics('findrelatedconcepts',{:text => @query })
	erb :similar_topics
end

get '/search/:query' do
	@query = params[:query]

	@query_results = AmazonAPI.getBooks(@query)

	erb :results
end

error do
	redirect '/'
end

not_found do
	redirect '/'
end