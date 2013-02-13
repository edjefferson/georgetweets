require 'twitter'
require 'engtagger'
require 'mysql'

class String
def georgealyser
  tgr = EngTagger.new
  tagged = tgr.add_tags(self)
  georgewords = ["Costanza", "George", "Costanza", "George", "Vandelay Industries", "George Costanza", "George Costanza", "Importer/Exporter"]
  nouns = tgr.get_nouns(tagged)
  nouns.delete_if {|key, value| key[0]==":"}
  nouns.delete_if {|key, value| key[0]=="@"}
  nouns.delete("http")
  b = nouns.keys.sample
  c = nouns.keys.sample
  self.gsub!("Alain","George")
  self.gsub!("de Botton","Costanza")
  self.gsub!("Religion for Atheists","Religion for Marine Biologists") 
  self.gsub!("Atheists","marine biologists") 
  self.gsub!("atheists","marine biologists") 
  self.gsub!(b,georgewords.sample)
  self.gsub!(c,georgewords.sample)

  return self
end

def trim140
  tweet = self
  while tweet.length>140
    tweetwords=tweet.split(' ')
    tweet=tweetwords[0..-2].join(' ') << "..."
 
  end
  return tweet
end
  
end

#heroku config:add DB_HOST= DB_USER= DB_PW= DB_NAME=


con = Mysql.new ENV['DB_HOST'],ENV['DB_USER'],ENV['DB_PW'],ENV['DB_NAME']

#heroku config:add E_CONSUMER_KEY= R_CONSUMER_SECRET= R_OATH_TOKEN= R_OATH_TOKEN_SECRET=

AlainTweets = Twitter.configure do |config|
  config.consumer_key = ENV['R_CONSUMER_KEY']
  config.consumer_secret = ENV['R_CONSUMER_SECRET']
  config.oauth_token = ENV['R_OATH_TOKEN']
  config.oauth_token_secret = ENV['R_OATH_TOKEN_SECRET']
end

#heroku config:add W_CONSUMER_KEY= W_CONSUMER_SECRET= W_OATH_TOKEN= W_OATH_TOKEN_SECRET=

AlainTwoots = Twitter.configure do |config|
  config.consumer_key = ENV['W_CONSUMER_KEY']
  config.consumer_secret = ENV['W_CONSUMER_SECRET']
  config.oauth_token = ENV['W_OATH_TOKEN']
  config.oauth_token_secret = ENV['W_OATH_TOKEN_SECRET']

end

result = con.query("select lasttweet from lasttweet where id=1")

x = result.fetch_row



  LatestTweet = AlainTweets.search("from:alaindebotton", :result_type => "recent",  :since_id => x[0].to_i ).results.reverse.each do |status|
    puts status.text.georgealyser
    puts status.id
    tweettext = status.text
    con.query("update lasttweet set lasttweet=#{status.id} where id=1")
    
    AlainTwoots.update(tweettext.trim140)  
  
    
  
  end

  

