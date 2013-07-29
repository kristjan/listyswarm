class GameController < ApplicationController
  def index
  end

  def tick
    game_id = params[:game_id]
    tick_id = params[:id]

    render text: File.read(tick_file(tick_id, game_id))
  end

  def game
    @game_id = params[:id]
    @max_ticks = Dir.entries(game_dir(@game_id)).count-2
    set_avatars
  end

  def set_avatars
    file = File.open(tick_file(1, @game_id))
    data = JSON.parse(file.first)

    @avatars = {}.tap do |avatars|
      ['x','o','w','s'].each do |char|
        if data[char] && data[char]['avatar'].present?
          avatars[char] = custom_avatar_url(data[char]['avatar'])
        else
          avatars[char] = default_avatar_url
        end
      end
    end
  end

  def game_dir(game_id)
    game_dir  = (game_id.to_i).to_s.rjust(10, '0')
    "../games/#{game_dir}"
  end

  def tick_file(tick_id, game_id)
    file_name = (tick_id.to_i+1).to_s.rjust(10, '0')
    "#{game_dir(game_id)}/#{file_name}"
  end

  def custom_avatar_url(url)
    if url =~ /^http/
      url
    else
      "/assets/#{url}"
    end
  end

  def default_avatar_url
    "/assets/tiny-listy.jpg"
  end
end
