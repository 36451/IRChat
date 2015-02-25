IRChatConnection = false
IsConnected      = false
JoinedChannel    = false
HookedIntoCore   = false
Callbacks = {}

function Initialize(Plugin)
	Plugin:SetName( "IRChat" )
	Plugin:SetVersion( 4 )
	
	-- Initialize all avialable callbacks
	Callbacks["OnSendFromEndpoint"] = {}
	Callbacks["OnSendToEndpoint"]   = {}
	
	-- Register for all hooks needed
	cPluginManager:AddHook(cPluginManager.HOOK_CHAT,                  OnChat)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED,      OnPlayerDestroyed);
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_JOINED,         OnPlayerJoined)
	cPluginManager:AddHook(cPluginManager.HOOK_KILLING,               OnKilling)
	cPluginManager:AddHook(cPluginManager.HOOK_PLUGINS_LOADED,        OnPluginsLoaded);
	
	-- Load the InfoReg shared library:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	
	-- Bind all the commands:
	RegisterPluginInfoCommands();
	
	-- Bind all the console commands:
	RegisterPluginInfoConsoleCommands();
	
	LOG("[" .. Plugin:GetName() .. "] Version " .. Plugin:GetVersion() .. ", initialised")
	
	return true
end

function OnDisable()
	if IsConnected == true then
		IRCDisconnect()
	end
	LOG("[IRChat] Disabled")
end

-- Adds a callback
-- Avialable ones:
--    OnSendFromEndpoint(Endpoint, Tag, From, Message) ; Plugin will receive ALL messages passing through IRChat, including .commands from irc
--    OnSendToEndpoint(Endpoint, Tag, From, Message)   ; This callback is more suited for custom endpoints
-- One message will always generate one OnSendFromEndpoint, and anywhere from 0 to a lot of OnSendToEndpoint
-- You can return true to prevent further actions related to the invoked function
-- All callbacks are called before the processing begins, so plugins can change
-- the message, endpoint it originated from, tag or player name, 
-- (by returning values in the false, Endpoint, Tag, From, Message form - you need to specify all of them)
-- this can also be used as a notification - in that case plugins shouldn't return anything
function AddCallback(EventName, PluginName, FunctionName) 
	if EventName ~= "OnSendFromEndpoint" and EventName ~= "OnSendToEndpoint" then
		return false
	end
	for k, v in pairs(Callbacks[EventName]) do
		if v[1] == PluginName and v[2] == FunctionName then
			return false
		end
	end
	table.insert(Callbacks[EventName], {PluginName, FunctionName})
	return true
end

-- Removes a callback
function RemoveCallback(EventName, PluginName, FunctionName) 
	if EventName ~= "OnSendFromEndpoint" and EventName ~= "OnSendToEndpoint" then
		return false
	end
	for i = #Callbacks[EventName], 0, -1 do
		if Callbacks[EventName][i][1] == PluginName and Callbacks[EventName][i][2] == FunctionName then
			table.remove(Callbacks[EventName], i)
			return true
		end
	end
	return false
end


