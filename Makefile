.PHONY: love clean

TITLE=SuperRollingBall

clean:
	rm *.love

# This is how to make love.
love: $(TITLE).love

# Love is zipped.
${TITLE}.love: *.lua
	zip -9 -q -r $(TITLE).love .

