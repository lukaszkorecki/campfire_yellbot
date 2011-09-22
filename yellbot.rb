require 'rubygems'
require 'bundler'

Bundler.require

require 'http_patch_for_linux'
require 'yaml'
require 'yellbot_meme_generator'

CONFIG = YAML.load_file('config.yml')
$replies = YAML.load_file('replies.yml')
@meme_generator = YellbotMemeGenerator.new

def reload! room, message
  return if message.nil? or not message.is_a? String
  unless message.match(/^RELOAD!/).nil?
    begin
      `curl #{CONFIG['replies_url']} > replies.yml`
      $replies = YAML.load_file('replies.yml')
      s = "RELOADED TEH $replies file"
    rescue
      s = "CANT RELOAD, file BORKED"
    end
  end
end


def reply(room, message)
  $replies.each_pair do |name, reply|
    if Regexp.new(reply['regex'], Regexp::IGNORECASE).match(message)
      respond(room, reply)
    end
  end
  if false # @meme_generator.meme? message
    respond(room, {'message' => [@meme_generator.reply(message)]})
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
  room = _room
  room.join

  begin
    room.listen do |message|
      puts '-' * 80

      puts message

      reply(room, message['body']) unless message.nil? or message['body'].nil?

    end
  rescue => e
    join_and_listen _room
  end
end

cf_room = connect CONFIG['domain'], CONFIG['token'], CONFIG['room_name']
join_and_listen cf_room
