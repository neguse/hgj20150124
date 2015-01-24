.PHONY: love

TITLE=SuperRollingBall

# This is how to make love.
love: $(name).love

# Love is zipped.
${name}.love: *.lua
	zip -9 -q -r $(name).love .

