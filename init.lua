server_helper = {
players = {}
}

dofile(minetest.get_modpath("server_helper").."/config.lua")

minetest.setting_set("no_messages", "false")

minetest.register_on_chat_message(function(name,message)
     if string.match(message, "gender") or string.match(message, "sex") or string.match(message, "male") or
     string.match(message, "female") or string.match(message, "location") or string.match(message, "u live") or
     string.match(message, "you live") or string.match(message, "girlfriend") or string.match(message, "boyfriend") or
     string.match(message, "family") or string.match(message, "how old") or string.match(message, "old?")  then
          minetest.chat_send_player(name, "<The All Seeing Eye> Maybe you shouldn't talk about that " .. name .. ".")
     end
end)

minetest.register_on_chat_message(function(name,message)
     if minetest.setting_getbool("punctuation_control") == true then
          if string.match(message, "%p%p%p%p%p%p") then
               minetest.chat_send_player(name, "<The All Seeing Eye> Please do not go over-board with punctuation.")
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
     server_helper.players[name] = {shout = 0, location = 0,}
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
                    minetest.chat_send_player(name, "<The All Seeing Eye> Please refrain from using all caps.")
               elseif a >= 5 then
                    minetest.kick_player(name, "You were told to stop and you didn't.")
                    minetest.chat_send_all(name .. " was just kicked for not following the rules.")
               end
          end
     end
end)

