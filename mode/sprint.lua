return {
    name = "Sprint",
    init = function(self)
        game.speeds = {
            gravity = 1/64, -- 1/64th of a G
            das = 8,
            lockDelay = 30,
            are = 10,
            lineAre = 20
        }

        self.endcount = 40

        game.movereset = true
    end,
    linesCleared = function(self, lines)
        if lines > 0 then
            if game.stats.lines >= self.endcount then
                game.won = true
                game:killPlayer()
            end
        end
    end,
    draw = function(self)
        ui.drawScoreText(self.endcount .. "-Line Sprint", 0)

        ui.drawScoreText("Lines", 2)
        ui.drawScoreText(tostring(self.endcount - game.stats.lines), 3)
    end,
    getPresenceText = function(self)
        return tostring(game.stats.pieceLocks) .. " blocks dropped"
    end
}