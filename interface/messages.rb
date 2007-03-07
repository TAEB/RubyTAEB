#!/usr/bin/ruby

class MessageHandler
  def initialize()
    @message_hooks = []
  end

  def add_message_hook(regex, callback)
    @message_hooks.push([regex, callback])
  end

  def del_message_hook(regex, callback)
    if callback == nil
      @message_hooks.delete_if do |regex_callback|
        regex_callback[0] == regex
      end
    else
      @message_hooks.delete_if do |regex_callback|
        regex_callback == [regex, callback]
      end
    end
  end

  def check_message_hooks(message)
    message.gsub!(/ {2,}/, ' ')

    @message_hooks.each do |regex_callback|
      if message =~ regex_callback[0]
        regex_callback[1].call(regex_callback[0].match_data)
      end
    end
  end

  def clear_screen()
    message = ""

    while 1
      if $controller.vt.row(0) =~ /^Do you want your possessions identified\?/ or
         $controller.vt.row(0) =~ /^Do you want to see what you had when you died\?/
        debug("Oh no! We died!")
        $controller.send("y")
        while 1 # let the Disconnect exception break the loop
          $controller.send(" ")
          sleep 1
        end
      end

      if $controller.vt.row(0) =~ /^ *Things that are here: *$/ or
         $controller.vt.row(2) =~ /^ *Things that are here: *$/
        debug("Things that are here menu")
        $controller.send(" ")
        redo
      end

      if $controller.vt.to_s =~ /^(.+)--More--/
           debug("I see a --More--!")
           message += $`
           $controller.send(" ")
           redo
      end

      break
    end

    check_message_hooks(message)
  end
end

