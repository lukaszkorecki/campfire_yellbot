require 'rubygems'
require 'bundler'

Bundler.require

require 'ext/http_patch_for_linux'
require 'yaml'

require 'lib/yellbot'
require 'lib/command'
require 'lib/helper'



config = YAML.load_file('config.yml')
replies = YAML.load_file('replies.yml')

unless ARGV.empty?
  ARGV.each do |file|
    puts "loading additional commands file: #{file}"
    load file
  end
end

command_interpreter = Command.new

bot = Yellbot.new  config, replies, command_interpreter

bot.connect!.join_and_listen
