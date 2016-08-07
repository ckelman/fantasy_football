class SeasonsController < ApplicationController
  require 'json'
	respond_to :js, :html
  def show
    @season = Season.find(params[:id])
  end

  # def json_season
  # 	# res_season = params[:season_id]
  # 	res_season = Season.first()


  # 	render :json => res_season
  # end

    def json_games_arr
    puts(params[:players])

    player_strings = params[:players]

    stat = params[:stat]

    puts stat

    response = []

    player_strings.each do |player_string|
        player = Player.get(player_string)

        name = player.name
        puts name

        player_data = {}
        puts player
        season = player.get_season(params[:year])

        if season != nil
          season.games.each do |game|
              # puts game.date
              gameDate = game['date']

              if gameDate.month > 2
                puts stat
                puts game[stat]
                player_data[gameDate] = game[stat] || 0
              end
          end
        else
          response = [{'error' => "Season does not exist for " + player.name}]
          render :json => response
          return

        end

        response.push({'name' => name, 'data' => player_data})

    end

    puts response


    render :json => response
  end

end
