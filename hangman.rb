require 'yaml'
require 'pry-byebug'

class NewGame
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
    puts @hidden_secret_word.join(' ')
  end

  def make_a_guess
    puts 'Write your guess or write "save" to save the game'
    puts
    @guess = gets.chomp.downcase
    until check_if_valid_guess(@guess)
      puts 'Invalid guess. Please enter a letter or "save" to save the game'
      puts
      @guess = gets.chomp.downcase
    end
    @guess
  end

  def check_if_valid_guess(guess)
    if (guess.length == 1 && guess.match(/[a-z]/)) || guess == 'save'
      if @hidden_secret_word.include?(guess) || @wrong_letters.include?(guess)
        puts 'You already tried this letter'
        puts
        false
      else
        true
      end
    else
      false
    end
  end

  def check_guess(guess)
    number_of_appearances = @secret_word.count(guess)
    if number_of_appearances != 0
      puts 'Correct'
      puts
      while number_of_appearances.positive?
        index = @secret_word.index(guess)
        @secret_word[index] = ''
        @hidden_secret_word[index] = guess.clone
        number_of_appearances -= 1
      end
    else
      puts 'Sorry, the guess is incorrect.'
      puts
			@remaining_tries -= 1
      @wrong_letters.push(guess)
    end
  end

  def did_the_game_end?
    if @secret_word_copy == @hidden_secret_word
      puts 'Yay! You won!'
      puts
      check_if_play_again
    end

    if @remaining_tries.zero?
      puts "You lost. The word was #{@secret_word_copy.join}."
      puts
      check_if_play_again
    end
  end

  def check_if_play_again
    puts 'Do you wanna play again? y/n'
    answer = gets.chomp.downcase
    until %w[y n].include?(answer)
      puts 'Please answer with y or n'
      answer = gets.chomp.downcase
    end

    if answer == 'y'
      if show_begin_menu == 1
        reset_game
      else
        choose_game_to_load
      end
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

  def save_game
    yaml = YAML.dump(self)
    puts 'Name your save:'
    game_file_name = gets.chomp.downcase
    while File.exist?("#{game_file_name}.yml")
      puts 'The file already exists. Please enter another name'
      game_file_name = gets.chomp.downcase
    end

    game_file = File.new("#{game_file_name}.yml", 'w+')
    game_file.write(yaml)
    game_file.close
    puts "Your game was saved in the '#{game_file_name}.yml' file"
  end

  def play
    did_the_game_end?
    show_hidden_word
    @guess = make_a_guess
    if @guess == 'save'
      save_game
      check_if_play_again
      return
    end
    check_guess(@guess)
    puts "Remaining tries:#{@remaining_tries}."
    puts "Wrong letters: #{@wrong_letters.uniq.join(', ')}"
    puts
    play
  end
end

def choose_game_to_load
  puts 'These are all the saved games:'
  Dir.glob('*.{yml}').each_with_index do |file, index|
    puts "(#{index + 1}) #{file}"
  end
  puts 'Choose the game you want to load'
  chosen_game = gets.chomp.downcase

  until chosen_game.match(/\d+/) && chosen_game.to_i <= Dir.glob('*.{yml}').length
    puts 'Please choose a number corresponding to the file you want to open'
    chosen_game = gets.chomp.downcase
  end

  Dir.glob('*.{yml}').each_with_index do |file, index|
    load_game(file) if index + 1 == chosen_game.to_i
  end
end

def load_game(game)
  loaded_game = File.open(game, 'r')
  yaml = YAML.load(loaded_game)
  loaded_game.close
  yaml.play
end

def show_begin_menu
  puts "Let's play Hangman! \n(1) Start new game \n(2) Load game"
  choice = gets.chomp

  until %w[1 2].include?(choice)
    puts 'Invalid input. Please enter 1 or 2'
    choice = gets.chomp
  end
  choice
end

if show_begin_menu == '1'
  NewGame.new
else
  choose_game_to_load
end
