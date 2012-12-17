function love.conf(t)
    t.title = "Fisticuffs" -- The title of the window the game is in (string)
    t.author = "SiENcE"       -- The author of the game (string)
    t.url = "http://crankgaming.blogspot.com/" -- The website of the game (string)
    t.identity = "fisticuffs"   -- The name of the save directory (string)
    t.version = "0.8.0"         -- The LÖVE version this game was made for (string)
	t.screen.width = 800
	t.screen.height = 600
	t.screen.fullscreen = false
	t.screen.vsync = true
	t.screen.fsaa = 0
	t.modules.joystick = false
	t.modules.physics = false
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = true
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.console = false
end
