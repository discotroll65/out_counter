class Player

	#A new player gets dealt cards from a deck
	def initialize (deck)
		@hand = 2.times.map {deck.draw_card}

		@folded = false
		@alive = true

	end

	def fold
		@folded = true
	end

	def folded?
		@folded
	end

	def playing?
		@alive
	end

	def hand
		@hand
	end

	def combos (board)
		board_amount = board.cards.length

		if board_amount == 3
			[board.cards + self.hand]
		elsif board_amount == 4

			[ board.cards[0..2] + self.hand,
				board.cards[1..3] + self.hand,
				[board.cards[0]] + [board.cards[2]] + [board.cards[3]] + self.hand,
				[board.cards[0]] + [board.cards[1]] + [board.cards[3]] + self.hand
				]

		elsif board_amount == 5

			[ board.cards[0..2] + self.hand,
				[board.cards[0]] + [board.cards[1]] + [board.cards[3]] + self.hand,
				[board.cards[0]] + [board.cards[2]] + [board.cards[3]] + self.hand,
				board.cards[1..3] + self.hand,

				[board.cards[0]] + [board.cards[1]] + [board.cards[4]] + self.hand,
				[board.cards[0]] + [board.cards[2]] + [board.cards[4]] + self.hand,
				[board.cards[1]] + [board.cards[2]] + [board.cards[4]] + self.hand,

				[board.cards[0]] + [board.cards[3]] + [board.cards[4]] + self.hand,
				[board.cards[1]] + [board.cards[3]] + [board.cards[4]] + self.hand,

				board.cards[2..4] + self.hand
				]
		end

	end
end
