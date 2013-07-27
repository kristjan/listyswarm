class GameController < ApplicationController
  def index
  end

  def tick
    tick = params[:id]

    game_dir  = Dir.entries("games").last
    tick_file = (tick.to_i+1).to_s.rjust(10, '0')
    path = "../games/#{game_dir}/#{tick_file}"

    render text: File.read(path)
  end
end
