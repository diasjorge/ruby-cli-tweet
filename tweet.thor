require 'oauth'
require 'twitter_oauth'

class Tweet < Thor
  include Thor::Actions

  desc "tweet TEXT", "Post a new tweet"
  def tweet(text)
    client.update(text)

    say "Tweet! #{text}", :green
  end

  desc "install CONSUMER_KEY CONSUMER_SECRET", "Install configuration"
  def install(consumer_key, consumer_secret)
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, :site => "http://twitter.com")
    request_token = consumer.get_request_token

    say "Please visit #{request_token.authorize_url}"
    pin = ask("Please enter pin:")
    access_token = request_token.get_access_token(:oauth_verifier => pin)

    self.destination_root = File.expand_path("~")
    create_file ".ruby-cli-tweet" do
      YAML.dump({
                  "consumer_key" => consumer_key,
                  "consumer_secret" => consumer_secret,
                  "access_token_token" => access_token.token,
                  "access_token_secret" => access_token.secret
                })
    end

    say "Configuration created!"
  end


  protected

  def client
    @client ||=
      begin
        client = TwitterOAuth::Client.new(
                                          :consumer_key => config.consumer_key,
                                          :consumer_secret => config.consumer_secret,
                                          :token => config.access_token_token,
                                          :secret => config.access_token_secret
                                          )

        unless client.authorized?
          say "Could not authorize", :red
          exit 1
        end

        client
      end
  end

  def config
    @config ||=
      begin
        Thor::CoreExt::HashWithIndifferentAccess.new(YAML.load_file(File.expand_path("~/.ruby-cli-tweet")))
      rescue Errno::ENOENT
        say "You need to create the file .ruby-cli-tweet in your home", :red
        exit 1
      end
  end

end
