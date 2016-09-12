server_helper = {
players = {}
}

dofile(minetest.get_modpath("server_helper").."/config.lua")

minetest.register_on_chat_message(function(name,message)
  if minetest.setting_getbool("punctuation_control") == true then
    if string.match(message, "%p%p%p%p%p%p") then
      minetest.chat_send_all("<The All Seeing Eye> Please do not go over-board with punctuation.")
    end
  end
end)

-- Can be turned on and off using the time_change setting in config.lua.
minetest.register_on_chat_message(function(name,message)
  if minetest.setting_getbool("time_change") == true then
    if message == "can we have day" or message == "can we have day?" or message == "Can we have day?" or message == "day?" or
    message == "Day?" or message == "day please" or message == "please have day" then
      minetest.set_timeofday(.4)
      minetest.chat_send_all("<The All Seeing Eye> It is now day!")
    elseif message == "can we have night" or message == "can we have night?" or message == "Can we have night?" or message == "night?" or
    message == "Night?" or message == "night please" or message == "please have night" then
      minetest.set_timeofday(0)
      minetest.chat_send_all("<The All Seeing Eye> It is now night!")
    end
  end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
    server_helper.players[name] = {shout = 0,}
	local a = server_helper.players[name].shout
end)

-- This watches for all caps usage and warns 4 times and kicks on the 5th.
minetest.register_on_chat_message(function(name,message)
  if minetest.setting_getbool("cap_usage") == true then
    if string.match(message, "%u%u%u%u") or string.match(message, "%u%u%u %u") or string.match(message, "%u %u%u%u") or
    string.match(message, "%u %u%u %u") or string.match(message, "%u%l%u%l%u") then
      local a = server_helper.players[name].shout
		  a = a + 1
      server_helper.players[name] = {shout = a,}
      if a < 5 then
        minetest.chat_send_all("<The All Seeing Eye> Please refrain from using all caps.")
      elseif a >= 5 then
        minetest.kick_player(name, "You were told to stop and you didn't.")
        minetest.chat_send_all(name .. " was just kicked for not following the rules.")
      end
    end
  end
end)

local you = "u"
local b = 1
minetest.register_on_chat_message(function(name,message)
  if string.match(message, "help") or string.match(message, "Help") or string.match(message, "I need help.") or
  string.match(message, "i need help") then
    minetest.chat_send_player(name, "<The All Seeing Eye> What do you need help with?")
      b = 1
      minetest.register_on_chat_message(function(name,message)
        if message == "how do i set home" or message == "How do I set home" or message == "How do I set home?" or
        message == "how do i set home?" or message == "set home?" or message == "how to set home?" or message == "how to set home" and b == 1 then
          minetest.chat_send_player(name, "<The All Seeing Eye> If you have the home priv, you can set home by going to the location where you would like to set home and type /sethome.")
          b = 0
        elseif string.match(message, "ip") or string.match(message, "ip?") or string.match(message, "IP") or string.match(message, "IP?") or
        string.match(message, "what is my ip") or string.match(message, "what is my ip?") or string.match(message, "What is my ip?") or
        string.match(message, "What is my IP") or string.match(message, "What is my IP?") or string.match(message, "my ip") or string.match(message, "my ip?") or
        string.match(message, "My IP") or string.match(message, "My IP?") then
          if b == 1 then
            minetest.chat_send_player(name, "<The All Seeing Eye> " ..minetest.get_player_ip(name))
            b = 0
          end
        elseif string.match(message, "how to protect using areas") or string.match(message, "How to protect using areas?") or string.match(message, "how do"..you.." protect using areas") or string.match(message, "how do"..you.." protect using areas?") or
        string.match(message, "how do "..you.." use areas?") or string.match(message, "How do"..you.." use areas?") or string.match(message, "help protecting") then
          if b == 1 then
            minetest.chat_send_player(name, "<The All Seeing Eye> You can potect a build by typing /area_pos set and setting 2 diagonal positions on the x,y,z axis.  Then you can use /protect (area name) to finish.")
            b = 0
          end
        end
      end)
  end
end)

-- This will ask you if you want to teleport to spawn if you are stuck.
-- Note: Only works if there is a static_spawnpoint set in the minetest.conf
local respawn = 1
minetest.register_on_chat_message(function(name,message)
  if message == "I am stuck." or message == "I'm stuck." or message == "im stuck" or message == "Help I am stuck." or
  message == "help i am stuck" or message == "help stuck" or message == "help im stuck" then
    minetest.chat_send_player(name, "<The All Seeing Eye> Would you like me to teleport you to spawn?")
      respawn = 1
      minetest.register_on_chat_message(function(name,message)
        if message == "no" and respawn == 1 then
          minetest.chat_send_player(name, "<The All Seeing Eye> Ok.")
          respawn = 0
        elseif message == "yes" then
          if respawn == 1 then
            local pos = minetest.setting_get_pos("static_spawnpoint")
            local player = minetest.get_player_by_name(name)
            player:setpos(pos)
            minetest.chat_send_player(name, "<The All Seeing Eye> There you are!")
            respawn = 0
          end
        end
      end)
    end
end)

