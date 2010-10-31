require 'twitter_oauth'

YOUR_CONSUMER_KEY       = ""
YOUR_CONSUMER_SECRET    = ""
YOUR_OAUTH_TOKEN        = ""
YOUR_OAUTH_TOKEN_SECRET = ""

class Tweet < Thor
  desc "tweet TEXT", "Post a new tweet"
  def tweet(text)
    client.update(text)

    say "Tweet! #{text}", :green
  end

  protected

  def client
    @client ||=
      begin
        client = TwitterOAuth::Client.new(
                                          :consumer_key => YOUR_CONSUMER_KEY,
                                          :consumer_secret => YOUR_CONSUMER_SECRET,
                                          :token => YOUR_OAUTH_TOKEN,
                                          :secret => YOUR_OAUTH_TOKEN_SECRET
                                          )

        unless client.authorized?
          say "Could not authorize", :red
          exit 1
        end

        client
      end
  end
end
