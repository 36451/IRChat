function HandleConsoleIrcConnect(Split, Player)
	IRCConnect()
	return true
end

function HandleConsoleIrcDisconnect(Split, Player)
	IRCDisconnect()
	return true
end

function HandleIRCPlayers(Caller, Params)
	local server = cRoot:Get():GetServer()
	if server:GetNumPlayers() == 0 then
		return "Nobody is minecrafting right now."
	end
	local ret = "Online (" .. server:GetNumPlayers() .. "/" .. server:GetMaxPlayers() .. "): "
	local getnames = function(Player)
		ret = ret .. Player:GetName() .. ","
	end
	cRoot:Get():ForEachPlayer(getnames)	
	return string.sub(ret, 1, #ret-1)
end

function HandleIRCHelp(Caller, Params)
	local ret = "~~~~ IRChat - IRC bridge for MCServer ~~~~\r\n"
	ret = ret .. "You can find more info here: goo.gl/85aqcp\r\n"
	local longest_name = 0
	for cmd, info in pairs(g_PluginInfo.IRCCommands) do 
		if #cmd > longest_name then
			longest_name = #cmd
		end
	end
	for cmd, info in pairs(g_PluginInfo.IRCCommands) do 
		ret = ret .. "." .. cmd
		local counter = #cmd 
		while counter < longest_name do
			ret = ret .. " "
			counter = counter + 1
		end
		ret = ret .. " - " .. info.HelpString .. "\r\n"
	end
	return ret
end
