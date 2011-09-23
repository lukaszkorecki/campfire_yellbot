class Yellbot
  def initialize config, replies
    @domain = config['domain']
    @room_name = config['room_name']
    @token = config['token']

    @replies = replies
  end

  def reply(message)
    puts message
    @replies.each_pair do |name, reply|
      if Regexp.new(reply['regex'], Regexp::IGNORECASE).match(message)
        puts 'WE MATCHED A REPLY'
        respond( reply)
      end
    end

    if message =~ /^!!y/
      puts 'WE GOT A COMMAND'
      pref, command, *args = message.split(' ')
      resp = Command.send command.to_sym, args
      respond( make_it_a_message(resp))
    end
  end

  def make_it_a_message sth
    reply = sth.is_a?( Array) ? sth : [ sth ]
    { 'message' => reply}
  end

  def respond( reply)
    puts "Responding with: \n\t #{reply.inspect}"
    reply['message'].each {  |message| @room.speak(message) }
  end

  def connect!
    @campfire = ::Tinder::Campfire.new @domain, :token => @token
    @room =  @campfire.find_room_by_name @room_name
    self
  end


  def join_and_listen
    puts 'YELLBOT JOINS THE ROOM'
    @room.join

    @room.speak 'Yellbot Active!'

    begin
      @room.listen do |message|
        puts '-' * 80
        reply( message['body']) unless message.nil? or message['body'].nil?
      end
    rescue => e
      puts 'YELLBOT CRASHEDQ!!!!!!'
      puts e.to_yaml
      join_and_listen
    end
  end

end
