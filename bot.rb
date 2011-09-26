require 'rubygems'
require 'bundler'

Bundler.require

require 'ext/http_patch_for_linux'
require 'yaml'

require 'lib/yellbot'
require 'lib/command'
require 'lib/helper'



unless ARGV.empty?
  ARGV.each do |file|
    puts "loading additional commands file: #{file}"
    load File.expand_path file
  end
end


bot = Yellbot.new(Command.new)
bot.load_config
bot.connect!.join_and_listen
