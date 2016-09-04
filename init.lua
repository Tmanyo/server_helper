dofile(minetest.get_modpath("server_helper").."/config.lua")

-- This watches for all caps usage and warns 4 times and kicks on the 5th.
local a = 1
minetest.register_on_chat_message(function(name,message)
    if string.match(message, "%u%u%u%u") then
      if minetest.setting_getbool("cap_usage") == true then
      a = a + 1
        if a < 6 then
          minetest.chat_send_all("<The All Seeing Eye> Please refrain from using all caps.")
        elseif a >= 6 then
          minetest.kick_player(name, "You were told to stop and you didn't.")
          a = 0
        end
      end
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

local chance = 1
minetest.register_on_chat_message(function(name, message)
  if string.match(message, "fuck") or string.match(message, "Fuck") or string.match(message, "Shit") or
  string.match(message, "shit") or string.match(message, "ass") or string.match(message, "Ass") or
  string.match(message, "bitch") or string.match(message, "Bitch") or string.match(message, "Cunt") or
  string.match(message, "cunt") or string.match(message, "Dick") or string.match(message, "dick") or
  string.match(message, "Fucker") or string.match(message, "fucker") or string.match(message, "damn") or
  string.match(message, "Damn") then
    if minetest.setting_getbool("language_control") == true then
      chance = chance + 1
      if chance < 6 then
        minetest.chat_send_all("<The All Seeing Eye> Please do not use foul language.")
      elseif chance >= 6 then
        minetest.kick_player(name, "You didn't stop using foul language!")
        chance = 0
      end
    end
  end
end)

minetest.register_on_chat_message(function(name,message)
  if string.match(message, "cussing") or string.match(message, "cursing") or string.match(message, "bad word") then
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
