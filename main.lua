PLUMINO_VERSION = {0, 0, 3}

modeNames = {
    "marathon",
    "sprint",
    "ionlysprint",
    "sinemarathon",
    "testmode"
}
-- EDIT THIS TABLE TO LOAD MORE MODES.

rotationSystems = {
    "ars",
    "srs",
    "flashlight",
    "incremental"
}
-- EDIT THIS TABLE TO LOAD ROTATION SYSTEMS.

randomisers = {
    "tgm",
    "onlyi"
}
-- EDIT THIS TABLE TO LOAD RANDOMISERS.

piece = {}

require "util"
inspect = require "lib/inspect"
require "game"
require "stuff/ui"

local libstatus, liberr = pcall(function() discord = require "lib/discordRPC" end)

if libstatus then
    discord = require "lib/discordRPC"
else
    print("[WARNING!] Could not load Discord rich presence: "..liberr)
    print("[WARNING!] This is normal if using the .love file.")
end
local presence = {}

function updatePresence(p)
    presence = p
    nextPresence = 0
end

local nextPresence = 0

game.font = {
    big = love.graphics.newFont("assets/font/standard.ttf", 36),
    std = love.graphics.newFont("assets/font/standard.ttf", 14),
    med = love.graphics.newFont("assets/font/standard.ttf", 20),
    med2 = love.graphics.newFont("assets/font/standard.ttf", 24),
    med3 = love.graphics.newFont("assets/font/standard.ttf", 26)
}

game.gfx = {
    intro = "arikek.png",
    title = "title.png",
    mino = "mino16.png",
    dev = "dev.png",
    poweredby = "poweredby.png"
}

game.background = {
    "bg1.png"
}

game.bgm = {
    "bgm1.ogg"
}

modes = {}
rotations = {}
randomiser = {}

game.sfx = {
    ready = "ready.wav",
    go = "go.wav",
    credit = "credit.wav"
}

screen = love.graphics.newCanvas() -- testing this
screenX = 0
screenY = 0
screenCol = {1, 1, 1, 1}

function game:switchState(name, args)
    if not game.states[name] then
        error("Could not switch to state "..name)
    end
    if game.state and game.state.stop then
        game.state:stop()
    end
    game.stateName = name
    game.state = game.states[name]
    if game.state.init then
        game.state:init(args)
    end

    -- RESET THE SCREEN VARIABLES
    screenX = 0
    screenY = 0
    screenCol = {1, 1, 1, 1}

    love.window.setTitle("Plumino 2: "..name)
end

local files = {
    "game",
    "menu",
    "splash"
}

function love.load()
    discord.initialize("585884186188054535", true) -- DISCORD RICH PRESENCE

    for _, i in pairs(files) do -- handle state loading
        require("./states/"..i)
    end

    for _, i in pairs(modeNames) do -- handle mode loading
        modes[i] = require("./mode/"..i)
    end

    for _, i in pairs(rotationSystems) do -- handle rotsys loading
        require("./rotsys/"..i)
    end

    for _, i in pairs(randomisers) do -- handle randomiser loading
        require("./randomiser/"..i)
    end

    for p, f in pairs(game.gfx) do -- handle gfx loading
        game.gfx[p] = love.graphics.newImage("assets/gfx/"..f)
    end

    for p, f in ipairs(game.background) do -- handle gfx loading
        game.background[p] = love.graphics.newImage("assets/bg/"..f)
    end

    for p, f in pairs(game.sfx) do -- handle sfx loading
        game.sfx[p] = love.audio.newSource("assets/sfx/"..f, "static")
    end

    if love.filesystem.getInfo("assets/bgm", "directory") then
        for p, f in ipairs(game.bgm) do -- handle bgm loading
            game.bgm[p] = love.audio.newSource("assets/bgm/"..f, "stream")
            game.bgm[p]:setLooping(true)
        end
    end

    game:switchState("splash")
end

function love.update(dt)
    game:checkJustPressed()

    if game.state and game.state.update then
        game.state:update(dt)
    end

    if game.mode and game.mode.getPresenceText then
        presence.largeImageText = game.mode:getPresenceText()
    end

    if nextPresence < love.timer.getTime() then
        discord.updatePresence(presence)
        nextPresence = love.timer.getTime() + 2.0
    end
    discord.runCallbacks()
end

function love.quit()
    discord.shutdown()
end

function discord.ready(uid, uname, discrim, avy)
    print(string.format("[Discord RPC] Ready! Logged in as %s#%s (%s).", uname, discrim, uid))
end

function love.draw()
    love.graphics.setCanvas(screen)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")

    if game.state and game.state.draw then
        game.state:draw()
    end

    love.graphics.setFont(game.font.med)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(love.timer.getFPS()).." FPS", 0, 0)

    love.graphics.setCanvas()
    love.graphics.setColor(unpack(screenCol))
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(screen, screenX, screenY)
end

function love.keypressed(k, sc, r)
    game:keyDown(k, sc, r)
    if game.state and game.state.keyDown then
        game.state:keyDown(k, sc, r)
    end
    game:doInput()
end

function love.keyreleased(k, sc, r)
    game:keyUp(k, sc, r)
    if game.state and game.state.keyUp then
        game.state:keyUp(k, sc, r)
    end
end