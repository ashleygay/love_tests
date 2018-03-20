src2 = love.audio.newSource("music.mp3")
platform = {}
player = {}

-- Current entities in the game
entities = {}

keybindings = {}
keybindings["Left"] = 'h'
keybindings["Right"] = 'l'
keybindings["Jump"] = 'k'

-- Table that matches conditions with their code to execute
actions = {}
--actions[isDown] = moveRight

--------------------
-- LOVE callbacks --
--------------------

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)

	--local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
	--love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], 0, 0, 0, 4)
end

function love.load()
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

	-- Animation setup
	animation = newAnimation(love.graphics.newImage("hero.png"), 16, 18, 1)
	entities["player"] = player
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

	if isDown("Right") then
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

	animation.currentTime = animation.currentTime + dt
	if animation.currentTime >= animation.duration then
		animation.currentTime = animation.currentTime - animation.duration
	end

	if player.x_velocity > 0 then
		player.x_velocity = player.x_velocity - player.deccel
	elseif player.x_velocity < 0 then
		player.x_velocity = player.x_velocity + player.deccel
	end
end

function updateMovement(entityIndex)
end

-----------------------------------
-- No callbacks below this point --
-----------------------------------

-- A given animation is for a given action (walking left. falling, etc...)
-- Each action is bound to condition and a callback function
-- The condition can be a keybind press or another condition (ex: falling)
-- We only have one condition at a time
-- We have an index in the spritesheet for the given action
-- We have a counter that functions as an index to the current step of the
-- animation.
-- We have a last index for the selected idle animation.
-- 	-> The idle animation can differ based on the previous animation.


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

function isDown(str)
	return love.keyboard.isDown(keybindings[str])
end

-- The idea is to simulate windup time
function moveRight()
	if player.x_velocity < player.max_abs_speed then
		player.x_velocity = player.x_velocity + player.accel
	end
end

function moveLeft()
	if player.x_velocity > -1 * player.max_abs_speed then
		player.x_velocity = player.x_velocity - player.accel
	end
end

