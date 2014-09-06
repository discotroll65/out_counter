class Board
  def initialize
    @board = []
  end

  def flop (deck)
    3.times {@board << deck.draw_card}
  end

  def turn (deck)
    @board << deck.draw_card
  end

  def river (deck)
    @board << deck.draw_card
  end
end
