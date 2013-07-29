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
    set_players
  end

  def game_dir(game_id)
    game_dir  = (game_id.to_i).to_s.rjust(10, '0')
    "../games/#{game_dir}"
  end

  def tick_file(tick_id, game_id)
    file_name = (tick_id.to_i).to_s.rjust(10, '0')
    "#{game_dir(game_id)}/#{file_name}"
  end

  def set_players
    file = File.open(tick_file(1, @game_id))
    data = JSON.parse(file.first)

    @players = {}.tap do |players|
      %w(x o w s).each do |char|
        if data[char].present?
          agent = agent_name(data[char]['agent'])
          avatar =
            if data[char] && data[char]['avatar'].present?
              custom_avatar_url(data[char]['avatar'])
            else
              default_avatar_url(char)
            end

          players[char] = 
            { char: char, agent: agent, avatar: avatar }
        end
      end
    end
  end

  def agent_name(klass)
    klass.split('::').last
  end

  def custom_avatar_url(url)
    if url =~ /^http/
      url
    else
      "/assets/#{url}"
    end
  end

  def default_avatar_url(char)
    case char
    when 'x' then "/assets/red-listy-avatar.png"
    when 'o' then "/assets/blue-listy-avatar.png"
    when 's' then "/assets/pink-listy-avatar.png"
    when 'w' then "/assets/green-listy-avatar.png"
    else
      "/assets/tiny-listy.jpg"
    end
  end
end
