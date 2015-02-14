
-- Info.lua

-- Implements the g_PluginInfo standard plugin description

g_PluginInfo =
{
	Name = "IRChat",
	Version = "1",
	Date = "2015-02-14",
	Description = [[IRC chat bridge]],
	
	Commands =
	{
	},
	
	ConsoleCommands =
	{
		ircc =
		{
			HelpString = "Connects to the irc",
			Handler = HandleConsoleIrcConnect,
			ParameterCombinations =
			{
				{
					Params = "",
					Help = "Connects to the irc",
				},
			},
		},
		
		ircd =
		{
			HelpString = "Disconnects from the irc",
			Handler = HandleConsoleIrcDisconnect,
			ParameterCombinations =
			{
				{
					Params = "",
					Help = "Disconnects from the irc",
				},
			},
		},
		
	},
}




