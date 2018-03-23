
-- Animation
-- actual index into the animation table
-- ending_animation;
-- required condition: all must be met to go into it
-- accepting condition: only one can be met

-- In order to go into the animation, the player must satisfy all
-- required conditions and at least one accepting condition

-- Lookup metatable for `classes`


AnimationState = {
	ending_animation = 1;
	animation_index = 1; -- index into the spritesheet
	required_conditions = {};
	accepting_conditions = {};
}

PlayerState = {
	animation_state = AnimationState;
	animations  = {[1] = animation_state};
	can_move = true;
	-- all for now
}

Player = {
	player_state = PlayerState;
	animation = nil; -- initialize it
}

-- A given animation is for a given action (walking left. falling, etc...)
-- Each action is bound to condition and a callback function
-- The condition can be a keybind press or another condition (ex: falling)
-- We only have one condition at a time
-- We have an index in the spritesheet for the given action
-- We have a counter that functions as an index to the current step of the
-- animation.
-- We have a last index for the selected idle animation.
-- 	-> The idle animation can differ based on the previous animation.
-- ANIMATIONS --
-- Terminology:
--	frame_index ->  in the table of the animation for the current frame
--	animation_index -> index to get the table of frames for the current state
--		IE: falling, jumping, going left,...
--
--	In C, we would compute the frame like this:
--		struct frame;
--		frame ** ptr = animation_table
--		frame f = ptr[animation_index][frame_index]
--
--

function Player.InitAnimation(self, str, w, h, duration)
	self.animation = newAnimation(str, w, h, duration);
end

function Player.updateAnimation(self)
	animation = self.animations[current_animation];
end

function Player.animationHasEnded(self)
	
end

function newAnimation(image, width, height, duration)
	local _animation = {}
	_animation.spritesheet = image;
	_animation.quads = {{},{},{},{}}; --TODO: fix that shit

	print("Image", image)
	print("Creating spritesheet", _animation.spritesheet)

	local index = 1;
	for y = 0, image:getHeight() - height, height do
		for x = 0, image:getWidth() - width, width do
			print("Test", x, y, width, height, "Index:", index)
			table.insert(_animation.quads[index], love.graphics.newQuad(x, y,
				width, height, image:getDimensions()))
        end
		index = index + 1;
    end

	_animation.duration = duration or 1
	_animation.currentTime = 0

	print("Returning spritesheet", _animation.spritesheet)
	return _animation
end


