class Player

	#A new player gets dealt cards from a deck
	def initialize (deck)
		@hand = 2.times.map {deck.draw_card}

		@folded = false
		@playing = true

	end

	def fold
		@folded = true
	end

end
