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

	#combines hand with all possible 5 card combinations using the board
	def combos (board)
		board_amount = board.cards.length

		if board_amount == 3
			[board.cards + self.hand]
		elsif board_amount == 4

			board_combos = [ board.cards[0..2],
											 board.cards[1..3],
											 [board.cards[0]] + [board.cards[2]] + [board.cards[3]],
											 [board.cards[0]] + [board.cards[1]] + [board.cards[3]]
											 ]
			board_combos.map { |combo| combo + self.hand }

		elsif board_amount == 5

			board_combos = [ board.cards[0..2],
											 [board.cards[0]] + [board.cards[1]] + [board.cards[3]],
											 [board.cards[0]] + [board.cards[2]] + [board.cards[3]],
											 board.cards[1..3],

											 [board.cards[0]] + [board.cards[1]] + [board.cards[4]],
											 [board.cards[0]] + [board.cards[2]] + [board.cards[4]],
											 [board.cards[1]] + [board.cards[2]] + [board.cards[4]],

											 [board.cards[0]] + [board.cards[3]] + [board.cards[4]],
											 [board.cards[1]] + [board.cards[3]] + [board.cards[4]],

											 board.cards[2..4]
											 ]
			board_combos.map { |combo| combo + self.hand }
		end
	end


	def straight_flush (five_card_hand)
		has_straight_flush = [false,nil]
		has_straight_flush[0] = straight(five_card_hand)[0] && flush(five_card_hand)[0]
		has_straight_flush[1] = straight(five_card_hand)[1]

		has_straight_flush
	end

	#tests if hand is a flush, gives back an array; true/false if flush,
	#and ordered list of rank, highest first
	def flush (five_card_hand)
		suitify = five_card_hand.map do |card|
			if card.slice(0..1) == "10"
				card.slice(2)
			else
				card.slice(1)
			end
		end

		has_flush = [false,nil]
		has_flush[0] = true if suitify.uniq.length == 1
		has_flush[1] = numberfy(five_card_hand)

		has_flush
	end

	#checks if a hand has a straight, returns an array
	#first value is true/false if the hand is an array
	#second value, if hand is a straight, is the high card of the straight
	def straight (five_card_hand)

		has_straight = [false,nil]

		possibilities = straight_numberfy(five_card_hand)

		possibilities.each do |hand|
			low_to_high = (hand.min..hand.max).to_a

			if low_to_high == hand.sort
				has_straight[0] = true
				has_straight[1] = hand.max.to_i
			end
		end
		has_straight
	end

	#takes hand, turns royals into numbers, handles aces
	#gives an array of hands - 2 hands if there is an ace,
	# one hand if there is no ace
	def straight_numberfy (five_card_hand)
		numbered_hands = [ [], [] ]

		five_card_hand.map do |card|

			if card.slice(0) == 'J'
				numbered_hands[0] << 11
				numbered_hands[1] << 11
			elsif card.slice(0) == 'Q'
				numbered_hands[0] << 12
				numbered_hands[1] << 12
			elsif card.slice(0) == 'K'
				numbered_hands[0] << 13
				numbered_hands[1] << 13
			elsif card.slice(0) == 'A'
				numbered_hands[0] << 1
				numbered_hands[1] << 14
			elsif card.slice(0..1) == '10'
				numbered_hands[0] << 10
				numbered_hands[1] << 10
			else
				numbered_hands[0] << card.slice(0).to_i
				numbered_hands[1] << card.slice(0).to_i
			end
		end

		#get rid of the second set if there are no Aces
		numbered_hands.pop unless five_card_hand.map {|card| card.slice(0)}.include? 'A'

		#return numbered_hands
		numbered_hands
	end

	#handles royals, turns ace to 14
	def numberfy(five_card_hand)

		numbered_hand = [ ]
		#are there any aces?

		five_card_hand.each do |card|

			if card.slice(0) == 'J'
				numbered_hand << 11
			elsif card.slice(0) == 'Q'
				numbered_hand << 12
			elsif card.slice(0) == 'K'
				numbered_hand << 13
			elsif card.slice(0) == 'A'
				numbered_hand << 14
			elsif card.slice(0..1) == '10'
				numbered_hand << 10
			else
				numbered_hand << card.slice(0).to_i
			end
		end
		numbered_hand.sort {|x,y| y<=>x}
	end

end
