class Player

	#A new player gets dealt cards from a deck
	def initialize (deck)
		@hand = 2.times.map {deck.draw_card}

		@folded = false
		@alive = true

	end

	def hand_populate (array)
		@hand = []
		array.each {|card| @hand<<card}
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

	def best_combo (board)
		all_combos = self.possible_hands(board)
		strongest_hand_strength = all_combos[0][:hand_strength]

		if strongest_hand_strength > all_combos[1][:hand_strength]
			best_combo = all_combos[0]
		else
			top_combos = []
			counter = 0

			while all_combos[counter][:hand_strength] == strongest_hand_strength
				top_combos << all_combos[counter]
				counter = counter + 1
			end

			top_combos.sort {|y,x| @garrett.universal_tie_breaker(x,y)<=>@garrett.universal_tie_breaker(y,x) }
			top_combos[0]
		end
	end

	def universal_tie_breaker(hand_result_1, hand_result_2)
		if hand_result_1[:hand_strength] == 9 || hand_result_1[:hand_strength] == 5
			result = self.straights_tie_breaker(hand_result_1, hand_result_2)
		end

		result
	end

	def possible_hands (board)
		result = []
		self.combos(board).each_with_index do |five_card_hand, index|
			while true
				hand_rating = self.straight_flush(five_card_hand)
				break if hand_rating[:status] == true

				hand_rating = self.four_of_a_kind(five_card_hand)
				break if hand_rating[:status] == true

				hand_rating = self.full_house(five_card_hand)
				break if hand_rating[:status] == true

				hand_rating = self.flush(five_card_hand)
				break if hand_rating[:status] == true

				hand_rating = self.straight(five_card_hand)
				break if hand_rating[:status] == true

				hand_rating = self.three_of_a_kind(five_card_hand)
				break if hand_rating[:status] == true

				hand_rating = self.two_pair(five_card_hand)
				break if hand_rating[:status] == true

				hand_rating = self.pair(five_card_hand)
				break if hand_rating[:status] == true

				hand_rating = self.highcard(five_card_hand)
				break
			end

			result << hand_rating
		end
		result.sort {|x,y| y[:hand_strength]<=>x[:hand_strength]}
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


	def straight_flush (five_card_hand)
		has_straight_flush = {:name => "straight flush", :hand_strength => 9, :status=>false, :straight_highcard => nil}
		has_straight_flush[:status] = straight(five_card_hand)[:status] && flush(five_card_hand)[:status]
		has_straight_flush[:straight_highcard] = straight(five_card_hand)[:straight_highcard]

		has_straight_flush
	end

	#Returns 0 if hand_result_2 beats hand_result_1, 1 if hand_result_1 beats hand_result_2, and "tie" if tie
	def straights_tie_breaker (hand_result_1,hand_result_2)
		if hand_result_2[:straight_highcard] > hand_result_1[:straight_highcard]
			result = 0
		elsif hand_result_2[:straight_highcard] < hand_result_1[:straight_highcard]
			result = 1
		elsif hand_result_2[:straight_highcard] == hand_result_1[:straight_highcard]
			result = "tie"
		end
		result
	end

	#checks if a hand has four of a kind, returns a hash
	def four_of_a_kind (five_card_hand)

		has_four_of_a_kind = {:name => "four of a kind", :hand_strength => 8,:status=>false, :quad_rank=> nil, :kicker => nil}

		hand_ranks = numberfy(five_card_hand)

		if hand_ranks.uniq.length == 2
			if (hand_ranks-[ hand_ranks.uniq[0] ] ).length == 1
				has_four_of_a_kind[:kicker] = (hand_ranks-[ hand_ranks.uniq[0] ] )[0]
				has_four_of_a_kind[:quad_rank] = (hand_ranks-[ hand_ranks.uniq[1] ] )[0]
				has_four_of_a_kind[:status] = true

			elsif (hand_ranks-[ hand_ranks.uniq[0] ] ).length == 4
				has_four_of_a_kind[:kicker] = (hand_ranks-[ hand_ranks.uniq[1] ] )[0]
				has_four_of_a_kind[:quad_rank] = (hand_ranks-[ hand_ranks.uniq[0] ] )[0]
				has_four_of_a_kind[:status] = true
			end
		end

		has_four_of_a_kind
	end

	#Returns 0 if hand_result_2 beats hand_result_1, 1 if hand_result_1 beats hand_result_2, and "tie" if tie
	def four_of_a_kind_tie_breaker (hand_result_1,hand_result_2)
		if hand_result_2[:quad_rank] > hand_result_1[:quad_rank]
			result = 0
		elsif hand_result_2[:quad_rank] < hand_result_1[:quad_rank]
			result = 1
		elsif hand_result_2[:quad_rank] == hand_result_1[:quad_rank]
			result = "tie"
		end
		result
	end


	def full_house (five_card_hand)

		has_full_house = {:name => "full_house", :hand_strength => 7,:status=>false, :trip_rank=> nil, :pair_rank => nil}

		hand_ranks = numberfy(five_card_hand)

		if hand_ranks.uniq.length == 2
			if (hand_ranks-[ hand_ranks.uniq[0] ] ).length == 2
				has_full_house[:pair_rank] = (hand_ranks-[ hand_ranks.uniq[0] ] )[0]
				has_full_house[:trip_rank] = (hand_ranks-[ hand_ranks.uniq[1] ] )[0]
				has_full_house[:status] = true

			elsif (hand_ranks-[ hand_ranks.uniq[0] ] ).length == 3
				has_full_house[:pair_rank] = (hand_ranks-[ hand_ranks.uniq[1] ] )[0]
				has_full_house[:trip_rank] = (hand_ranks-[ hand_ranks.uniq[0] ] )[0]
				has_full_house[:status] = true
			end
		end

		has_full_house
	end


	#tests if hand is a flush, gives back a hash
	def flush (five_card_hand)
		has_flush = {:name => "flush", :hand_strength => 6,:status=>false, :highcard => nil, :kickers => nil}

		suitify = five_card_hand.map do |card|
			if card.slice(0..1) == "10"
				card.slice(2)
			else
				card.slice(1)
			end
		end

		has_flush[:status] = true if suitify.uniq.length == 1

		hand_ranks = numberfy(five_card_hand)
		has_flush[:highcard] = hand_ranks[0]
		has_flush[:kickers] = hand_ranks.slice(1..4)

		has_flush
	end

	#checks if a hand has a straight, returns a hash
	def straight (five_card_hand)

		has_straight = {:name => "straight", :hand_strength => 5,:status=>false, :straight_highcard => nil}
		straight_possibilities = straight_numberfy(five_card_hand)

		straight_possibilities.each do |hand|
			low_to_high = (hand.min..hand.max).to_a

			if low_to_high == hand.sort
				has_straight[:status] = true
				has_straight[:straight_highcard] = hand.max.to_i
			end
		end
		has_straight
	end

	#checks if a hand has three of a kind, returns a hash
	def three_of_a_kind (five_card_hand)

		has_three_of_a_kind = {:name => "three of a kind", :hand_strength => 4,:status=>false, :trip_rank=> nil, :kickers => nil}

		hand_ranks = numberfy(five_card_hand)

		if hand_ranks.uniq.length == 3
			hand_ranks.each do |card_rank|
				reduced_hand = hand_ranks - [card_rank]
				if reduced_hand.length == 2
					has_three_of_a_kind[:status] = true
					has_three_of_a_kind[:trip_rank] = card_rank
					has_three_of_a_kind[:kickers] = reduced_hand.sort {|x,y| y<=>x}
					break
				end
			end
		end
		has_three_of_a_kind
	end

	def two_pair (five_card_hand)

		has_two_pair = {:name => "two pair", :hand_strength => 3,:status=>false, :higher_pair_rank=> nil, :lower_pair_rank=> nil, :kicker => nil}

		hand_ranks = numberfy(five_card_hand)

		if hand_ranks.uniq.length == 3
			hand_ranks.each do |card_rank|
				reduced_hand = hand_ranks - [card_rank]
				if reduced_hand.length == 3 && reduced_hand.uniq.length == 2
					has_two_pair[:status] = true
					first_pair = card_rank
					#find the second pair and kicker
					if (reduced_hand - [ reduced_hand.uniq[0] ]).length == 1
						second_pair = reduced_hand.uniq[0]
						has_two_pair[:kicker] = (reduced_hand - [ reduced_hand.uniq[0] ])[0]
					else
						second_pair = reduced_hand.uniq[1]
						has_two_pair[:kicker] = (reduced_hand - [ reduced_hand.uniq[1] ])[0]
					end
					#which pair is higher
					if first_pair > second_pair
						has_two_pair[:higher_pair_rank] = first_pair
						has_two_pair[:lower_pair_rank] = second_pair
					else
						has_two_pair[:higher_pair_rank] = second_pair
						has_two_pair[:lower_pair_rank] = first_pair
					end
					break
				end
			end
		end
		has_two_pair
	end

	def pair (five_card_hand)
		has_pair = {:name => "pair", :hand_strength => 2,:status => false, :pair_rank => nil, :kickers => nil}
		hand_ranks = numberfy(five_card_hand)
		if hand_ranks.uniq.length == 4
			hand_ranks.each do |card_rank|
				reduced_hand = hand_ranks - [card_rank]
				if reduced_hand.length == 3
					has_pair[:status] = true
					has_pair[:pair_rank] = card_rank
					has_pair[:kickers] = reduced_hand.sort {|x,y| y<=>x}
					break
				end
			end
		end
		has_pair
	end

	def highcard (five_card_hand)
		hand_highcard = {:name => "high card", :hand_strength => 1,:highcard => nil, :kickers => nil}

		hand_ranks = numberfy(five_card_hand)
		hand_highcard[:highcard] = hand_ranks[0]
		hand_highcard[:kickers] = hand_ranks.slice(1..4)

		hand_highcard
	end

end
