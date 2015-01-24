
-- constants
DISP_W = 800
DISP_H = 600

MARK_D = 5

TORQUE_PER_PUSH = 40000
JUMP_PER_PUSH = -30000

-- variables
torque = 0
jump = 0
objects = {}

function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)

	objects.ground = {}
	objects.ground.body = love.physics.newBody(world, DISP_W/2, DISP_H-50/2)
	objects.ground.shape = love.physics.newRectangleShape(DISP_W, 50)
	objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)

	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, DISP_W/2, DISP_H/2, "dynamic")
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
	world:update(dt)

	if torque ~= 0 then
		objects.ball.body:applyTorque(torque)
		torque = 0
	end
	if jump ~= 0 then
		objects.ball.body:applyForce(0, jump)
		jump = 0
	end

end

function love.draw()
	love.graphics.setColor(137, 137, 137)
	love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))

	love.graphics.setColor(23, 23, 23)
	love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
	-- draw marking
	love.graphics.setColor(82, 82, 82)
	a = objects.ball.body:getAngle()
	x = objects.ball.body:getX() + math.cos(a) * MARK_D
	y = objects.ball.body:getY() + math.sin(a) * MARK_D
	love.graphics.circle("fill", x, y, 4)

end

