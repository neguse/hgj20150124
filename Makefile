.PHONY: love

TITLE=SuperRollingBall

# This is how to make love.
love: $(TITLE).love

# Love is zipped.
${TITLE}.love: *.lua
	zip -9 -q -r $(TITLE).love .

