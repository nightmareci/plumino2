game.states.splash = {
    init = function(self)
        self.stuff = {
            game.gfx.dev,
            game.gfx.intro,
            game.gfx.poweredby
        }
        self.timer = 1
        self.state = 0
        self.progress = 1
        self.speed = 2
    end,
    update = function(self)
        if self.state == 0 then
            self.timer = self.timer + self.speed
        elseif self.state == 1 then
            self.timer = self.timer - self.speed
        end
        if self.timer > 100 then
            self.state = 1
        end
        if self.timer < 1 then
            self.state = 0
            self.progress = self.progress + 1
        end
        if self.progress > #self.stuff then
            game:switchState("menu")
        end
    end,
    draw = function(self)
        local i = self.stuff[self.progress]
        local w, h, _ = love.window.getMode()
        love.graphics.setColor(1, 1, 1, self.timer/100)
        love.graphics.draw(i, (w/2)-(i:getWidth()/2), (h/2)-(i:getHeight()/2))
    end
}