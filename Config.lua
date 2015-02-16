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
--message from irc/webchat is displayed
--
IRCTag      = "[IRC] "
WebTag      = "[WEB] "

--
-- By Default, You don't need to change anything
-- below this. Hovewer, if you want to customize 
-- the bot, it's possible to do quite a lot with
-- endpoints. Even Channel to Channel irc bridges!
--
-- Avialable endpoints:
--    + in-game  - minecraft chat
--    + web      - webadmin chat
--    + console  - server console
--    + anything that can be send to on irc, be it a channel,
--      service or user - just enter the name!
--
-- Avialable sources:
--    + in-game-chat/join/leave/death - events from the server
--    + web-chat                      - messages from webadmin chat
--    + anything that can send you messages on irc 
--      (#something-chat, UserName-chat, source in this case is "endpoint-chat"
--      with the exception for channels, these have join/leave/kick too)
--
endpoints   = {
--{"From"                ,  "To"      },
--          IRC -> Minecraft          --
{BotChannel .. "-chat"   ,  "in-game" },
{BotChannel .. "-kick"   ,  "in-game" },
{BotChannel .. "-join"   ,  "in-game" },
{BotChannel .. "-leave"  ,  "in-game" },
--          Minecraft -> IRC          --
{"in-game-chat"          ,  BotChannel},
{"in-game-join"          ,  BotChannel},
{"in-game-leave"         ,  BotChannel},
{"in-game-death"         ,  BotChannel},
--          IRC -> Web chat           --
{BotChannel .. "-chat"   ,  "web"     },
{BotChannel .. "-kick"   ,  "web"     },
{BotChannel .. "-join"   ,  "web"     },
{BotChannel .. "-leave"  ,  "web"     },
--          Web chat -> IRC           --
{"web-chat"              ,  BotChannel},
--          NickServ -> Console       --
{"nickserv-chat"         ,  "console" },
}


--Unless You have errors, don't change these:
--If You do, in most cases you want to only
--enable debug, not full_debug
debug       = false
full_debug  = false
