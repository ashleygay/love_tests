src2 = love.audio.newSource("music.mp3")
platform = {}
player = {}

keybindings = {}
keybindings["Left"] = 'h'
keybindings["Right"] = 'l'

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)

	--local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
	--love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], 0, 0, 0, 4)
end

function love.load()
	platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()
	platform.x = 0
	platform.y = platform.height / 2

	-- Player setup
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.img = love.graphics.newImage('purple.png')
	player.speed = 0
	player.ground = player.y
	player.y_velocity = player.y
	player.jump_height = -300
	player.gravity = -900

	-- Animation setup
	animation = newAnimation(love.graphics.newImage("hero.png"), 16, 18, 1)
end

function love.update(dt)

	if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
		player.x = player.x + (player.speed * dt)
	else
		player.x = (love.graphics.getWidth() - player.img:getWidth() - 1)
	end

	if love.keyboard.isDown(keybindings["Right"]) then
		moveRight()
	elseif love.keyboard.isDown(keybindings["Left"]) then
		moveLeft()
	end

	if love.keyboard.isDown('space') then
		if player.y_velocity == 0 then
			player.y_velocity = player.jump_height
		end
	end

	if player.y_velocity ~= 0 then
		player.y = player.y + player.y_velocity * dt
		player.y_velocity = player.y_velocity - player.gravity * dt
	end

	if player.y > player.ground then
		player.y_velocity = 0
		player.y = player.ground
	end

	animation.currentTime = animation.currentTime + dt
	if animation.currentTime >= animation.duration then
		animation.currentTime = animation.currentTime - animation.duration
	end

	if player.speed > 0 then
		player.speed = player.speed - 40
	elseif player.speed < 0 then
		player.speed = player.speed + 40
	end
end

-- No callbacks below this point

-- Generate an animation table ready for use
-- Each frame have the same width, height and duration
function newAnimation(image, width, height, duration)
	local animation = {}
	animation.spritesheet = image;
	animation.quads = {};
	for y = 0, image:getHeight() - height, height do
		for x = 0, image:getWidth() - width, width do
			table.insert(animation.quads, love.graphics.newQuad(x, y,
				width, height, image:getDimensions()))
        end
    end

	animation.duration = duration
	animation.currentTime = 0

	return animation
end

-- The idea is to simulate windup time
function moveRight()
	if player.speed < 800 then
		player.speed = player.speed + 80
	end
end

function moveLeft()
	if player.speed > -800 then
		player.speed = player.speed - 80
	end
end

