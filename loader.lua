--
local config = {
	--first load order, these are processed and loaded first
	{
		--include your loader from autorun or wherever you want to load it from
		--make sure it is marked for AddCSLuaFile by setting it to download in here
		--the key is loader because this file is named loader.lua
		loader = "download",
		
		some_client_script = "client",
		some_shared_script = "shared",
		
		--a folder named dictionaries
		dictionaries = {
			--we want download when the client needs to include the script, but we load it from somewhere other than here
			en_us = "download",
			fr_ca = "download",
			pt_br = "download",
		},
		
		--a folder named early_loaded_scripts which is placed next to this file
		early_loaded_scripts = {
			--files named server, client, shared, stream, and compatibility
			client = true, --same as "client"
			compat = "server single",
			server = true, --same as "server"
			shared = true, --same as "shared"
			stream = "shared",
		},
	},
	
	--second load order, as you guessed, these are loaded after everything above
	{
		
	},
	
	--you can have more load orders, but you should understand this script by now
	--please leave the link to this script if you use it, this lets others use the most updated version
}

local branding = "Some Unique Addon Name"
local color = Color(166, 226, 46)
local color_generic = Color(240, 240, 240)

do --do not touch
	--locals
	local block_developer = not GetConVar("developer"):GetBool()
	local global = _G[CryotheumsLoader .. "_" .. branding] or {}
	local hook_name = "CryotheumsLoader" .. branding
	local include_list = {}
	
	--local tables
	local load_methods = SERVER and {
		client = AddCSLuaFile,
		download = AddCSLuaFile,
		server = true,
		
		shared = function(script)
			AddCSLuaFile(script)
			
			return true
		end
	} or {client = true, shared = true}
	
	local word_methods = { --return true to block the script
		dedicated = not game.IsDedicated(),
		developer = block_developer,
		hosted = not game.IsDedicated() and game.SinglePlayer(),
		if_global = function(_words, _script, global_name) return _G[global_name] == nil end,
		ignore = true,
		listen = game.IsDedicated() or game.SinglePlayer(),
		no_global = function(_words, _script, global_name) return _G[global_name] ~= nil end,
		simple = game.IsDedicated(),
		single = not game.SinglePlayer(),
		
		await = function(_words, script, hook_event)
			if CryotheumsLoaderHookHistory[hook_event] then return true end
			
			local scripts = include_list_await[hook_event]
			
			return false
		end,
		
		hook = function(_words, script, hook_event)
			
			
			return true
		end,
		
		world = function(_words, script)
			if CryotheumsLoaderHookHistory then return false end
			
			local world_hooks = include_list_hooked.InitPostEntity
			
			if world_hooks then table.insert(world_hooks, script)
			else include_list_hooked.InitPostEntity = {script} end
			
			return true
		end,
	}
	
	--local functions
	local function check_words(words, script)
		for index, raw_word in ipairs(words) do
			local word_parts = string.Split(raw_word, ":")
			local word = table.remove(word_parts, 1)
			local word_method = word_methods[word] or nil
			
			if word_method and (word_method == true or word_method(words, script, unpack(word_parts))) then return false end
		end
		
		return true
	end
	
	local function build_list(include_list, prefix, tree) --recursively explores to build load order
		for name, object in pairs(tree) do
			local trimmed_path = prefix .. name
			
			if istable(object) then build_list(include_list, trimmed_path .. "/", object)
			elseif object then
				local words = isstring(object) and string.Split(object, " ") or {name}
				local script = trimmed_path .. ".lua"
				local word = table.remove(words, 1)
				local load_method = load_methods[word]
				
				if load_method and (load_method == true or load_method(script)) and check_words(words, script) then table.insert(include_list, script) end
			end
		end
	end
	
	local function load_scripts(include_list, late)
		if GM then MsgC(color, "\nLoading " .. branding .. " (Gamemode) scripts...\n")
		else MsgC(color, "\nLoading " .. branding .. " scripts...\n") end
		
		if late then MsgC(color_generic, "This late load is running in the " .. (SERVER and "SERVER" or "CLIENT") .. " realm.\n")
		else MsgC(color_generic, "This load is running in the " .. (SERVER and "SERVER" or "CLIENT") .. " realm.\n") end
		
		for index, script in ipairs(include_list) do
			MsgC(color_generic, "\t" .. index .. ": " .. script .. "\n")
			include(script)
		end
		
		if not late and include_list_late[1] then MsgC(color, GM and "Initial Gamemode load concluded; a late load will follow." or "Initial load concluded; a late load will follow.")
		else MsgC(color, GM and "Gamemode load concluded." or "Load concluded.") end
		
		MsgC("\n\n")
	end
	
	--globals
	CryotheumsLoaderHookHistory = CryotheumsLoaderHookHistory or {}
	_G[CryotheumsLoader .. "_" .. branding] = global
	
	--build the load order
	for priority, tree in ipairs(config) do build_list(include_list, "", tree) end
	
	load_scripts(include_list, false)
	
	--create a hook if we need late loading
	if include_list_late[1] then hook.Add("InitPostEntity", branding .. "LateLoader", function() load_scripts(include_list_late, true) end) end
end