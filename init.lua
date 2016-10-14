server_helper = {
	players = {}
}

if minetest.setting_getbool("language_control") == nil then
	-- Set up default configuration
	dofile(minetest.get_modpath("server_helper").."/config.lua")
end

server_helper.callbacks = {
	--[[
	{	-- Each of these keys in the table can be nil when not used (except keywords)
		keywords  = {"word1", "word2", ...},
		answer    = {[send to everybody?], "Answer to player @1."},
		setting   = "foo_enabled",
		use_string_match = true,
		-- ^ Uses string.match to compare
		compare_full_text = true,
		-- ^ Compares with the whole message
		--   overrides 'use_string_match'
		callback  = function(name)
			do_something()
			...
			return [send to everybody?], "Return text"
		end
		-- ^ Gets called when one of the keywords matches
		--   Overrides 'answer'
	},
	]]
	{
		keywords = {"gender", "sex", "male", "female", "location", "u live", "you live", "girlfriend", "boyfriend"},
		answer   = {false, "Maybe you shouldn't talk about that @1."}
	},
	{
		keywords = {"%p%p%p%p%p%p"},
		answer   = {false, "Please do not go over-board with punctuation."},
		setting  = "punctuation_control"
	},
	{
		-- Can be turned on and off using the time_change setting in config.lua.
		keywords = {"can we have day", "day please", "please have day"},
		setting  = "time_change",
		callback = function(name)
			minetest.set_timeofday(.3)
			return true, "It is now day!"
		end
	},
	{
		keywords = {"can we have night", "night please", "please have night"},
		setting  = "time_change",
		callback = function(name)
			minetest.set_timeofday(0)
			return true, "It is now night!"
		end
	},
	{
		keywords = {"i am stuck", "i'm stuck", "im stuck", "help stuck"},
		callback = function(name)
			server_helper.players[name].respawn = 1
			return false, "Would you like me to teleport you to spawn?"
		end
	},
	{
		keywords = {"hi", "hello", "hola", "howdy"},
		answer   = {true, "Hello @1."},
		compare_full_text = true
	},
	-- These watch for certain keywords or phrases and make a response.
	{
		keywords = {"the all seeing eye"},
		answer   = {true, "What do you need?"},
		compare_full_text = true
	},
	{
		keywords = {"grief"},
		answer   = {false, "Griefing is not permitted and will not be allowed!"},
		use_string_match = true,
	},
	{
		keywords = {"fuck", "shit", "bitch", "cunt", "dick"},
		setting  = "language_control",
		callback = function(name)
			local player = server_helper.players[name]
			player.shout = player.shout + 2
			if player.shout <= 6 then
				return true, "Please do not use foul language."
			end
			minetest.kick_player(name, "You didn't stop using foul language!")
			minetest.chat_send_all(name .. " was just kicked for not following the rules.")
		end
	},
	{
		keywords = {"cussing", "cursing", "bad word", "swearing"},
		answer   = {false, "Bad language is not acceptable."},
		setting  = "language_control",
	},
	{
		keywords  = {"who is the all seeing eye"},
		answer    = {true, "I am a server moderator created by Tmanyo."}
	},
	{
		keywords  = {"can i be mod", "can i be admin", "can i be a mod", "can i be an admin", "can i have more privs"},
		answer    = {true, "You need to ask server administration."}
	},
	{
		keywords  = {"dumb", "stupid", "ugly", "idiot"},
		answer    = {true, "Shots fired!  Those are fighting words..."}
	}
}

minetest.register_on_chat_message(function(name, message)
	message = message:lower()
	for i, info in pairs(server_helper.callbacks) do
		if not info.setting
				or minetest.setting_getbool(info.setting) == true then
			local matches
			for j, keyword in pairs(info.keywords) do
				if info.compare_full_text then
					matches = keyword == message
				elseif info.use_string_match then
					matches = message:match(keyword)
				else
					matches = message:find(keyword)
				end
				if matches then break end
			end
			local broadcast, message
			if matches and info.callback then
				broadcast, message = info.callback(name)
			elseif matches and info.answer then
				broadcast = info.answer[1]
				message   = info.answer[2]
			end
			-- Message stays 'nil' when no keyword matched
			if message then
				message = message:gsub("@1", name)
				if broadcast then
					minetest.chat_send_all("<The All Seeing Eye> " .. message)
				else
					minetest.chat_send_player(name, "<The All Seeing Eye> " .. message)
				end
			end
			if matches then
				break -- Already answered to the current message
			end
		end
	end
end)

minetest.register_on_chat_message(function(name, message)
	if minetest.setting_getbool("cap_usage") ~= true then
		return
	end

	if message:match("%u%u%u%u")
			or message:match("%u%u%u %u")
			or message:match("%u %u%u%u")
			or message:match("u%l%u%l%u") then

		local player = server_helper.players[name]
		player.shout = player.shout + 1

		if player.shout < 5 then
			minetest.chat_send_player(name, "<The All Seeing Eye> Please refrain from using all caps.")
			return
		end
		minetest.kick_player(name, "You were told to stop and you didn't.")
		minetest.chat_send_all(name .. " was just kicked for not following the rules.")
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	server_helper.players[name] = {
		shout = 0,
		location = 0,
		respawn = 0
	}
end)

-- This will ask you if you want to teleport to spawn if you are stuck.
minetest.register_on_chat_message(function(name, message)
	local player = server_helper.players[name]
	if not player or player.respawn ~= 1 then
		return
	end

	message = message:lower()
	if message == "no" then
		minetest.chat_send_player(name, "<The All Seeing Eye> Ok.")
		player.respawn = 0
	elseif message == "yes" then
		local pos = minetest.setting_get_pos("static_spawnpoint") or {x=0,y=0,z=0}
		local player = minetest.get_player_by_name(name)
		player:setpos(pos)
		minetest.chat_send_player(name, "<The All Seeing Eye> There you are!")
		player.respawn = 0
	end
end)

-- If you die in singleplayer you are given an option to teleport to your bones.
minetest.register_on_dieplayer(function(player)
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
      else
      end
    end)
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
