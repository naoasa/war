# frozen_string_literal: true

# プレイヤーの責務
class Player
  attr_reader :name
  attr_accessor :cards, :battle, :battles, :sub_cards

  def initialize(name)
    @name = name # プレイヤーは名前を持つ
    @cards = [] # プレイヤーは手札を持つ
    @battle = nil # プレイヤーは対戦カードを持つ
    @battles = [] # プレイヤーは対戦カードたちを持つ
    @sub_cards = [] # プレイヤーは手元にサブカードを持つ
  end
end

# ゲーム進行の責務
class Game
  attr_reader :num_players, :player_names, :player1, :player2

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
      @player1 = @player_names[0]
      @player2 = @player_names[1]
      # 各プレイヤーに持ちカードを分割して配る
      @player1.cards = cards.all_cards.slice(0, cards_per_player)
      @player2.cards = cards.all_cards.slice(cards_per_player, cards_per_player)
    end

    puts "カードが配られました。"
  end

  def war # 戦争ゲームを開始する
    # 戦争の終了条件: 参加プレイヤーのいずれかの手札が0になる => いずれの手札も0ではない間(=true)繰り返す
    while @player1.cards.any? && @player2.cards.any?
      puts "戦争！"

      # プレイヤー1の手札からカードを1枚引き、プレイヤー1のバトル場に移動させる
      @player1.battles << @player1.cards.shift # 手札の先頭の要素を抽出し、battlesの最後に要素を追加する
      @player1.battle = @player1.battles.last

      # プレイヤー2の手札からカードを1枚引き、プレイヤー2のバトル場に移動させる
      @player2.battles << @player2.cards.shift # 手札の先頭の要素を抽出し、battlesの最後に要素を追加する
      @player2.battle = @player2.battles.last

      # カード情報の出力
      puts "#{@player1.name}のカードは#{@player1.battle.show_card}です。"
      puts "#{@player2.name}のカードは#{@player2.battle.show_card}です。"

      # 数字を比較して、大きい方が勝利
      if @player1.battle.num > @player2.battle.num
        puts "#{@player1.name}が勝ちました。#{@player1.name}はカードを#{@player1.battles.length + @player2.battles.length}枚もらいました。"
        # 2プレイヤーのバトル場のカードを全てプレイヤー1のサブカードに移動させる
        @player1.sub_cards.concat(@player1.battles) # サブカード配列にバトル場配列を連結させる
        @player1.battles.clear # バトル場配列を空にする

        @player1.sub_cards.concat(@player2.battles) # サブカード配列にバトル場配列を連結させる
        @player2.battles.clear # バトル場配列を空にする
      elsif @player1.battle.num < @player2.battle.num
        puts "#{@player2.name}が勝ちました。#{@player2.name}はカードを#{@player1.battles.length + @player2.battles.length}枚もらいました。"
        # 2プレイヤーのバトル場のカードを全てプレイヤー1のサブカードに移動させる
        @player2.sub_cards.concat(@player1.battles) # サブカード配列にバトル場配列を連結させる
        @player1.battles.clear # バトル場配列を空にする

        @player2.sub_cards.concat(@player2.battles) # サブカード配列にバトル場配列を連結させる
        @player2.battles.clear # バトル場配列を空にする
      else
        puts "引き分けです。"
      end

      # 手札が空になった場合に手札を増やすメソッドを実行
      sub_cards_to_cards

      # puts "プレイヤー1: 手札#{@player1.cards.length}, サブカード#{@player1.sub_cards.length}, バトル場#{@player1.battles.length}"
      # puts "プレイヤー2: 手札#{@player2.cards.length}, サブカード#{@player2.sub_cards.length}, バトル場#{@player2.battles.length}"
    end # while文のend

    add_cards_before_result # 全てのサブカードを手札に移す
    show_result # 勝利を判定し、勝負の結果を出力する
  end # warメソッドのend

  def sub_cards_to_cards # 手札が0になった場合、サブカードから手札にカードを移動させる
    if @player1.cards.empty? # 手札が空の場合
      @player1.cards.concat(@player1.sub_cards.shuffle)
      @player1.cards.shuffle! # 手札を破壊的にシャッフルする
      @player1.sub_cards.clear # サブカード配列を空にする
    end

    if @player2.cards.empty? # 手札が空の場合
      @player2.cards.concat(@player2.sub_cards)
      @player2.cards.shuffle! # 手札を破壊的にシャッフルする
      @player2.sub_cards.clear # サブカード配列を空にする
    end
  end

  def add_cards_before_result # 結果発表前に、サブカードから手札にカードを移動させる
    @player_names.each do |player|
      player.cards.concat(player.sub_cards)
      player.sub_cards.clear
    end
  end

  def show_result # 勝利を判定し、勝負の結果を出力する
    if @player1.cards.empty?
      loser = @player1
    else
      loser = @player2
    end

    # プレイヤーを手札の多い順に並べ替える
    sorted_players = @player_names.sort_by { |player| -player.cards.length } # 手札枚数の降順

    puts "#{loser.name}の手札がなくなりました。"
    puts "#{@player1.name}の手札の枚数は#{@player1.cards.length}枚です。#{@player2.name}の手札の枚数は#{@player2.cards.length}枚です。"

    rank1_player = sorted_players[0]
    rank2_player = sorted_players[1]

    puts "#{rank1_player.name}が1位、#{rank2_player.name}が2位です。"
    puts "戦争を終了します。"
  end
end

# カードの責務
class Card
  attr_reader :suit, :num

  def initialize(suit, num)
    @suit = suit # 絵柄を持つ
    @num = num # 数字を持つ
  end

  def show_card # カードの絵柄と数字を返す
    # 絵柄
    case @suit
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
    case @num
    when 11
      num = "J"
    when 12
      num = "Q"
    when 13
      num = "K"
    when 14
      num = "A"
    else
      num = @num
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
cards = Cards.new # Cardsクラスのインスタンスを生成
cards.create_cards # 52枚のカードを生成
game.deal_cards(cards) # プレイヤーにカードを配る
game.war # ゲームを開始
