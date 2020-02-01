local inspect = require "lib/inspect"

return {
    init = function(self, arg)
        game:loadReplay(arg[1])
        self.quitAfterPlaying = arg[2]

        self.rpArg = arg

        -- READY. GO.
        self.readyGoText = "Ready"
        self.readyGoCountdown = 0
        self.drawingReadyGo = true
        self.readyGoStage = 1
        self.readyGoSound = {game.sfx.ready, game.sfx.go}
        for _, j in ipairs(self.readyGoSound) do j:setVolume(0.8) end

        -- game over
        self.gameovertimer = 10
        self.drawgameover = false
        self.blankfield = true
        self.gameoverframes = 0
        self.blankstage = 20+game.invisrows
        self.gameoverspeed = 10

        self.overrideMatrix = false
        self.invis = false
        self.pausetimer = false

        self.currentbgm = nil

        function self:playBGM(t)
            if type(t) ~= "string" then
                self.currentbgm = t
                t:play()
            end
        end

        function self:stopBGM()
            if self.currentbgm then
                self.currentbgm:stop()
            end
        end
    end,
    update = function(self, dt)
        if not game.hasRanInit then return end

        -- input
        if self.drawgameover and game.justPressed.a then
            if not self.quitAfterPlaying then
                game:switchState("menu")
            else
                love.event.quit()
            end
        end
        if game.gameOver and not self.drawgameover and game.keys.a then
            self.gameoverspeed = 3
        end
        -- end input

        if game.gameOver and self.blankfield then
            self.overrideMatrix = true
            self.gameoverframes = self.gameoverframes + 1
            if self.gameoverframes % self.gameoverspeed == 0 then
                if self.blankstage <= game.invisrows then
                    self.overrideMatrix = false
                    self.drawgameover = true
                    self.blankfield = false
                    game.sfx.gameover:play()
                end
                if self.blankstage < 1 then self.blankstage = 1 end
                for i, j in ipairs(game.matrix[self.blankstage]) do
                    if j then
                        local d = game.matrix[self.blankstage][i]
                        local colour = rotations[game.rotsys].colours[d] or {1, 1, 1, 1}
                        if rotations[game.rotsys].getPieceColour then
                            colour = rotations[game.rotsys]:getPieceColour(x, y, d)
                        end
                        if game.mode.getPieceColour then
                            colour = game.mode:getPieceColour(x, y, d)
                        end
                        if colour == {1, 1, 1, 1} then
                            game.matrix[self.blankstage][i] = false
                        else
                            game.matrix[self.blankstage][i] = "FLAT"
                        end
                    end
                end
                self.blankstage = self.blankstage - 1
            end
        end

        if self.drawingReadyGo then
            if self.readyGoCountdown == 0 then
                if self.readyGoStage == 3 then
                    self.drawingReadyGo = false
                    game.timeStart = love.timer.getTime()
                    game.playing = true
                    local now = os.time(os.date("*t"))
                    -- local pt = {
                    --     details = modes[self.rpArg[1]].name,
                    --     state = rotations[self.rpArg[2]].name,
                    --     startTimestamp = now,
                    --     largeImageKey = "gameplay"
                    -- }
                    -- updatePresence(pt)
                    self:playBGM(game.bgm[1])
                elseif self.readyGoStage == 2 then
                    self.readyGoText = "Go!"
                end
                if self.readyGoStage ~= 3 then
                    self.readyGoCountdown = 60
                    self.readyGoSound[self.readyGoStage]:play()
                    self.readyGoStage = self.readyGoStage + 1
                end
            end
            self.readyGoCountdown = self.readyGoCountdown - 1
        end

        game:update()
    end,
    draw = function(self)
        if game.background[game.currentBackground] then
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
            local quad = love.graphics.newQuad(0, 0, window.w, window.h, 800, 600) -- VERY NASTY HACK
            love.graphics.draw(game.background[game.currentBackground], 0, 0, 0, window.w/800, window.h/600)
        end

        local minoDim = 16

        local tx = (game.playfieldDimensions.x * minoDim)
        local ty = (game.playfieldDimensions.y * minoDim)
        love.graphics.setColor(0, 0, 0, 0.7)

        local CENTER_X = (window.w-tx)/2
        local CENTER_Y = (window.h-ty)/2

        love.graphics.rectangle("fill", CENTER_X+game.xMatrixOffset, CENTER_Y+game.yMatrixOffset, tx, ty)

        if not game.invisible then
            game.rendermatrix = deepcopy(game.matrix)
        else
            game.rendermatrix = deepcopy(game.blankmatrix)
        end

        if game.piece.active and game.are == 0 and game.playing then
            for y, j in ipairs(game.piece.type[game.piece.state] or {}) do
                for x, k in ipairs(j) do
                    if k == 1 and y+game.piecey <= game.playfieldDimensions.y+game.invisrows and x+game.piecex <= game.playfieldDimensions.x then
                        game.rendermatrix[y+game.piecey][x+game.piecex] = game.piece.name
                    end
                end
            end
        end

        if game.playing or self.overrideMatrix then
            if game.drawGhost and not self.overrideMatrix and game.piece.active then
                for y, j in ipairs(game.piece.type[game.piece.state]) do
                    for x, h in ipairs(j) do
                        if h == 1 and y+game.piecey <= game.playfieldDimensions.y+game.invisrows and x+game.piecex <= game.playfieldDimensions.x and not game.rendermatrix[game:getGhostPosition()+y][game.piecex+x] then
                            game.rendermatrix[game:getGhostPosition()+y][game.piecex+x] = 'GHOST'
                        end
                    end
                end
            end

            for y, j in ipairs(game.rendermatrix) do
                for x, d in ipairs(j) do
                    if d ~= false and y > game.invisrows then
                        local colour = rotations[game.rotsys].colours[d] or {1, 1, 1, 1}
                        if rotations[game.rotsys].getPieceColour then
                            colour = rotations[game.rotsys]:getPieceColour(x, y, d)
                        end
                        if game.mode.getPieceColour then
                            colour = game.mode:getPieceColour(x, y, d)
                        end
                        for pi, pj in pairs(plugins) do
                            if pj.enabled and pj.getPieceColour then
                                colour = pj:getPieceColour(x, y, d)
                            end
                        end
                        if d == "GHOST" then
                            colour = {1, 1, 1, 0.5}
                        end
                        love.graphics.setColor(unpack(colour))
                    else
                        love.graphics.setColor(1, 1, 1, 0)
                    end
                    love.graphics.draw(game.mino[game.minoSkin], ((CENTER_X-minoDim)+((x)*minoDim))+game.xOffset[x]+game.xMatrixOffset, (((CENTER_Y)-minoDim)+((y)*minoDim)-((4)*minoDim))+game.yOffset[x]+game.yMatrixOffset)
                end
            end

            for i = 1, game.drawNextQueue do
                local next = game.nextQueue[i]

                if next ~= nil and not self.overrideMatrix then
                    local h = rotations[game.rotsys].structure[next][1]
                    for y = 1, #h, 1 do
                        for x = 1, #h, 1 do
                            if rotations[game.rotsys].structure[next][1][y][x] == 1 then
                                love.graphics.setColor(unpack(rotations[game.rotsys].colours[next] or {1, 1, 1, 1}))
                                local v = 0
                                if optionFlags.hd then
                                    v = 50 -- dirty hack
                                end
                                love.graphics.draw(game.mino[game.minoSkin], ((window.w/2-(minoDim*4))+((x)*minoDim))+((i-1)*75), ((window.h-ty-210)-minoDim)+((y)*minoDim)-v)
                            end
                        end
                    end
                end
            end

            if game.heldPiece then
                local h = rotations[game.rotsys].structure[game.heldPiece][1]
                for y = 1, #h, 1 do
                    for x = 1, #h, 1 do
                        if rotations[game.rotsys].structure[game.heldPiece][1][y][x] == 1 then
                            love.graphics.setColor(unpack(rotations[game.rotsys].colours[game.heldPiece] or {1, 1, 1, 1}))
                            local v = 0
                            if optionFlags.hd then
                                v = 50 -- dirty hack
                            end
                            love.graphics.draw(game.mino[game.minoSkin], ((window.w/2-(minoDim*4))+((x)*minoDim)-(6*minoDim)), ((window.h-ty-210)-minoDim)+((y)*minoDim)-v)
                        end
                    end
                end
            end
        end

        local RIGHT_OF_FIELD = (CENTER_X+(CENTER_X/2))+10

        if game.mode.draw then
            game.mode:draw()
        end

        love.graphics.setColor(1, 1, 1, 1)

        if self.drawgameover then
            love.graphics.setFont(game.font.med3)
            local t = "Game Over"
            if game.won then t = "Excellent!" end
            local total = game.font.med:getHeight(t)
            love.graphics.print(t, (window.w/2)-(game.font.med3:getWidth(t)/2), (window.h/2)-total)
            love.graphics.setFont(game.font.med2)
        end

        love.graphics.setFont(game.font.med2)
        local timer = game.timer - game.timeStart
        local timeText = string.format("%02d:%02d.%02d", math.abs(math.floor(timer/60)), math.floor(timer%60), math.floor((timer*100)%100))
        local fw = game.font.med2:getWidth(timeText)
        local rt = 'REPLAY MODE'
        local rw = game.font.med2:getWidth(rt)
        love.graphics.print(timeText, (window.w/2)-(fw/2), (window.h-ty)+200)
        love.graphics.print(rt, (window.w/2)-(rw/2), (window.h-ty)+225)

        if self.drawingReadyGo then
            love.graphics.setFont(game.font.med2)
            local w = game.font.med2:getWidth(self.readyGoText)
            local h = game.font.med2:getHeight(self.readyGoText)
            love.graphics.print(self.readyGoText, (window.w/2)-(w/2), (window.h/2)-(h/2))
        end
    end,
    stop = function(self)
        if game.mode.stop then game.mode:stop() end
        self:stopBGM()
    end
}