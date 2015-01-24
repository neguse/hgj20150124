
sounds = {
	hit = { path = "resources/hit.wav" },
	restart = { path = "resources/restart.wav" },
	roll = { path = "resources/roll.wav" },
	start = { path = "resources/start.wav" },
}

level = {
	shapes = {
		start = {
			points = { -100, -500, -100, 0, 300, 0, 500, 0, 600, 10, 700, 20, 800, -30, 1200, 50, 1300, -50 },
		},
		second = {
			points = {0, 0, 30, 3, 82, 28, 148, 24, 193, -12, 282, -64, 387, -33, 481, 16, 638, 47, 668, -39, 775, -42, },
		},
		owan = {
			points = {4, -290, 9, -275, 28, -229, 53, -200, 75, -168, 128, -116, 169, -83, 207, -33, 247, -14, 301, -1, 373, 4, 443, 7, 542, -10, 619, -77, 650, -113, 689, -150, 723, -210, 755, -256, 773, -290, },
		},
		slope = {
			points = {0, 0, 17, 2, 87, -9, 125, -22, 208, -38, 265, -37, 320, -34, 407, -34, 506, -16, 576, -6, 659, -3, 754, -2, 787, 0, },
		},
		upper = {
			points = {0, 0, 11, -1, 64, -10, 162, -34, 302, -73, 497, -166, 667, -250, 764, -298, },
		},
	},
	bodies = {
		start = { shape = "start", x = 0, y = 100 },
		owan = { shape = "owan", x = 1365, y = 320 },
		owan2 = { shape = "owan", x = 2265, y = 420 },
		owan3 = { shape = "owan", x = 3265, y = 620 },
		slope = { shape = "slope", x = 4134, y = 450 },
		upper = { shape = "upper", x = 5134, y = 450 },
		upper2 = { shape = "upper", x = 6134, y = 350 },
		upper3 = { shape = "upper", x = 7134, y = 350 },
		upper4 = { shape = "upper", x = 8134, y = 350 },
	},
	checkpoints = {
		{x = 150, y = 0},
		{x = 1200, y = -100},
		{x = 3600, y = 523},
		{x = 9999, y = 0},
	},
	messages = {
		{xbegin = -200, xend = 100, message = "Push Left or Right key to rolling ball." },
		{xbegin = 100, xend = 300, message = "Good luck!" },
	}
}

-- constants
DISP_W = 800
DISP_H = 600

BALL_INIT_X = 0
BALL_INIT_Y = 0
BALL_FALLED_Y_UPPER = 2500

BALL_DEBUG_MOVE = 25

GRAVITY = 9.81*64

MARK_D = 5

TORQUE_PER_PUSH = 40000
JUMP_PER_PUSH = -300

CHECKPOINT_LEN = 100

-- variables
torque = 0
jump = 0
objects = {}
camera = { x=0, y=0, scale=1.5 }
checked = 0
isgoal = false
isdebug = true
starttime = nil
goaltime = nil

function pack(...)
	return arg
end

-- camera
function camera:set()
	love.graphics.push()
	love.graphics.scale(1.0 / self.scale)
	love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
	love.graphics.pop()
end

function camera:setPos(x, y)
	self.x = x
	self.y = y
end

function camera:setScale(f)
	self.scale = f
end

function camera:lookto(x, y)
	tx = - DISP_W / 2 + x
	ty = - DISP_H + y

	nx = camera.x + (tx - camera.x) * 0.1
	ny = camera.y + (ty - camera.y) * 0.1

	-- if math.abs(ny - camera.y) < 150 then
	--	ny = camera.y + (ty - camera.y) * 0.001
	-- end

	-- ts = math.max(math.abs(nx - tx), math.abs(ny - ty), 1)
	-- ns = camera.scale + (math.max(ts / math.min(DISP_W / 2, DISP_H / 2), 1) - camera.scale) * 0.1

	camera:setPos(nx, ny)
	-- camera:setScale(ns)
end

function beginContact()
	sounds.hit.sound:rewind()
	sounds.hit.sound:play()
end

function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, GRAVITY, true)
	world:setCallbacks(beginContact)

	objects.ground = {}
	objects.ground.shapes = {}
	for k, v in pairs(level.shapes) do
		objects.ground.shapes[k] = love.physics.newChainShape(false, unpack(v.points))
	end
	objects.ground.bodies = {}
	objects.ground.points = {}
	for k, v in pairs(level.bodies) do
		local body = love.physics.newBody(world, v.x, v.y)
		local shape = objects.ground.shapes[v.shape]
		local fixture = love.physics.newFixture(body, shape)

		objects.ground.bodies[k] = {
			body = body,
			shape = shape,
			fixture = fixture,
		}
	end

	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, BALL_INIT_X, BALL_INIT_Y, "dynamic")
	objects.ball.shape = love.physics.newCircleShape(20)
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1)
	objects.ball.fixture:setFriction(0.8)
	objects.ball.fixture:setRestitution(0.8)

	love.graphics.setBackgroundColor(220, 220, 220)
	love.window.setMode(DISP_W, DISP_H)

	for k, v in pairs(sounds) do
		v.sound = love.audio.newSource(v.path)
	end

