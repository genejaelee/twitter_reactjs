class ApiController < ApplicationController
  def get_user
    client = create_twitter_client
    @username = params[:username]
    render :json => client.user_timeline(@username).take(10)
  end
  
  def get_parents
    parent_tweet_id = params[:parent_tweet_id]
    # loop through requests up reply chain
    tweets = get_parents(parent_tweet_id)
    puts tweets
    render :json => {
      :tweets => tweets
    }
  end
  
  def get_parents(id)
    client = create_twitter_client
    @id = id
    replies = []
    reply_exists = true
    while reply_exists do
      reply = client.status(@id)
      puts 'pushed reply to array'
      replies.push(reply)
      if !reply.in_reply_to_status_id.nil?
        puts 'reply exists'
        @id = reply.in_reply_to_status_id
        reply_exists = true
      else
        puts 'no more replies'
        reply_exists = false
      end
    end
    return replies
  end
  
  # turn this into initialized module
  def create_twitter_client
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
    return client
  end
end
