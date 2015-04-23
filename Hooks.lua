function HookingError(PluginName, ErrorCode, ErrorDesc, ErrorResult)
	LOGINFO("[IRChat] Couldn't hook into " .. PluginName)
	LOGINFO("[IRChat] Error " .. ErrorCode .. ": " .. ErrorDesc)
	LOGINFO("[IRChat] " .. ErrorResult)
end

function OnPluginsLoaded() 
	-- Hook into Core's webchat callback
	if cPluginManager:Get():IsPluginLoaded("Core") then
		cPluginManager:Get():ForEachPlugin(
			function (PluginHandle)
				if PluginHandle:GetName() == "Core" then
					if PluginHandle:GetStatus() == cRoot:Get():GetPluginManager().psLoaded then
						if PluginHandle:GetVersion() >= 15 then
							if cPluginManager:CallPlugin("Core", "AddWebChatCallback", "IRChat", "OnWebChat") == true then
								HookedIntoCore = true
								LOG("[IRChat] Hooked into Core")
							else 
								HookingError("Core", 1, "CallPlugin didn't return true", "Web endpoint will be unavialable")
							end
						else
							HookingError("Core", 2, "Your Core is outdated, the minimum version is 15", "Web endpoint will be unavialable")
						end
					else
						HookingError("Core", 3, "Core not loaded", "Web endpoint will be unavialable")
					end
				end
			end
		)
	else
		HookingError("Core", 4, "Core not found", "Web endpoint will be unavialable")
	end	
	-- Auto connect on startup if enabled
	if AutoConnect == true then
		IRCConnect()
	end
end

function OnPlayerDestroyed(Player)
	if Player == nil then
		return false
	end
	SendFromEndpoint("in-game-leave", "", "", Player:GetName() .." has left the game.")
	return false	
end

function OnPlayerJoined(Player)
	if Player == nil then
		return false
	end
	SendFromEndpoint("in-game-join", "", "", Player:GetName() .. " has joined the game.")	
	return false
end

function OnChat(Player, Message)
	if Player == nil then
		return false
	end
	SendFromEndpoint("in-game-chat", "", Player:GetName(), Message)
	return false
end

function OnWebChat(Player, Message)
	SendFromEndpoint("web-chat", WebTag, Player, Message)	
	return false
end

function OnKilling(Victim, Killer)
	if Victim == nil then
		return false
	end
	if Victim:IsPlayer() == false then
		return false
	end
	if Killer == nil then
		SendFromEndpoint("in-game-death", "", "", Victim:GetName() .. " died.")
	else
		SendFromEndpoint("in-game-death", "", "", Victim:GetName() .. " has been killed by " .. Killer:GetName() .. ".")
	end
	return false	
end
