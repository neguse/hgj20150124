
level = {
	shapes = {
		start = {
			points = { -100, -500, -100, 0, 300, 0, 500, 0, 600, 10, 700, 20, 800, -30, 1200, 50, 1300, -50 },
		},
	},
	bodies = {
		start = { shape = "start", x = 400, y = 450 },
	}
}

-- constants
DISP_W = 800
DISP_H = 600

BALL_INIT_X = DISP_W / 2
BALL_INIT_Y = DISP_H / 2
BALL_FALLED_Y_UPPER = 2500

BALL_DEBUG_MOVE = 25

GRAVITY = 9.81*64

MARK_D = 5

TORQUE_PER_PUSH = 40000
JUMP_PER_PUSH = -30000

-- variables
torque = 0
jump = 0
objects = {}
camera = { x=0, y=0, scale=1 }

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
	ty = - DISP_H * 3 / 5 + y

	nx = camera.x + (tx - camera.x) * 0.1
	ny = camera.y + (ty - camera.y) * 0.1

	-- if math.abs(ny - camera.y) < 150 then
	--	ny = camera.y + (ty - camera.y) * 0.001
	-- end

	ts = math.max(math.abs(nx - tx), math.abs(ny - ty), 1)
	ns = camera.scale + (math.max(ts / math.min(DISP_W / 2, DISP_H / 2), 1) - camera.scale) * 0.1

	camera:setPos(nx, ny)
	camera:setScale(ns)
end

function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, GRAVITY, true)

	objects.ground = {}
	objects.ground.shapes = {}
	for k, v in pairs(level.shapes) do
		objects.ground.shapes[k] = love.physics.newChainShape(false, unpack(v.points))
	end
	objects.ground.bodies = {}
	objects.ground.points = {}
	for k, v in pairs(level.bodies) do
		local body = love.physics.newBody(world, v.x, v.y)
		print (body)
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
	objects.ball.fixture:setRestitution(0.9)

	love.graphics.setBackgroundColor(220, 220, 220)
	love.window.setMode(DISP_W, DISP_H)
end


function love.keypressed(key, isrepeat)
   if key == "escape" then
      love.event.quit()
   end
   if key == "left" and not isrepeat then
	   torque = torque - TORQUE_PER_PUSH
   end
   if key == "right" and not isrepeat then
	   torque = torque + TORQUE_PER_PUSH
   end
   if key == "up" and not isrepeat then
	   jump = jump + JUMP_PER_PUSH
   end
end

function love.update(dt)

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


	world:update(dt)

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
		objects.ball.body:setPosition(BALL_INIT_X, BALL_INIT_Y)
		objects.ball.body:setLinearVelocity(0, 0)
		objects.ball.body:setAngularVelocity(0, 0)
	end

end

function love.draw()
	camera:set()

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
	love.graphics.setColor(0, 0, 0)
	love.graphics.printf(
		string.format("pos:%3.2f, %3.2f", objects.ball.body:getX(), objects.ball.body:getY()),
		0, 0, DISP_W)
	love.graphics.printf(
		string.format("camera:%3.2f, %3.2f, %3.2f", camera.x, camera.y, camera.scale),
		0, 20, DISP_W)

end

