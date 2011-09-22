require 'rubygems'
require 'bundler'

Bundler.require

require 'http_patch_for_linux'
require 'yaml'
require 'yellbot_meme_generator'

CONFIG = YAML.load_file('config.yml')
$replies = YAML.load_file('replies.yml')
@meme_generator = YellbotMemeGenerator.new

class Commands
  def self.reload arg=nil
    s = ''
    begin
      `curl #{CONFIG['replies_url']} > replies.yml`
      $replies = YAML.load_file('replies.yml')
      s = "RELOADED TEH $replies file"
    rescue
      s = "CANT RELOAD, file BORKED"
    end
    s
  end


  def self.test arg=[]
    arg.join ' - '
  end
end


def make_it_a_message sth
  reply = sth.is_a?( Array) ? sth : [ sth ]
  { 'message' => reply}
end

def reply(room, message)
  puts message
  $replies.each_pair do |name, reply|
    if Regexp.new(reply['regex'], Regexp::IGNORECASE).match(message)
      respond(room, reply)
    end
  end

  if message =~ /^!!y/
    pref, command, *args = message.split(' ')
    resp = Commands.send command.to_sym, args
    respond(room, make_it_a_message(resp))
  end
end

def respond(room, reply)
  reply['message'].each do |message|
    room.speak(message)
  end
end

def connect domain, token, room_name
  campfire = ::Tinder::Campfire.new domain, :token => token

  campfire.find_room_by_name room_name
end



def join_and_listen _room
  puts 'YELLBOT JOINS THE ROOM'
  room = _room
  room.join

  begin
    room.listen do |message|
      puts '-' * 80
      reply(room, message['body']) unless message.nil? or message['body'].nil?

    end
  rescue => e
    puts 'YELLBOT CRASHEDQ!!!!!!'
    puts e.to_yaml
    join_and_listen _room
  end
end

cf_room = connect CONFIG['domain'], CONFIG['token'], CONFIG['room_name']
join_and_listen cf_room
