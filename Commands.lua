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
