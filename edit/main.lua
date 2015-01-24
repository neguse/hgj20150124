
-- constants
DISP_W = 800
DISP_H = 600

-- variables
shape = {0, 0, 0, 0 }

function love.mousepressed(x, y, button)
	table.insert(shape, x)
	table.insert(shape, y - DISP_H / 2)
end

function love.load()
end

function love.update(dt)
end

function love.keypressed(key, isrepeat)
	if key == "return" then
		local buf = "points = {"
		for i, v in pairs(shape) do
			if i > 2 then
				buf = buf .. string.format("%d, ", v)
			end
		end
		buf = buf .. "},"
		print(buf)
	end
end

function love.draw()
	love.graphics.push()

	love.graphics.translate(0, DISP_H / 2)

	love.graphics.setLineWidth(5)
	love.graphics.setColor(110, 110, 110)
	love.graphics.line(0, 0, DISP_W, 0)

	love.graphics.setBackgroundColor(220, 220, 220)
	love.graphics.setColor(0, 0, 0)
	love.graphics.line(unpack(shape))

	love.graphics.pop()
end


