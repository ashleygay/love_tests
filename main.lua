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


player = {
	animation_index = 1;
	frame_index = 1;
	can_move = true;
	-- all for now
}
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

--------------------
-- LOVE callbacks --
--------------------

function love.load()
	-- Platform setup
	platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()
	platform.x = 0
	platform.y = platform.height / 2
	init_animation_table(GlobalAnimationTable);
	player.animation = GlobalAnimationTable[1].animation;
	player.animation_index = 1;
end

function love.update(dt)
	-- We update only one entity for one `love.update` call,
	-- we increase the wrap-around index into the tables of entities to update.

	-- Right most case
	-- TODO: Remove the woblyness
	-- Actually maybe wait for the collision detection to do it
	if player.x > (love.graphics.getWidth() - player.img:getWidth()) then
		player.x = (love.graphics.getWidth() - player.img:getWidth())
		player.x_velocity = 0
	elseif player.x < 0 then -- Left most case
		player.x = 1
		player.x_velocity = 0
	else -- Normal case
		player.x = player.x + (player.x_velocity * dt)
	end

	if player.y_velocity ~= 0 then
		player.y = player.y + player.y_velocity * dt
		player.y_velocity = player.y_velocity - player.gravity * dt
	end

	if player.y > player.ground then
		player.y_velocity = 0
		player.y = player.ground
	end

	update_player(player, dt)

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
	player.frame_index = compute_next_frame_index(player);
end

function love.draw()
	-- love.graphics.rotate(rotation);
	love.graphics.draw(player.animation.spritesheet,
		player.animation.quads[player.frame_index],
		player.x, player.y - 120, 0, 2)

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

end

-----------------------------------
-- No callbacks below this point --
-----------------------------------

function update_player(player, dt)

	player.animation.currentTime = player.animation.currentTime + dt
	if player.animation.currentTime >= player.animation.duration then
		-- We restart at the first animation
		player.animation.currentTime = player.animation.currentTime - player.animation.duration
	end

	-- If a condition is sucessful, we update the current animation.
	-- We get the possible next states of the current animation
	local conditions = GlobalAnimationTable[player.animation_index].conditions;
	for condition, index in pairs(conditions) do
		print("Vertical velocity", player.y_velocity, "Jump?", isDown("Jump"))
		-- If an animation is succesful, we change the current animation to it.
		if condition(player) then
			player.animation_index = index;
			player.animation = GlobalAnimationTable[index].animation;
			-- We play the effect of the change of state.
			GlobalAnimationTable[player.animation_index].effect(player)
			player.animation.currentTime = 0; -- Reset the animation timer
			break;
		end
	end
end

-- function new_animation(image, width, height, duration)
-- 	local _animation = {}
-- 	_animation.spritesheet = image;
-- 	_animation.quads = {{},{},{},{}}; --TODO: fix that shit
-- print("Image", image)
-- 	print("Creating spritesheet", _animation.spritesheet)
-- 
-- 	local index = 1;
-- 	for y = 0, image:getHeight() - height, height do
-- 		for x = 0, image:getWidth() - width, width do
-- 			print("Test", x, y, width, height, "Index:", index)
-- 			table.insert(_animation.quads[index], love.graphics.newQuad(x, y,
-- 				width, height, image:getDimensions()))
--         end
-- 		index = index + 1;
--     end
-- 
-- 	_animation.duration = duration or 1
-- 	_animation.currentTime = 0
-- 
-- 	print("Returning spritesheet", _animation.spritesheet)
-- 	return _animation
-- end

function compute_next_frame_index(player)
	return math.floor(
		player.animation.currentTime / player.animation.duration *
		#player.animation.quads) + 1
end

