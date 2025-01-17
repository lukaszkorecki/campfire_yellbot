require 'yaml'
class Yellbot
  def initialize command
    @command = command
    @predefined_commands = [ 'RELOAD', 'REPLIES', 'COMMANDS'].map { |c| "yellbot #{c}"}

    @me = nil
  end

  def load_config
    config = YAML.load_file('config.yml')

    @domain = config['domain']
    @room_name = config['room_name']
    @token = config['token']

    @replies = YAML::load_file( 'replies.yml')
  end


  def reply(message)
    puts message
    case message
    when 'yellbot RELOAD'
      load_config
      respond make_it_a_message('configs reloaded')
    when 'yellbot REPLIES'
      paste @replies.map {|name, conf| conf['regex'] }.to_yaml
    when 'yellbot COMMANDS'
      b = (@command.methods - Object.new.methods).reject! { |m| m == 'method_missing'}
      paste  (@predefined_commands + b).map {|s| '> ' + s }.to_yaml
    end

    @replies.each_pair do |name, reply|
      if Regexp.new(reply['regex'], Regexp::IGNORECASE).match(message)
        puts 'WE MATCHED A REPLY'
        respond( reply)
      end
    end

    if message =~ /^yellbot\s/ and not @predefined_commands.include? message
      puts 'WE GOT A COMMAND'
      pref, command, *args = message.split(' ')
      resp = @command.send command.to_sym, args
      respond( make_it_a_message(resp))
    end
  end

  def make_it_a_message sth
    reply = sth.is_a?( Array) ? sth : [ sth ]
    { 'message' => reply}
  end

  def paste str
    @room.paste str
  end

  def respond( reply)
    puts "Responding with: \n\t #{reply.inspect}"
    reply['message'].each {  |message| @room.speak(message) }
  end

  def connect!
    @campfire = ::Tinder::Campfire.new @domain, :token => @token
    @room =  @campfire.find_room_by_name @room_name
    @me ||= @campfire.me
    self
  end


  def join_and_listen init=false
    puts 'YELLBOT JOINS THE ROOM'
    @room.join

    @room.speak 'Yellbot Active!' if  init

    begin
      @room.listen do |message|
        puts '-' * 80
        puts "USER: #{message.inspect} vs #{@me.inspect}"
        if message['user'] and message['user']['id'] != @me['id'] and not message.nil? and not message['body'].nil?
          reply( message['body'])
        end
      end
    rescue => e
      puts 'YELLBOT CRASHEDQ!!!!!!'
      puts e.to_yaml
      join_and_listen(false)
    end
  end

end
