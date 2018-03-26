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
	player.deccel = 150
	player.max_abs_speed = 600
	player.spritenum = 1;

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
end

function love.draw()
	-- TODO use love.grpahics.zoom to enable fullscreen.
	love.graphics.scale(2, 2);
	love.graphics.draw(player.animation.spritesheet,
		player.animation.quads[player.spritenum],
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
		-- If a condition is succesful, we change the current animation to it.
		if condition(player) then
			--XXX I dont like this, find a way to remove that code
			if not (player.animation_index == index) then
				player.animation.currentTime = 0; -- Reset the animation timer
			end
			player.animation_index = index;
			player.animation = GlobalAnimationTable[index].animation;
			-- We play the effect of the new state.
			GlobalAnimationTable[player.animation_index].effect(player)
			break;
		end
	end

	player.spritenum = compute_next_frame_index(player);
end

function compute_next_frame_index(player)
	return math.floor(
		player.animation.currentTime / player.animation.duration *
		#player.animation.quads) + 1
end

