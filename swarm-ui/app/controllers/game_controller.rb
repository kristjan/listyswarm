class GameController < ApplicationController
  def index
  end

  def tick
    game_id = params[:game_id]
    tick_id = params[:id]

    game_dir  = (game_id.to_i).to_s.rjust(10, '0')
    tick_file = (tick_id.to_i+1).to_s.rjust(10, '0')
    @max_ticks = Dir.entries("../games/#{game_dir}/").count

    path = "../games/#{game_dir}/#{tick_file}"

    render text: File.read(path)
  end

  def game
    @game_id = params[:id]
    game_dir  = (@game_id.to_i).to_s.rjust(10, '0')
    @max_ticks = Dir.entries("../games/#{game_dir}/").count-2
  end
end
