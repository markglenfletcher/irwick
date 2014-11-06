class WikipediaPlugin < IrcPlugin
  def initialize(options = {})
  end

  def on_privmsg_messages(message)
    if matches = /!(?<trigger>\S+) (?<query>.+)/.match(message.message)
      if matches[:trigger] == 'wiki'
        respond_to_trigger(matches[:query])
      end
    end
  end

  def respond_to_trigger(query)
    WikipediaCall.query(query)
  end
end

class WikipediaCall
end