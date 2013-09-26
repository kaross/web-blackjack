require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do
  def best_value(hand)
    sum = 0
    aces = 0
    hand.each do |card|
      if card[1] == 'A'
        sum += 11
        aces += 1
      elsif card[1] == 'J' || card[1] == 'Q' || card[1] == 'K'
        sum += 10
      else
        sum += card[1].to_i
      end
    end

    while sum > 21 and aces > 0
      sum -= 10
      aces -= 1
    end

    sum
  end

  def show_card(card)
    case card[0]
    when 'C' 
      suit = 'clubs'
    when 'D' 
      suit = 'diamonds'
    when 'H' 
      suit = 'hearts'
    else 
      suit = 'spades'
    end

    case card[1]
      when 'A' 
        face = 'ace'
      when 'J' 
        face = 'jack'
      when 'Q' 
        face = 'queen'
      when 'K' 
        face = 'king'
      else 
        face = card[1].to_i
    end

    "<img src='/images/cards/#{suit}_#{face}.jpg' class='image-rounded'>"
  end
end

get '/' do
  if session[:username]
    session[:balance] = 500
    redirect '/take_bet'
  else
    redirect '/get_name'
  end
end

get '/get_name' do
  erb :get_name
end

post '/store_name' do
  if params['username'].empty? || params['username'].to_i != 0
    @error = "Must enter a name"
    halt erb :get_name
  end

  session[:username] = params['username']
  session[:balance] = 500
  redirect '/take_bet'
end

get '/take_bet' do
  if session[:balance] < 5
    redirect '/quit'
  end

  erb :take_bet
end

post '/take_bet' do
  if params['bet'].empty? || params['bet'].to_i < 5 || params['bet'].to_i > session[:balance].to_i
    @error = "Please enter a valid bet"
    halt erb :take_bet
  end
  
  session[:bet] = params['bet'].to_i
  session[:balance] -= session[:bet]
  redirect '/game'
end

get '/game' do
  suits = ['S', 'H', 'C', 'D']
  face = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
  session[:deck] = suits.product(face).shuffle!

  session[:player_cards] = []
  session[:dealer_cards] = []

  2.times do
    session[:dealer_cards] << session[:deck].pop
    session[:player_cards] << session[:deck].pop
  end

# session[:player_cards] = [['S', 'A'],['S','J']]

  # My understanding is that the automatic win rules for hitting 21 only apply during the first
  # round before any hits, so do it here.
  # For simplicity, we just give player blackjack to the player regardless of the dealer.
  if best_value(session[:player_cards]) == 21
    session[:player_stay] = true
    @show_player_options = false
    @show_dealer_turn = false
    @show_play_again = true
    @success = 'Congratulations, you hit Blackjack!'
    session[:balance] += (session[:bet] * 2.5).round
  elsif best_value(session[:dealer_cards]) == 21
    session[:player_stay] = true
    @show_player_options = false
    @show_dealer_turn = false
    @show_play_again = true
    @error = 'Dealer Blackjack! Sorry, you lose.'
  else
    session[:player_stay] = false
    @show_player_options = true
    @show_dealer_turn = false
  end 

  erb :game
end

post '/hit' do
  session[:player_cards] << session[:deck].pop
  if best_value(session[:player_cards]) > 21
    @error = "Sorry, you busted on this hand."
    @show_play_again = true
    @show_player_options = false
    @show_dealer_turn = false
  else 
    @show_player_options = true
    @show_dealer_turn = false
  end

  erb :game
end

post '/stay' do
  @msg = "You've chosen to stay, it is the dealer's turn."
  session[:player_stay] = true

  redirect '/dealer_turn'
end

get '/dealer_turn' do
  if best_value(session[:dealer_cards]) > 21
    @dealer_status = "and has busted!"
  elsif best_value(session[:dealer_cards]) < 17
    @dealer_status = "and will hit"
  else
    @dealer_status = "and will stay"
  end

  @show_dealer_turn = true
  @show_player_options = false
  erb :game
end

post '/dealer_turn' do
  if best_value(session[:dealer_cards]) < 17
    session[:dealer_cards] << session[:deck].pop
    redirect '/dealer_turn'
  else
    redirect '/results'
  end
end

get '/results' do
  @show_player_options = false
  @show_dealer_turn = false

  # Player bust was dealt with during player turn.
  if best_value(session[:dealer_cards]) > 21 
    @success = "Congratulations, you won!"
    session[:balance] += session[:bet] * 2
  elsif best_value(session[:dealer_cards]) > best_value(session[:player_cards])
    @error = "Sorry, the dealer wins!"
  elsif best_value(session[:dealer_cards]) < best_value(session[:player_cards])
    @success = "Congratulations, you won!"
    session[:balance] += session[:bet] * 2
  else
    @msg = "The hands are equal - push!"
    session[:balance] += session[:bet]    
  end

  @show_play_again = true
  erb :game
end

get '/quit' do
  erb :quit
end

post '/quit' do
  erb :quit
end

