class Game
  @@words_list = File.read('word_list')
  @@words_list = @@words_list.split

  def find_secret_word
    word = ''
    word = @@words_list.sample until word.length >= 5 && word.length <= 12
    word
  end

  def initialize
    @secret_word = find_secret_word.split('')
    @secret_word_copy = @secret_word.clone
    @hidden_secret_word = Array.new(@secret_word.length, '_')
    @wrong_letters = []
    @remaining_tries = 10
    play
  end

  def show_hidden_word
    puts @hidden_secret_word.join
  end

  def make_a_guess
    puts 'Write your guess or write "save" to save the game'
    @guess = gets.chomp
  end

  def check_guess(guess)
    number_of_appearances = @secret_word.count(guess)
    if number_of_appearances != 0
      while number_of_appearances.positive?
        puts 'Correct'
        index = @secret_word.index(guess)
        @secret_word[index] = ''
        @hidden_secret_word[index] = guess
        number_of_appearances -= 1
      end
    else
      puts 'Sorry, the guess is incorrect.'
      @wrong_letters.push(guess)
    end
  end

  def did_the_game_end?
    if @secret_word_copy == @hidden_secret_word
      puts 'Yay! You won!'
      check_if_play_again
    end

    if @remaining_tries.zero?
      puts "You lost. The word was #{@secret_word_copy.join}."
      check_if_play_again
    end
  end

  def check_if_play_again
    puts 'Do you wanna play again? y/n'
    answer = gets.chomp
    if answer == 'y'
      reset_game
    else
      puts 'Ok bye!'
    end
  end

  def reset_game
    @secret_word = find_secret_word.split('')
    @secret_word_copy = @secret_word.clone
    @hidden_secret_word = Array.new(@secret_word.length, '_')
    @wrong_letters = []
    @remaining_tries = 10
    play
  end

  def play
    did_the_game_end?
    show_hidden_word
    @guess = make_a_guess
    check_guess(@guess)
    @remaining_tries -= 1
    if did_the_game_end?
      nil
    else
      puts "Remaining tries:#{@remaining_tries}."
      puts "Tried letters: #{@wrong_letters.uniq.join(', ')}"
      play
    end
  end
end

puts "Let's play Hangman! Do you want to start a new game(1) or load a previous game(2)?"

choice = gets.chomp
Game.new if choice == '1'
