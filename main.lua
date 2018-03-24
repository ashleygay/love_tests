require "input"
require "player"

src2 = love.audio.newSource("music.mp3")
platform = {}
player = {}

-- Current entities in the game
entities = {}

-- Table that matches conditions with their code to execute
actions = {}
--actions[isDown] = moveRight

rotation = 0
camera_acc = -0.1

--------------------
-- LOVE callbacks --
--------------------

function love.load()
	animation = newAnimation(love.graphics.newImage("more_robots.png"), 64, 64, 1/4)
	-- Platform setup
	platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()
	platform.x = 0
	platform.y = platform.height / 2

	-- Player setup
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.img = love.graphics.newImage('purple.png')
	player.x_velocity = 0
	player.ground = player.y
	player.y_velocity = player.y
	player.jump_height = -500
	player.gravity = -1500
	player.accel = 300
	player.deccel = 100
	player.max_abs_speed = 600
end

function love.update(dt)
	-- We update only one entity for one `love.update` call,
	-- we increase the wrap-around index into the tables of entities to update.

	-- Right most case
	if player.x > (love.graphics.getWidth() - player.img:getWidth()) then
		player.x = (love.graphics.getWidth() - player.img:getWidth())
		player.x_velocity = 0
	elseif player.x < 0 then -- Left most case
		player.x = 1
		player.x_velocity = 0
	else -- Normal case
		player.x = player.x + (player.x_velocity * dt)
	end

	local right = function() return isDown("Right") end
	print("Is Down ?", right)
	if right() then
		moveRight()
	elseif isDown("Left") then
		moveLeft()
	end

	if isDown("Jump") then
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

	-- update animation
	animation.currentTime = animation.currentTime + dt
	if animation.currentTime >= animation.duration then
		animation.currentTime = animation.currentTime - animation.duration
	end

	if player.x_velocity > 0 then
		player.x_velocity = player.x_velocity - player.deccel;
	elseif player.x_velocity < 0 then
		player.x_velocity = player.x_velocity + player.deccel;
	end

	if rotation < -0.5 then
		camera_acc = 0.01;
	end

	if rotation > 0.5 then
		camera_acc = -0.01;
	end
	rotation = rotation + camera_acc
end

function love.draw()
	love.graphics.rotate(rotation);
	local index = 4;
	-- Lua tables are indexed at 1.
	local frameIndex = math.floor(animation.currentTime / animation.duration * #animation.quads[index]) + 1
	print("frameIndex", frameIndex)
	print("Spritesheet", animation.spritesheet)
	print("quad[frameIndex]", animation.quads[frameIndex])
	love.graphics.draw(animation.spritesheet, animation.quads[index][frameIndex], 0, 0, 0, 2)

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)

end

-----------------------------------
-- No callbacks below this point --
-----------------------------------
