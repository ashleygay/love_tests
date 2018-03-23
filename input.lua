-- Input functions
--
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
