
-- Animation
-- actual index into the animation table
-- ending_animation;
-- required condition: all must be met to go into it
-- accepting condition: only one can be met

-- In order to go into the animation, the player must satisfy all
-- required conditions and at least one accepting condition

-- Lookup metatable for `classes`

require "input"

movingLeft = function() return isDown("Left") end
movingRight = function() return isDown("Right") end

IdleState = {
	animation_index = 2; -- index into the spritesheet
	animation = nil;
	conditions = {
		[function() return (not movingLeft() and not movingRight()) end] = 1,
		[function() return (movingLeft() and movingRight()) end] = 1,
		[function() return (movingLeft() and not movingRight()) end] = 2,
		[function() return (movingRight() and not movingLeft()) end] = 3,
	};
	effect = function(player) end;
}

LeftState = {
	animation_index = 4; -- index into the spritesheet
	animation = nil;
	conditions = {
		[function() return (not movingLeft() and not movingRight()) end] = 1,
		[function() return (movingLeft() and movingRight()) end] = 1,
		[function() return (movingLeft() and not movingRight()) end] = 2,
		[function() return (movingRight() and not movingLeft()) end] = 3,
	};
	effect = moveLeft;
}

RightState = {
	animation_index = 4; -- index into the spritesheet
	animation = nil;
	conditions = {
		[function() return (not movingLeft() and not movingRight()) end] = 1,
		[function() return (movingLeft() and movingRight()) end] = 1,
		[function() return (movingLeft() and not movingRight()) end] = 2,
		[function() return (movingRight() and not movingLeft()) end] = 3,
	};
	effect = moveRight;
}

-- Global animation set containg all animations
GlobalAnimationTable = {};
GlobalAnimationTable[1] = IdleState;
GlobalAnimationTable[2] = LeftState;
GlobalAnimationTable[3] = RightState;
--HACK CHANGE IT GOD ITS BAD
GlobalAnimationTable[4] = RightState;

function init_animation_table(unstable)
	for index, state in pairs(unstable) do
		state.animation = newSpritesheet(love.graphics.newImage("robots.png"),
			64, 64, 1/4, state.animation_index);
	end
end

-- We could represent all animations `paths` as a directed graph:
-- (walking_state) => jumping
--				   => attacking
--				   => falling
--				   => taking damage

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

-- TODO We specify the nth line that we take for the animation
function newSpritesheet(image, width, height, duration, row)
	local _animation = {}
	_animation.spritesheet = image;
	_animation.quads = {}; --TODO: fix that shit

	print("Image", image)
	print("Creating spritesheet", _animation.spritesheet)

	-- Height is the iterator, we add height each loop iteration.
	print("Height ", height)

	local actual_height = (row - 1) * height;
	for x = 0, image:getWidth() - width, width do
			print("Test", x, y, width, height);
			table.insert(_animation.quads,
				love.graphics.newQuad(x,actual_height, width, actual_height,
				image:getDimensions()))
    end

	_animation.duration = duration or 1
	_animation.currentTime = 0

	print("Table size ", table.getn(_animation.quads))
	print("Returning spritesheet", _animation.spritesheet)
	return _animation
end


