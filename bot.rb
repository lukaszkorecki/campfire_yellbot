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

bot = Yellbot.new  config, replies

bot.connect!.join_and_listen
