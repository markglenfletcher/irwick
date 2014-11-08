require 'net/http'
require 'json'

class WikipediaPlugin < IrcPlugin
  def initialize(options = {})
    @wikipedia_call = options[:wikipedia_call] || WikipediaCall.new
  end

  def on_privmsg_messages(message)
    if matches = /!(?<trigger>\S+) (?<query>.+)/.match(message.message)
      if matches[:trigger] == 'wiki'
        wiki_response = respond_to_trigger(matches[:query])
        IrcTools::PrivmsgMessage.new(:recipient => message.recipient, :message => wiki_response.slice(0,400))
      end
    end
  end

  def respond_to_trigger(query)
    @wikipedia_call.query(query)
  end
end

class WikipediaCall
  WIKIPEDIA_EXTRACTS_QUERY_URL = 'http://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro='

  def query(query)
    begin
      json_response = Net::HTTP.get build_uri_for(query)
      dissect_json json_response
    rescue KeyError
      'Could not parse the JSON response from Wikipedia'
    rescue Exception => e
      "Can't do it!"
    end
  end

  def build_uri_for(query)
    URI(WIKIPEDIA_EXTRACTS_QUERY_URL + "&titles=#{query}")
  end

  def dissect_json(json_string)
    # Strip HTML tags from the string
    json_string.gsub!(/<\/?[^>]*>/, "")
    json = JSON.parse(json_string)
    page_key = json.fetch('query').fetch('pages').keys[0]
    extract = json.fetch('query').fetch('pages').fetch(page_key).fetch('extract')
    # Strip new lines
    extract.gsub("\n",'')
  end
end