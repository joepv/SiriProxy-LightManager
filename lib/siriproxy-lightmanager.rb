require 'cora'
require 'siri_objects'
require 'pp'
require 'socket'

# LightManager plugin v0.9 by Joep Verhaeg (info@joepverhaeg.nl)
# Last update: Mar 5, 2012
#
# Custom plugin for my home light scenes.
#
# Remember to add this plugin to the "config.yml" file!
######
class SiriProxy::Plugin::LightManager < SiriProxy::Plugin
  def initialize(config)
    # Appserver configuration (enable the appserver in Lightman Studio!)
    @host = "192.168.1.1"
    @port = 6004
    
    # Receiver/scene id mapping
    @receiver =  {'led' => '1','bookshelf' => '2','couch' => '3','kitchen' => '4','table' => '5','living' => '6'}
    @scenes = {'TV' => '1','sleep' => '4','dinner' => '2','wake' => '3'}
  end
 
  def kaku_device(device, command)
    case command
      when "off"
        signal = "0"
        say "I'll power off your " + device + " light!"
      when "on"
        signal = "255"
        say "I'll power on your " + device + " light!"
      else
          signal = command
          say "I'll dim your " + device + " light to " + command + "%"
      end
    socket = TCPSocket.open(@host,@port)
    socket.puts("DEVICE~." + @receiver[device] + "~" + signal)
    socket.close
    request_completed
  end

  def kaku_scene(scene)
    if scene == "sleep" then
      say "See you later..."
    else 
    say "Starting your favorite " + scene + " light scene."
    end
    socket = TCPSocket.open(@host,@port)
    socket.puts("SCENE~" + @scenes[scene])
    socket.close
    request_completed
  end

  # Turn lights ON/OFF speaking scenario A
  listen_for /(led|bookshelf|couch|kitchen|table|living).*(on|off)/i do |src, cmd|
    kaku_device(src,cmd)
  end
  
  # Turn lights ON/OFF speaking scenario B
  listen_for /(on|off).*(led|bookshelf|couch|kitchen|table|living)/i do |cmd, src|
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
  listen_for /(tv|dinner|wake).*scene/i do |src|
    kaku_scene(src)
  end

  # Launch a light scene speaking scenario B
  listen_for /scene.*(tv|dinner|wake)/i do |src|
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
end