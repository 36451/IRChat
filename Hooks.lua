
function OnPlayerDestroyed(Player)

	if Player == nil then
		return false
	end
	
	if IsConnected == true and JoinedChannel == true then
		IRChatConnection:Send("PRIVMSG " .. BotChannel .. " :" .. Player:GetName() .. " has left the game.\r\n")
	end
	return false
end

function OnPlayerJoined(Player)
	
	if Player == nil then
		return false
	end
	
	if IsConnected == true and JoinedChannel == true then
		IRChatConnection:Send("PRIVMSG " .. BotChannel .. " :" .. Player:GetName() .. " has joined the game.\r\n")
	end
	return false
end

function OnChat(Player, Message)

	if Player == nil then
		return false
	end
	
	if IsConnected == true and JoinedChannel == true then
		IRChatConnection:Send("PRIVMSG " .. BotChannel .. " :(" .. Player:GetName() .. ") " .. Message .. "\r\n")
	end
	return false
end

function OnKilling(Victim, Killer)

	if Victim == nil then
		return false
	end
	
	if Victim:IsPlayer() == false then
		return false
	end
	
	if IsConnected == true and JoinedChannel == true then
		if Killer == nil then
			IRChatConnection:Send("PRIVMSG " .. BotChannel .. " :" .. Victim:GetName() .. " died.\r\n")
		else
			IRChatConnection:Send("PRIVMSG " .. BotChannel .. " :" .. Victim:GetName() .. " has been killed by " .. Killer:GetName() .. ".\r\n")
		end
	end
	return false
end
