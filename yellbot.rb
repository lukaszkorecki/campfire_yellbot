require 'rubygems'
require 'bundler'

Bundler.require

require 'yaml'
require 'yellbot_meme_generator'

CONFIG = YAML.load_file('config.yml')
$replies = YAML.load_file('replies.yml')
@meme_generator = YellbotMemeGenerator.new

def reload! room, message
  return if message.nil? or not message.is_a? String
  unless message.match(/^RELOAD!/).nil?
    begin
      $replies = YAML.load_file('replies.yml')
      room.speak "RELOADED TEH $replies file"
    rescue
      room.speak "CANT RELOAD, file BORKED"
    end
  end
end


def reply(room, message)
  $replies.each_pair do |name, reply|
    if Regexp.new(reply['regex'], Regexp::IGNORECASE).match(message)
      respond(room, reply)
    end
  end
  if @meme_generator.meme? message
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


cf_room = connect CONFIG['domain'], CONFIG['token'], CONFIG['room_name']

cf_room.join

cf_room.listen do |message|
  puts '-' * 80

  puts message

  reply(cf_room, message['body']) unless message.nil? or message['body'].nil?

end
