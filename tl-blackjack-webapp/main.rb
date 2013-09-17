require 'rubygems'
require 'sinatra'

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
end

get '/' do
  if session[:username]
    redirect '/game'
  else
    redirect '/get_name'
  end
end

get '/get_name' do
  erb :get_name
end

post '/store_name' do
  session[:username] = params['username']
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

#  session[:player_cards] = [['S', 'A'],['S','J']]

  @show_player_options = true
  erb :game
end

post '/hit' do
  session[:player_cards] << session[:deck].pop
  if best_value(session[:player_cards]) > 21
    @error = "Sorry, you busted on this hand."
    @show_player_options = false
  else 
    @show_player_options = true
  end

  erb :game
end

post '/stay' do
  @msg = "You've chosen to stay, it is the dealer's turn."
  @show_player_options = false
  erb :game
end
