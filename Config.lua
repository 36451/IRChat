--
--Simple settings
--

AutoConnect = true

Host        = "CHANGEME (Plugins/IRChat/Config.lua) "

Port        = 6667

BotNick     = "IRChat"

BotPassword = ""

--
--You Can specify more than one channel after a comma, 
--("#Channel1,#Channel2,#Channel3")
--but you'll have to change BotChannel in the endpoints
--table to the channels data should be relayed to / from
--
BotChannel  = "#ChangeMe"

--
--This is the text added before every 
--message from irc is displayed in-game
--
IRCTag      = "[IRC] "

--
-- By Default, You don't need to change this
-- Hovewer, if you want to customize the bot
-- It's possible to do quite a lot with this 
-- Even Channel to Channel irc bridges!
--
--            {"From"    ,  "To"},        --
endpoints   = {
{BotChannel .. "-chat"   ,  "in-game"},
{BotChannel .. "-kick"   ,  "in-game"},
{BotChannel .. "-join"   ,  "in-game"},
{BotChannel .. "-leave"  ,  "in-game"},
{"in-game-chat"          ,  BotChannel},
{"in-game-join"          ,  BotChannel},
{"in-game-leave"         ,  BotChannel},
{"in-game-death"         ,  BotChannel},
}

--Unless You have errors, don't change these:
--If You do, in most cases you want to only
--enable debug, not full_debug
debug       = false
full_debug  = false