-- If you die in singleplayer you are given an option to teleport to your bones.
local question = 1
minetest.register_on_dieplayer(function(player)
  local pos = vector.round(player:getpos())
  minetest.chat_send_player(player:get_player_name(),"<The All Seeing Eye> Would you like me to teleport you to your bones?")
    question = 1
    minetest.register_on_chat_message(function(name,message)
      if message == "no" and question == 1 then
          minetest.chat_send_player(name, "<The All Seeing Eye> Ok.")
          question = 0
      elseif message == "yes" then
        if question == 1 then
          local playername = player:get_player_name(player)
          player:setpos(pos)
          minetest.chat_send_player(name, "<The All Seeing Eye> There you are!")
          question = 0
        end
      end
    end)
end)

minetest.register_on_chat_message(function(name,message)
  if message == "Hi" or message == "hi" or message == "hello" or message == "Hello" or
  message == "Hola" or message == "hola" or message == "howdy" or message == "Howdy" or
  message == "Hoy" or message == "hoy" then
    minetest.chat_send_all("<The All Seeing Eye> Hello "..name..".")
  end
end)

local myname = "The All Seeing Eye"
local myname2 = "the all seeing eye"
minetest.register_on_chat_message(function(name,message)
  if string.match(message, myname) then
    minetest.chat_send_all("<The All Seeing Eye> What do you need?")
  end
  if string.match(message, myname2) then
    minetest.chat_send_all("<The All Seeing Eye> What do you need?")
  end
end)

-- These watch for certain keywords or phrases and make a response.
minetest.register_on_chat_message(function(name,message)
  if string.match(message, "grief" or "griefing" or "griefed") then
    minetest.chat_send_all("<The All Seeing Eye> Griefing is not permitted and will not be allowed!")
  end
end)

minetest.register_on_chat_message(function(name, message)
  if minetest.setting_getbool("language_control") == true then
    if string.match(message, "fuck") or string.match(message, "Fuck") or string.match(message, "Shit") or
    string.match(message, "shit") or string.match(message, "ass") or string.match(message, "Ass") or
    string.match(message, "bitch") or string.match(message, "Bitch") or string.match(message, "Cunt") or
    string.match(message, "cunt") or string.match(message, "Dick") or string.match(message, "dick") or
    string.match(message, "Fucker") or string.match(message, "fucker") or string.match(message, "damn") or
    string.match(message, "Damn") then
      local a = server_helper.players[name].shout
      a = a + 1
      server_helper.players[name] = {shout = a,}
      if a < 5 then
        minetest.chat_send_all("<The All Seeing Eye> Please do not use foul language.")
      elseif a >= 5 then
        minetest.kick_player(name, "You didn't stop using foul language!")
        minetest.chat_send_all(name .. " was just kicked for not following the rules.")
      end
    end
  end
end)

minetest.register_on_chat_message(function(name,message)
  if string.match(message, "cussing") or string.match(message, "cursing") or string.match(message, "bad word") or string.match(message, "swearing") then
    if minetest.setting_getbool("language_control") == true then
      minetest.chat_send_all("<The All Seeing Eye> Bad language is not acceptable.")
    end
  end
end)

minetest.register_on_chat_message(function(name,message)
  if message == "who is The All Seeing Eye" or message == "who is the all seeing eye" or message == "The All Seeing Eye?" or message == "who is The All Seeing Eye?" or message == "who is the all seeing eye?" or message == "Who is the all seeing eye?" or message == "Who is The All Seeing Eye?" then
    minetest.chat_send_all("<The All Seeing Eye> I am a server moderator created by Tmanyo.")
  end
end)

minetest.register_on_chat_message(function(name,message)
  if message == "can i be a mod" or message == "can i be a mod?" or message == "Can I be a mod?" or message == "can i be an admin" or message == "can i be an admin?" or message == "Can I be an admin?" or message == "can i have more privs" then
    minetest.chat_send_player(name, "<The All Seeing Eye> You need to ask server administration.")
  end
end)

minetest.register_on_chat_message(function(name,message)
  if string.match(message, "dumb") or string.match(message, "stupid") or string.match(message, "ugly") or string.match(message, "idiot") then
    minetest.chat_send_all("<The All Seeing Eye> Shots fired!  Those are fighting words...")
  end
end)

minetest.register_on_chat_message(function(name,message)
  if string.match(message, "favorite color") or string.match(message, "color") or string.match(message, "colour") then
    minetest.chat_send_all("<The All Seeing Eye> My favorite color is yellow.")
  end
end)

minetest.register_on_chat_message(function(name,message)
  if string.match(message, "favorite food") or string.match(message, "food") or string.match(message, "meal") then
    minetest.chat_send_all("<The All Seeing Eye> My favorite food is Chicken.")
  end
end)
