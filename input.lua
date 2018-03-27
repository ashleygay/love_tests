
keybindings = {}
keybindings["Left"] = 'h'
keybindings["Right"] = 'l'
keybindings["Jump"] = 'k'

-- Input functions
--
function isDown(str)
	return love.keyboard.isDown(keybindings[str])
end

-- The idea is to simulate windup time
function moveRight(player)
	if player.x_velocity < player.max_abs_speed then
		player.x_velocity = player.x_velocity + 2 * player.accel
	end
end

function moveLeft(player)
	if player.x_velocity > -1 * player.max_abs_speed then
		player.x_velocity = player.x_velocity - 2 * player.accel
	end
end

function jump(player)
	player.y_velocity = player.jump_height
end
