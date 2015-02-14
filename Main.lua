IRChatConnection = 0
IsConnected = false
JoinedChannel = false
firstmode = 0

function Initialize(Plugin)
	Plugin:SetName( "IRChat" )
	Plugin:SetVersion( 1 )

	-- Register for all hooks needed
	cPluginManager:AddHook(cPluginManager.HOOK_CHAT,                  OnChat)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED,      OnPlayerDestroyed);
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_JOINED,         OnPlayerJoined)
	cPluginManager:AddHook(cPluginManager.HOOK_KILLING,               OnKilling)
	
	-- Bind ingame commands:
	
	-- Load the InfoReg shared library:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	
	-- Bind all the commands:
	RegisterPluginInfoCommands();
	
	-- Bind all the console commands:
	RegisterPluginInfoConsoleCommands();

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	if AutoConnectAfterStartup == true then
		IRCConnect()
	end
	return true
end

function OnDisable()
	if IsConnected == true then
		IRChatConnection:Close()
	end
	LOG( "Disabled IRChat!" )
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function splitfrom(s, delimiter, startat)
    result = "";
    local counter = 1
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        if counter >= startat then
			result = result .. match .. delimiter
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
	
	firstmode = 0

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
						
						if command == "MODE" then
							
							if firstmode == 0 then
							
								if BotPassword ~= "" then
									LOG("[IRChat] Authenticating with nickserv")
									a_Link:Send("PRIVMSG nickserv :identify " .. BotPassword .. "\r\n")
								end
								if debug then
									LOG("[IRChat] Sending JOIN")
								end
								a_Link:Send("JOIN " .. BotChannel .. "\r\n")
								firstmode = 1 
							
							end
							
						end
						
						if command == "JOIN" then
							
							if shortsender == BotNick then
								JoinedChannel = true
								LOG("[IRChat] Joined " .. BotChannel)
							else
								cRoot:Get():BroadcastChat(IRCTag .. shortsender .. " has joined " .. BotChannel)
							end
							
						end
						
						if command == "PART" or command == "QUIT" then
						
							if shortsender == BotNick then
								JoinedChannel = false
								if debug then
									LOG("[IRChat] Parted " .. BotChannel)
									LOG("[IRChat] Sending JOIN")
								end
								a_Link:Send("JOIN " .. BotChannel .. "\r\n")
							else
								cRoot:Get():BroadcastChat(IRCTag .. shortsender .. " has left " .. BotChannel)
							end
						
						end
						
						if command == "KICK" then
						
							if split(args, " ")[2] == BotNick then
								JoinedChannel = false
								LOG("[IRChat] Client got kicked from " .. BotChannel .. " by " .. sender)
								LOG("[IRChat] Rejoining " .. BotChannel)
								if debug then
									LOG("[IRChat] Sending JOIN")
								end
								a_Link:Send("JOIN " .. BotChannel .. "\r\n")
							else
								cRoot:Get():BroadcastChat(IRCTag .. split(args, " ")[2] .. " has been kicked from " .. BotChannel .. " by " .. shortsender .. "!")
							end
							
						end
						
						if command == "PRIVMSG" then
							--LOG("(" .. shortsender .. ") " .. string.sub(splitfrom(args," ", 2), 2))
							cRoot:Get():BroadcastChat(IRCTag .. "<" .. shortsender .. "> " .. string.sub(splitfrom(args," ", 2), 2))
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
