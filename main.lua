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

	-- XXX Wobblyness kind of `removed`, at some point replace by real collisions???

	-- dt is the time difference betwee 2 update calls
	print("DT", dt)
	local new_pos = player.x + (player.x_velocity * dt)
	if not (new_pos < 0 )
	and not (new_pos > love.graphics.getWidth() - 64) then
		player.x = new_pos
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
	--- TODO: create a screen object
	local x_scale = love.graphics.getWidth() / platform.width;
	local y_scale = love.graphics.getHeight() / platform.height;
	love.graphics.scale(x_scale, y_scale);

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

	love.graphics.draw(player.animation.spritesheet,
		player.animation.quads[player.spritenum],
		player.x, player.y - 64, 0, 2)

--  XXX: userdata vs table ???
--	print("Quad", player.animation.quads[player.spritenum])
--	for key, value in pairs(player.animation.quads[player.spritenum]) do
--		print(key, "=", value)
--	end
	print("Sprite height = ", player.animation.quads[player.spritenum].height)

	love.graphics.setColor(123, 123, 123)
	--love.graphics.rectangle('fill', player.x, player.y, 64, -64)

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

