
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
	
	SendFromEndpoint("in-game-chat", "", Player:GetName(), Message)
	
	return false
	
end

function OnWebChat(Player, Message)

	if Player == nil then
		return false
	end
	
	SendFromEndpoint("web-chat-chat", WebTag, Player, Message)
	
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
