require 'cora'
require 'siri_objects'
require 'pp'
require 'socket'
require 'time'

# LightManager plugin v1.0 by Joep Verhaeg (info@joepverhaeg.nl)
# Last update: Dec 8, 2012
#
# Custom plugin for my home light scenes.
#
# Remember to add this plugin to the "config.yml" file!
######
class SiriProxy::Plugin::LightManager < SiriProxy::Plugin
  def initialize(config)
    # Appserver configuration (enable the appserver in Lightman Studio!)
    # host = config["jb_host"]
    # port = config["jb_port"]
    
    @host = "192.168.1.1"
    @port = 6004
    
    # Receiver/scene id mapping
    @receiver =  {'led' => '1','bookshelf' => '2','couch' => '3','kitchen' => '4','table' => '5','living' => '6', 'radio' => '7', 'squeezebox' => '8', 'TV' => '10', 'door' => '11'}
    @scenes = {'evening' => '1','wake' => '2','all' => '3','sleep' => '3','home' => '4','movie' => '5','leds' => '6'}
    
    @responses = [ "One moment.", "Your wish is my command.", "Just a second.", "OK.", "No problem.", "Hold on a second.", "Fine with me.", "Give me a second." ]
  end
 
  def kaku_device(device, command)
    begin
      case command
        when "off"
          signal = "0"
          say "Powering off your " + device + " light.", spoken: @responses[rand(@responses.size)]
        when "on"
          signal = "255"
          say "Powering on your " + device + " light.", spoken: @responses[rand(@responses.size)]
        else
            signal = command
            say "Dimming your " + device + " light to " + command + "%", spoken: @responses[rand(@responses.size)]
        end
      socket = TCPSocket.open(@host,@port)
      socket.puts("DEVICE~." + @receiver[device] + "~" + signal)
      socket.close
      request_completed
    rescue Exception => e
      say e.to_s, spoken: "Uh oh! Something bad happened..."
      request_completed
    end
  end

  def ir_device(device, command)
    begin
      case command
        when "off"
          signal = "0"
          say "Turning off your " + device + ".", spoken: @responses[rand(@responses.size)]
        when "on"
          signal = "110"
          say "Turning on your " + device + ".", spoken: @responses[rand(@responses.size)]
        when "watch"
          signal = "110"
          say "Turning on your " + device + ".", spoken: @responses[rand(@responses.size)]
        else
          say "I do not understand you."
        end
      socket = TCPSocket.open(@host,@port)
      socket.puts("DEVICE~." + @receiver[device] + "~" + signal)
      socket.close
      request_completed
    rescue Exception => e
      say e.to_s, spoken: "Uh oh! Something bad happened..."
      request_completed
    end
  end

  def kaku_scene(scene)
    begin
      if scene == "all" then
        say "Powering off all your lights.", spoken: @responses[rand(@responses.size)]
      elsif scene == "sleep" then
        say "See you later..."
      else 
        say "Starting the " + scene + " scene.", spoken: @responses[rand(@responses.size)]
      end
      socket = TCPSocket.open(@host,@port)
      socket.puts("SCENE~" + @scenes[scene])
      socket.close
      request_completed
    rescue Exception => e
      say e.to_s, spoken: "Uh oh! Something bad happened..."
      request_completed
    end
  end

  # Turn lights ON/OFF speaking scenario A
  listen_for /(led|bookshelf|couch|kitchen|table|living|door).*(on|off)/i do |src, cmd|
    kaku_device(src,cmd)
  end
  
  # Turn lights ON/OFF speaking scenario B
  listen_for /(on|off).*(led|bookshelf|couch|kitchen|table|living|door)/i do |cmd, src|
    kaku_device(src,cmd)
  end

  # DIM lights speaking scenario A
  listen_for /(kitchen|table|living).*(dim).*([0-9,].*[0-9])/i do |src, cmd, lvl|
    kaku_device(src,lvl)
  end

  # DIM lights speaking scenario B
  # listen_for /(dim).*(kitchen|table|living).*([0-9,].*[0-9])/i do |cmd, src, lvl|
    listen_for /(kitchen|table|living).*([0-9,].*[0-9])/i do |src, lvl|
    kaku_device(src,lvl)
  end

  # Launch a light scene speaking scenario A
  listen_for /(evening|all|dinner|wake|home|movie|leds).*light/i do |src|
    kaku_scene(src)
  end

  # Launch a light scene speaking scenario B
  listen_for /light.*(evening|all|dinner|wake|home|movie|leds)/i do |src|
    kaku_scene(src)
  end

  # Launch going to sleep light scene
  listen_for /going.*(sleep|bed)/i do
    response = ask "Should I turn off the lights?"
    if(response =~ /yes/i)
      kaku_scene("sleep")
    else
      say "See you later..."
      request_completed
    end
  end

  # Turn IR device ON/OFF speaking scenario A
  listen_for /(TV|radio|squeezebox).*(on|off|watch)/i do |src, cmd|
    ir_device(src,cmd)
  end
  
  # Turn IR device ON/OFF speaking scenario B
  listen_for /(on|off|watch).*(TV|radio|squeezebox)/i do |cmd, src|
    ir_device(src,cmd)
  end
end
