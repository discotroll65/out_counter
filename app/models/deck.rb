# Top 15 Hold'em Starting Hands
# AA
# KK
# QQ
# AK (suited)
# JJ
# 1010
# AQ (suited)
# AJ (suited)
# AK (off suit)
# KQ (suited)
# A10 (suited)
# KJ (suited)
# AQ (off suit)
# 99
# JQ (suited)

class Deck

  def initialize
    #build a full deck
    @full_deck_array = []

    build_suite("s")
    build_suite("c")
    build_suite("h")
    build_suite("d")

    @playing_deck = @full_deck_array
  end


  #takes a string character, one for each suite (s = spades, c = clubs, h = heart, d = diamond)
  def build_suite (letter)
    suite = []

    2.upto(10) do |value|
      suite << "#{value.to_s+letter}"
    end

    suite << "#{'J'+letter}"
    suite << "#{'Q'+letter}"
    suite << "#{'K'+letter}"
    suite << "#{'A'+letter}"

    suite.each {|card| @full_deck_array << card}
  end


  #generates a random number, uses it to select a card, removes that card from the deck
  #Returns the card that was drawn
  def draw_card
    cards_in_deck = @playing_deck.length - 1
    draw_num = rand(0..cards_in_deck)
    card = @playing_deck[draw_num]
    @playing_deck = @playing_deck - [@playing_deck[draw_num]]

    card
  end

  def how_many
    @playing_deck.length
  end

end
