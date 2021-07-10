push = require "push"

class = require 'Class'

require 'Paddle'
require 'Ball'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_HEIGHT = 432
VIRTUAL_WIDTH = 400

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont("font.ttf", 16)
    largeFont = love.graphics.newFont("font.ttf", 32)
    math.randomseed(os.time())

    love.window.setTitle("Pong")
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false, 
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    player1 = Paddle(10, 30, 5, 30)
    player2 = Paddle(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT-30, 5, 30)

    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)

    ball_y = 0
    dist_bn_ball_player2 = 0
    target_y = 0 
    last_hit_y = 0

    gameState = 'start'
    winner = ''
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then 
        if gameState == 'win' then 
            gameState = 'start'
            player1Score = 0
            player2Score = 0
            winner = ''
        end
        if gameState == 'start' then 
            gameState = 'play'
        else
            gameState = 'start'
            ball:reset()
        end
    end
end

function love.update(dt)
    if love.keyboard.isDown('w') or love.keyboard.isDown('up') then 
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then 
        player1.dy = PADDLE_SPEED
    else 
        player1.dy = 0
    end

    if ball.dx > 0 then
        if player2.y+(player2.height/2) <= target_y-5 then
            player2.dy = PADDLE_SPEED
        elseif player2.y+(player2.height/2) >= target_y+5 then  
            player2.dy = -PADDLE_SPEED
        else
            player2.dy = 0
        end
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    if ball:collide(player2) then 
        sounds['paddle_hit']:play()
        ball.x = player2.x - 5
        ball.dx = -ball.dx * 1.03

        if ball.dy < 0 then 
            ball.dy = -math.random(10, 150)
        else 
            ball.dy = math.random(10, 150)
        end
    end

    if ball:collide(player1) then 
        ball_y = ball.y + (ball.height/2)
        dist_bn_ball_player2 = player2.x - (ball.x+ball.width)
        target_y = ball_y - ( (ball.dy*dist_bn_ball_player2)/ball.dx )

        sounds['paddle_hit']:play()
        ball.x = player1.x + 5
        ball.dx = -ball.dx * 1.03

    end

    --Check collision with boundaries

    if ball.y >= VIRTUAL_HEIGHT - 4 then 
        ball_y = ball.y + (ball.height/2)
        dist_bn_ball_player2 = player2.x - (ball.x+ball.width)
        target_y = ball_y - ( (ball.dy*dist_bn_ball_player2)/ball.dx )

        ball.y = VIRTUAL_HEIGHT- 4
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end 

    if ball.y <=0 then 
        ball_y = ball.y + (ball.height/2)
        dist_bn_ball_player2 = player2.x - (ball.x+ball.width)
        target_y = ball_y - ( (ball.dy*dist_bn_ball_player2)/ball.dx )

        ball.y = 0
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end

    if ball.x+ball.width < 0 then 
        player2Score = player2Score + 1
        sounds['score']:play()
        ball:reset()
    end

    if ball.x+ball.width > VIRTUAL_WIDTH then 
        last_hit_y = ball.y+(ball.height/2)

        player1Score = player1Score + 1
        sounds['score']:play()
        ball:reset()
    end

    if player1Score == 10 then 
        gameState = 'win'
        winner = 'player1'
    end 

    if player2Score == 10 then 
        gameState = 'win'
        winner = 'player2'
    end 

    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if gameState == 'win' then
        love.graphics.setFont(largeFont)
        love.graphics.printf(winner .. " won", 0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
    end

    if gameState ~= 'win' then 

        love.graphics.setFont(smallFont)    
        if gameState == 'start' then
            love.graphics.printf('Hit enter to start', 0, 30, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf('Hit enter to reset', 0, 30, VIRTUAL_WIDTH, 'center')
        end

        love.graphics.setFont(largeFont)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

        player1:render()
        player2:render()
        ball:render()
    end

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 1)
end