-- This will ask you if you want to teleport to spawn if you are stuck.
local respawn = 0
minetest.register_on_chat_message(function(name,message)
     local same_name = minetest.get_player_by_name(name)
     if message == "I am stuck." or message == "I'm stuck." or message == "im stuck" or message == "Help I am stuck." or
     message == "help i am stuck" or message == "help stuck" or message == "help im stuck" or message == "i am stuck" or
     message == "I am stuck" or message == "Help I'm stuck" or message == "stuck" then
          minetest.chat_send_player(name, "<The All Seeing Eye> Would you like me to teleport you to spawn?")
          local respawn = 1
          minetest.register_on_chat_message(function(name,message)
               local next_name = minetest.get_player_by_name(name)
               if message == "no" or message == "No" then
                    if respawn == 1 and next_name == same_name then
                         minetest.chat_send_player(name, "<The All Seeing Eye> Ok.")
                         respawn = 0
                    end
               elseif message == "yes" or message == "Yes" then
                    if respawn == 1 and next_name == same_name then
                         local pos = minetest.setting_get_pos("static_spawnpoint")
                         if pos == nil then
                              local pos = {x=0,y=0,z=0}
                         end
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
minetest.register_on_dieplayer(function(player)
     if minetest.setting_getbool("bones_teleport") == true then
          local name = player:get_player_name()
          local dead_name = player:get_player_name()
          local pos = vector.round(player:getpos())
          local question = 0
          server_helper.players[name].location = pos,
          minetest.chat_send_player(player:get_player_name(),"<The All Seeing Eye> Would you like me to teleport you to your bones? (Yes/No)")
          question = 1
          print (name)
          print (dead_name)
          minetest.register_on_chat_message(function(name,message)
               print (name)
               print (dead_name)
               if message == "no"  or message == "No" then
                    if question == 1 and dead_name == name then
                         minetest.chat_send_player(name, "<The All Seeing Eye> Ok.")
                         question = 0
                    end
               elseif message == "yes" or message == "Yes" then
                    if question == 1 and dead_name == name  then
                         local playername = player:get_player_name(player)
                         local pos = server_helper.players[name].location
                         player:setpos(pos)
                         minetest.chat_send_player(name, "<The All Seeing Eye> There you are!")
                         question = 0
                    end
               end
          end)
     end
end)

minetest.register_on_chat_message(function(name,message)
     if message == "Hi" or message == "hi" or message == "hello" or message == "Hello" or
     message == "Hola" or message == "hola" or message == "howdy" or message == "Howdy" or
     message == "Hoy" or message == "hoy" then
          minetest.chat_send_player(name, "<The All Seeing Eye> Hello "..name..".")
     end
end)

local myname = "The All Seeing Eye"
local myname2 = "the all seeing eye"
minetest.register_on_chat_message(function(name,message)
     if string.match(message, myname) then
          minetest.chat_send_player(name, "<The All Seeing Eye> What do you need?")
     end
     if string.match(message, myname2) then
          minetest.chat_send_player(name, "<The All Seeing Eye> What do you need?")
     end
end)

-- These watch for certain keywords or phrases and make a response.
minetest.register_on_chat_message(function(name,message)
     if string.match(message, "grief" or "griefing" or "griefed") then
          minetest.chat_send_player(name, "<The All Seeing Eye> Griefing is not permitted and will not be allowed!")
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
                    minetest.chat_send_player(name, "<The All Seeing Eye> Please do not use foul language.")
               elseif a >= 5 then
                    minetest.kick_player(name, "You didn't stop using foul language!")
                    minetest.chat_send_all(name .. " was just kicked for not following the rules.")
               end
          end
     end
end)

minetest.register_on_chat_message(function(name,message)
     if minetest.setting_getbool("no_messages") == false then
          if string.match(message, "cussing") or string.match(message, "cursing") or string.match(message, "bad word") or string.match(message, "swearing") then
               if minetest.setting_getbool("language_control") == true then
                    minetest.chat_send_player(name, "<The All Seeing Eye> Bad language is not acceptable.")
               end
          end
     end
end)

minetest.register_on_chat_message(function(name,message)
     if minetest.setting_getbool("no_messages") == false then
          if message == "who is The All Seeing Eye" or message == "who is the all seeing eye" or message == "The All Seeing Eye?" or message == "who is The All Seeing Eye?" or message == "who is the all seeing eye?" or message == "Who is the all seeing eye?" or message == "Who is The All Seeing Eye?" then
               minetest.chat_send_player(name, "<The All Seeing Eye> I am a server moderator created by Tmanyo.")
          end
     end
end)

minetest.register_on_chat_message(function(name,message)
     if minetest.setting_getbool("no_messages") == false then
          if message == "can i be a mod" or message == "can i be a mod?" or message == "Can I be a mod?" or message == "can i be an admin" or message == "can i be an admin?" or message == "Can I be an admin?" or message == "can i have more privs" then
               minetest.chat_send_player(name, "<The All Seeing Eye> You need to ask server administration.")
          end
     end
end)

minetest.register_on_chat_message(function(name,message)
     if minetest.setting_getbool("no_messages") == false then
          if string.match(message, "dumb") or string.match(message, "stupid") or string.match(message, "ugly") or string.match(message, "idiot") then
               minetest.chat_send_player(name, "<The All Seeing Eye> Shots fired!  Those are fighting words...")
          end
     end
end)

minetest.register_chatcommand("people", {
  func = function(name, param)
		local people = ""
		  for i, player in ipairs(minetest.get_connected_players()) do
			  local name = player:get_player_name()
			  if i < #minetest.get_connected_players() then
				  people = people..name..", "
			  else
				  people = people..name
			  end
		  end
    minetest.show_formspec(name, "server_helper:peeps",
			"size[7,7]" ..
			"label[0,0;Connected players:]" ..
			"table[.5,.5;6,6;player_list;" .. people .."]"..
			"button_exit[.5,6.5;2,1;exit;Close]")
  end
})

minetest.register_privilege("no_server_helper", {
     description = "Allow trust worthy players option to not listen to server helper.",
     give_to_singleplayer = false,
})

minetest.register_chatcommand("options", {
     privs = {
          no_server_helper = true
     },
     func = function(name, param)
          minetest.show_formspec(name, "server_helper:options",
               "size[4,4]" ..
               "field[.5,1;3,1;question;The All Seeing Eye messages?(Y/N); ]" ..
               "button_exit[1,3;2,1;exit;Apply]")
     end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
     if formname == "server_helper:options" then
          local player = player:get_player_name()
          if fields.question == "y" or fields.question == "Y" then
               player:get_player_name() = minetest.setting_set("no_messages", "false")
          elseif fields.question == "n" or fields.question == "N" then
               player:get_player_name() = minetest.setting_set("no_messages", "true")
          end
     end
end)
