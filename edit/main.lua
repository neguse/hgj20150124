
shape = {0, 0, 0, 0 }

function love.mousepressed(x, y, button)
	table.insert(shape, x)
	table.insert(shape, y)
end

function love.load()
end

function love.update(dt)
end

function love.keypressed(key, isrepeat)
	if key == "return" then
		local buf = "points = {"
		for i, v in pairs(shape) do
			if i > 4 then
				buf = buf .. string.format("%d, ", v)
			end
		end
		buf = buf .. "},"
		print(buf)
	end
end

function love.draw()
	love.graphics.setBackgroundColor(220, 220, 220)
	love.graphics.setLineWidth(5)
	love.graphics.setColor(0, 0, 0)
	love.graphics.line(unpack(shape))
end


