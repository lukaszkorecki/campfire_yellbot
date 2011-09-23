# Yellbot


Is your campfire room not cluttered enough?  Use yellbot to annoy all your co-workers.
Apart from that Yellbot can do much more - take a look at Commands

# Get started

1. clone it
2. (you need rubygems and bundler)
3. `bundle install`
4. configure stuff
3. `ruby bot.rb`
4. ??????
5. profit

# Configuration

1. cp config.yml.example config.yml
2. cp replies.yml.example replies.yml

Edit the config files (duh).

# Commands

Yellbot accepts commands (that is if you write them :-))

The syntax is:

    yellbot <command> <args>


(look in `lib/command.rb`)

If you want to add more just create a separate file, monkey patch the
Command class and load the file during startup with:

    ruby bot.rb <path to your additional commands file>

### example

Monkey patch Command class:

    class Command

      def time args=nil
        Time.now
      end
    end
and save it to `time.rb` and load it:

    ruby bot.rb time.rb

now:

> yellbot time

will  send the 'time' command to yellbot, and call method `:time` on
instance of Command class.

Arguments to commands are always passed as an array.


# Automatic replies
Configure your replies in `replies.yml` using this format:

    rage:
      regex: '^rage$'
      message:
        - FFFFFFUUUUUUU

Then if someone types 'rage' the bot will reply with 'FFFFFFUUUUUUU'

Because `message`  is an array you can have a list of replies for one
trigger (useful if you want the bot to reply with a text message and a
in image).
