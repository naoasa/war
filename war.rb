# frozen_string_literal :true

require "debug"

# プレイヤーの責務
class Player
  attr_reader :name
  attr_accessor :cards

  def initialize(name)
    @name = name # プレイヤーは名前を持つ
    @cards = [] # プレイヤーはカードの集まりを持つ
  end
end

# ゲーム進行の責務
class Game
  attr_reader :num_players, :player_names

  def initialize(num_players)
    @num_players = num_players # プレイヤー数を把握する
    @player_names = [] # プレイヤー名を把握する
  end

  def add_player_name(name) # プレイヤー名を追加する
      @player_names << Player.new(name) # Playerクラスのインスタンスに引数を渡し、配列に格納
  end

  def deal_cards(cards) # プレイヤーにカードを配る
    # puts cards.all_cards.length => 52
    # puts cards.all_cards.length / @num_players => 26
    cards_per_player = cards.all_cards.length / @num_players # 1人あたりのカード数
    # カードをシャッフルする
    cards.all_cards.shuffle! # 破壊的に配列の要素をシャッフル
    # 1人あたりのカード数だけ、プレイヤーにカードを配布する
    case @num_players
    when 2 # プレイヤーが2人の場合
      # 各プレイヤーを取得
      player1 = @player_names[0]
      player2 = @player_names[1]
      # 各プレイヤーに持ちカードを分割して配る
      player1.cards = cards.all_cards.slice(0, cards_per_player)
      player2.cards = cards.all_cards.slice(cards_per_player, cards_per_player)
    end

    puts "カードが配られました。"
  end
end

# カードの責務
class Card
  attr_reader :suit, :num

  def initialize(suit, num)
    @suit = suit # 絵柄を持つ
    @num = num # 数字を持つ
  end

  def show_card(card) # カードの絵柄と数字を返す
    # 絵柄
    case card.suit
    when "spade"
      suit = "スペード"
    when "diamond"
      suit = "ダイヤ"
    when "club"
      suit = "クラブ"
    when "heart"
      suit = "ハート"
    end

    # 数字
    case card.num
    when 11
      num = "J"
    when 12
      num = "Q"
    when 13
      num = "K"
    when 14
      num = "A"
    else
      num = card.num
    end

    # 返す文字列
    "#{suit}の#{num}"
  end
end

# カードの集まりの責務
class Cards
  attr_reader :all_cards

  def initialize
    @all_cards = [] # カードの集まりを持つ
  end

  def create_cards # 52枚のカードの集まりを生成(絵柄4種類 * 数字13種類 => 52枚)
    i = 2
    while i <= 14
      card_s = Card.new("spade", i)
      card_d = Card.new("diamond", i)
      card_c = Card.new("club", i)
      card_h = Card.new("heart", i)
      @all_cards.push(card_s)
      @all_cards.push(card_d)
      @all_cards.push(card_c)
      @all_cards.push(card_h)
      i += 1
    end
  end
end

# 実行

puts "戦争を開始します。"
game = Game.new(2) # プレイヤー数は2人
game.add_player_name("プレイヤー1") # プレイヤー1を生成
game.add_player_name("プレイヤー2") # プレイヤー2を生成
game.player_names.each do |name|
  puts "プレイヤー名: #{name.name}"
end
cards = Cards.new # Cardsクラスのインスタンスを生成
cards.create_cards # 52枚のカードを生成
# cards.all_cards.each do |card|
#   puts "#{card.show_card(card)}は、絵柄が#{card.suit}で強さが#{card.num}のカードです"
# end
game.deal_cards(cards)
# binding.b