end

function love.keypressed(key, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
	if key == "left" and not isrepeat then
		torque = torque - TORQUE_PER_PUSH
		sounds.roll.sound:rewind()
		sounds.roll.sound:play()
	end
	if key == "right" and not isrepeat then
		torque = torque + TORQUE_PER_PUSH
		sounds.roll.sound:rewind()
		sounds.roll.sound:play()
	end
	if key == "up" and not isrepeat then
		jump = jump + JUMP_PER_PUSH
	end
end

function love.update(dt)

	if isdebug then

		-- f fixes ball.
		if love.keyboard.isDown("f") then
			world:setGravity(0, 0)
			objects.ball.body:setLinearVelocity(0, 0)
			objects.ball.body:setAngularVelocity(0, 0)
		else
			world:setGravity(0, GRAVITY)
		end

		-- move ball by wasd.
		if love.keyboard.isDown("w") then
			objects.ball.body:setY(objects.ball.body:getY() - BALL_DEBUG_MOVE)
		end
		if love.keyboard.isDown("s") then
			objects.ball.body:setY(objects.ball.body:getY() + BALL_DEBUG_MOVE)
		end
		if love.keyboard.isDown("a") then
			objects.ball.body:setX(objects.ball.body:getX() - BALL_DEBUG_MOVE)
		end
		if love.keyboard.isDown("d") then
			objects.ball.body:setX(objects.ball.body:getX() + BALL_DEBUG_MOVE)
		end

	end

	for i, v in pairs(level.checkpoints) do
		if checked < i then
			local dx = v.x - objects.ball.body:getX()
			local dy = v.y - objects.ball.body:getY()
			local d = math.sqrt(dx*dx+dy*dy)
			if d < CHECKPOINT_LEN then
				checked = i
				sounds.start.sound:play()

				if i == 1 then
					starttime = love.timer.getTime()
				end
				if i == #level.checkpoints then
					goaltime = love.timer.getTime()
					isgoal = true
				end
			end
		end
	end

	if not isgoal then
		world:update(dt)
	end

	camera:lookto(objects.ball.body:getX(), objects.ball.body:getY())

	if torque ~= 0 then
		objects.ball.body:applyTorque(torque)
		torque = 0
	end
	if jump ~= 0 then
		objects.ball.body:applyForce(0, jump)
		jump = 0
	end

	-- Detect fall and then return ball position.
	if objects.ball.body:getY() > BALL_FALLED_Y_UPPER then
		if checked == 0 then
			objects.ball.body:setPosition(BALL_INIT_X, BALL_INIT_Y)
		else
			checkpoint = level.checkpoints[checked]
			objects.ball.body:setPosition(checkpoint.x, checkpoint.y)
		end
		objects.ball.body:setLinearVelocity(0, 0)
		objects.ball.body:setAngularVelocity(0, 0)
		sounds.restart.sound:play()
	end

end

function love.draw()
	if starttime ~= nil and goaltime == nil then
		love.graphics.printf(
			string.format("time:%2.5f", love.timer.getTime() - starttime),
			0, 0, DISP_W, "right")
	end

	if isgoal then
		love.graphics.printf(
			"Goal!", 0, -150 + DISP_H / 2, DISP_W, "center")

		love.graphics.printf(
			string.format("time:%2.5f", goaltime - starttime),
			0, -50 + DISP_H / 2, DISP_W, "center")
	end

	for k, v in pairs(level.messages) do
		bx = objects.ball.body:getX()
		if v.xbegin < bx and bx < v.xend then
			love.graphics.printf(
				v.message, 0, DISP_H / 2, DISP_W, "center")
		end
	end

	camera:set()

	for i, v in pairs(level.checkpoints) do
		if i <= checked then
			love.graphics.setColor(201, 201, 137, 128)
		else
			love.graphics.setColor(137, 201, 137, 128)
		end
		love.graphics.circle("fill", v.x, v.y, CHECKPOINT_LEN)
	end

	love.graphics.setColor(137, 137, 137)
	love.graphics.setLineWidth(5)
	for k, v in pairs(objects.ground.bodies) do
		love.graphics.line(v.body:getWorldPoints(v.shape:getPoints()))
	end

	love.graphics.setColor(23, 23, 23)
	love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
	-- draw marking
	love.graphics.setColor(82, 82, 82)
	a = objects.ball.body:getAngle()
	x = objects.ball.body:getX() + math.cos(a) * MARK_D
	y = objects.ball.body:getY() + math.sin(a) * MARK_D
	love.graphics.circle("fill", x, y, 4)

	camera:unset()

	-- print information for developing perpose.
	if isdebug then
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf(
		string.format("pos:%3.2f, %3.2f", objects.ball.body:getX(), objects.ball.body:getY()),
		0, 0, DISP_W)
		love.graphics.printf(
		string.format("camera:%3.2f, %3.2f, %3.2f", camera.x, camera.y, camera.scale),
		0, 20, DISP_W)
	end

end