function split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function splitfrom(s, delimiter, startat)
    local result = "";
    local counter = 1
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        if counter >= startat then
			result = result .. match .. delimiter
		end
		counter = counter + 1
    end
    result = string.sub(result, 1, #result - #delimiter)
    return result
end

function splitto(s, delimiter, endat)
    local result = ""
    local counter = 1
    temp = split(s, delimiter)
    for k, v in pairs(temp) do
		if counter < ((#temp)-endat) then
			result = result .. v .. delimiter
		end
		if counter == ((#temp)-endat) then
			result = result .. v
		end
		counter = counter + 1
    end
    return result;
end

function IRCDisconnect()
	if IsConnected == false then
		LOG("[IRChat] Client isn't connected to anything!")
		return false
	end
	IRChatConnection:Send("QUIT\r\n");
	if IsConnected then
		IRChatConnection:Close()
	end
	IsConnected = false
	JoinedChannel = false
	LOG("[IRChat] Disconnected from IRC!")
	
end

function IRCConnect() 

	if IsConnected == true then
		LOG("[IRChat] Client is already connected to the server!")
		return false
	end
	
	LOG("[IRChat] Connecting to " .. Host .. ":" .. Port .. "")

	local Callbacks =
	{
		OnConnected = function (a_Link)
			IRChatConnection = a_Link
			LOG("[IRChat] Connected to " .. a_Link:GetRemoteIP() ..  ":" .. a_Link:GetRemotePort())
			if debug then
				LOG("[IRChat] Sending newline");
			end
			a_Link:Send("\r\n")
			if debug then
				LOG("[IRChat] Sending NICK")
			end
			a_Link:Send("NICK " .. BotNick .. "\r\n")
			if debug then
				LOG("[IRChat] Sending USER")
			end
			a_Link:Send("USER " .. BotNick .. " 8 * : IRChat client\r\n")
			IsConnected = true
		end,
		
		OnError = function (a_Link, a_ErrorCode, a_ErrorMsg)
			IsConnected = false
			JoinedChannel = false
			LOG("[IRChat] Connection to " .. Host .. ":" .. Port .. " failed: " .. a_ErrorCode .. " (" .. a_ErrorMsg .. ")")
		end,
		
		OnReceivedData = function (a_Link, a_Data)
			local lines = split(a_Data, "\r\n")
			for k, line in pairs(lines) do
				
				if full_debug then
					LOG(line)
				end
				
				if string.find(line, ":") == 1 then
				
					local sender = string.sub(split(line, " ")[1],2)
					local shortsender = split(sender, "!")[1]
					local command = split(line, " ")[2]
					local args = splitfrom(line, " ", 3)

					if sender ~= nil and command ~= nil then 
						
						if debug then
							LOG("[IRChat] Command(" .. sender .. "): " .. command .. " " .. args)
						end
						
						if command == "376" or command == "422" then
							if BotPassword ~= "" then
								LOG("[IRChat] Authenticating with nickserv")
								IRChatConnection:Send("PRIVMSG nickserv :identify " .. BotPassword .."\r\n")
							end
							if debug then
								LOG("[IRChat] Sending JOIN")
							end
							a_Link:Send("JOIN " .. BotChannel .. "\r\n")
						end
						
						if command == "JOIN" then
							
							if shortsender == BotNick then
								JoinedChannel = true
								LOG("[IRChat] Joined " .. split(args, " ")[1])
							else
								SendFromEndpoint(split(args, " ")[1] .. "-join", IRCTag, "", shortsender .. " has joined " .. split(args, " ")[1])
							end
							
						end
						
						if command == "PART" then
						
							if shortsender == BotNick then
								JoinedChannel = false
								if debug then
									LOG("[IRChat] Parted " .. split(args, " ")[1])
									LOG("[IRChat] Sending JOIN")
								end
								a_Link:Send("JOIN " .. split(args, " ")[1] .. "\r\n")
							else
								SendFromEndpoint(split(args, " ")[1] .. "-leave", IRCTag, "", shortsender .. " has left " .. split(args, " ")[1])
							end
						
						end
						
						if command == "QUIT" then 
							if shortsender == BotNick then
								JoinedChannel = false
							else
								SendFromEndpoint(split(args, " ")[1] .. "-leave", IRCTag, "", shortsender .. " has left " .. split(args, " ")[1])
							end
						end
						
						if command == "KICK" then
						
							if split(args, " ")[2] == BotNick then
								JoinedChannel = false
								LOG("[IRChat] Client got kicked from " .. split(args, " ")[1] .. " by " .. sender)
								if debug then
									LOG("[IRChat] Rejoining " .. split(args, " ")[1])
								end
								a_Link:Send("JOIN " .. split(args, " ")[1] .. "\r\n")
							else
								SendFromEndpoint(split(args, " ")[1] .. "-kick", IRCTag, "", split(args, " ")[2] .. " has been kicked from " .. split(args, " ")[1] .. " by " .. shortsender .. "!")
							end
							
						end
						
						if command == "PRIVMSG" then
							SendFromEndpoint(split(args, " ")[1] .. "-chat", IRCTag, shortsender, string.sub(splitfrom(args," ", 2), 2))
						end
						
						if command == "NOTICE" then
							LOG("[IRChat] (" .. shortsender .. ") " .. string.sub(splitfrom(args," ", 2), 2))
						end
						
						if command == "471" or command == "473" or command == "474" or command == "475" then
							JoinedChannel = false
							LOG("[IRChat] " .. string.sub(split(args, " :")[2], 1, #split(args, " :")[2]-1) .. ". Disconnecting!")
							IRCDisconnect()
						end
						
					end
					
				else 
				
					local command = split(line, " ")[1];
					local args = splitfrom(line, " ", 2);
					if args == nil then
						args = ""
					end
					if command ~= nil and command ~= "" then 
						if debug then
							LOG("Command(Without sender): " .. command .. " " .. args)
						end
						if command == "PING" then
							if debug then
								LOG("[IRChat] Received PING " .. args);
								LOG("[IRChat] Sending PONG " .. args);
							end
							a_Link:Send("PONG " .. args .. "\r\n")
						end
						
					end
					
				end

			end 

		end,
		
		OnRemoteClosed = function (a_Link)
			IsConnected = false
			JoinedChannel = false
			LOG("[IRChat] Connection to " .. Host .. ":" .. Port .. " was closed by the remote peer.")
		end,
		
	}

	local ret = cNetwork:Connect(Host, Port, Callbacks)
	if not ret then
		LOGWARNING("[IRChat] Connect call failed immediately")
		return true
	end
	
	return true
end

--
--Sends something from endpoint
--This can actaully be utilized by other plugins for integration with irc
--
function SendFromEndpoint(Endpoint, Tag, From, Message)
	
	if splitto(Endpoint,"-", 1) == BotNick then
		-- Fix for private messages on irc
		Endpoint = From .. "-chat"
	end
	
	for k, v in pairs(Callbacks["OnSendFromEndpoint"]) do
		local ret, rEndpoint, rTag, rFrom, rMessage = cPluginManager:CallPlugin(v[1], v[2], Endpoint, Tag, From, Message)
		if ret == true then
			return false
		end
		if ret == false then
			Endpoint = rEndpoint
			Tag = rTag
			From = rFrom
			Message = rMessage
		end
	end
	
	if string.find(Message, "%.") == 1 and splitto(Endpoint,"-", 1) ~= "in-game" and splitto(Endpoint,"-", 1) ~= "web" then
		
		local CmdResult = "Command not found."
		
		for cmd, info in pairs(g_PluginInfo.IRCCommands) do 
			if cmd == split(string.sub(Message, 2), " ")[1] then
				CmdResult = info.Handler(From, splitfrom(Message, " ", 2))
			end
		end
		
		SendToEndpoint(splitto(Endpoint,"-", 1), "", "", CmdResult)
		
		return true
		
	end
	
	for id, key in pairs(endpoints) do
		if key[1] == Endpoint then
			SendToEndpoint(key[2], Tag, From, Message)
		end
	end
	
	return true

end

function SendToEndpoint(Endpoint, Tag, From, Message)
	
	for k, v in pairs(Callbacks["OnSendToEndpoint"]) do
		local ret, rEndpoint, rTag, rFrom, rMessage = cPluginManager:CallPlugin(v[1], v[2], Endpoint, Tag, From, Message)
		if ret == true then
			-- This is kinda bad - there is no way to distinguish custom endpoint implementation from a cancelled message
			return true
		end
		if ret == false then
			Endpoint = rEndpoint
			Tag = rTag
			From = rFrom
			Message = rMessage
		end
	end
	
	-- In-game chat endpoint
	if Endpoint == "in-game" then
	
		if From == "" then
			cRoot:Get():BroadcastChat(Tag .. Message)
		else
			cRoot:Get():BroadcastChat(Tag .. "<" .. From .. "> " .. Message)
		end
		
		return true
		
	end
	
	-- Console endpoint
	if Endpoint == "console" then
	
		if From == "" then
			LOG("[IRChat] " .. Tag .. Message)
		else
			LOG("[IRChat] " .. Tag .. "<" .. From .. "> " .. Message)
		end
		
		return true
		
	end
	
	-- Webadmin chat endpoint
	if Endpoint == "web" then
		
		if HookedIntoCore == false then
			return false
		end

		if From == "" then
			cPluginManager:CallPlugin("Core", "WEBLOG", Tag .. Message)
		else
			cPluginManager:CallPlugin("Core", "WEBLOG", Tag .. "[" .. From .. "]: " .. Message)
		end
		
		return true
		
	end
	
	-- Neither of the above, must be irc
	if IsConnected == false or JoinedChannel == false then
		return false
	end
	
	-- Support for multiline messages
	local lines = split(Message, "\r\n")
	for k, line in pairs(lines) do
		if From == "" then
			IRChatConnection:Send("PRIVMSG " .. Endpoint .. " :" .. Tag .. line .."\r\n")
		else
			IRChatConnection:Send("PRIVMSG " .. Endpoint .. " :" .. Tag .."(" .. From .. ") " .. line .."\r\n")
		end
	end
		
	return true
	
end
