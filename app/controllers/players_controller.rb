class PlayersController < ApplicationController
  require 'json'
   skip_before_action :verify_authenticity_token

  def show
    @player = Player.find(params[:id])


    @graphable = graphable

    @stat_legend = stat_legend

  end

  def compare
    @stat_legend = stat_legend
    @stat_legend_json = stat_legend.to_json
    @graphable = graphable
  end

  def index
    @players = Player.where{active == true}
    @rbs = @players.where{position =='RB'}.sort_by{|play| -play.last_points}

    @rbs.each do |rb|
        if rb.average_points == nil || rb.average_points == 0
            @rbs.delete(rb)
        end
    end

    @wrs = @players.where{position =='WR'}.sort_by{|play| -play.last_points}

    @wrs.each do |wr|
        if wr.average_points == nil || wr.average_points == 0
            @wrs.delete(wr)
        end
    end

    @qbs = @players.where{position =='QB'}.sort_by{|play| -play.last_points}

    @qbs.each do |qb|
        if qb.average_points == nil || qb.average_points == 0
            @qbs.delete(qb)
        end
    end

    @count = 0
  end


  def find_player
    player = Player.get(params[:q])
    if player == nil
        player = Player.get("Antonio Brown")
    end
    redirect_to action: 'show', id: player
  end



  def json_seasons
    puts(params[:player_name])

    puts Player.get(params[:player_name]).name
        
    found_player = Player.get(params[:player_name])
    res_seasons = found_player.org_seasons()

    data = {'seasons' => res_seasons, 'name' => Player.get(params[:player_name]).name}




    render :json => data
  end

  def json_player_names
    players = Player.get_all(params[:player_name])

    player_names = players.map{|p| p.name}

    player_names.sort!

    render :json => player_names
  end

    def json_player_name
    player = Player.get(params[:player_name])

    data = {}

    if (player == nil)
        data["name"]=""
    else
        data["name"] = player.name
    end

    render :json =>data
  end

  def json_seasons_arr
    puts(params[:players])

    player_strings = params[:players]

    stat = params[:stat]

    response = []

    player_strings.each do |player_string|
        puts player_string
        player = Player.get(player_string)
        if player == nil
            next 
        end
        puts player

        name = player.name

        player_data = {}

        player.seasons.each do |season|
            player_data[season['year']] = season[stat]
        end

        response.push({'name' => name, 'data' => player_data})

    end

    puts response


    render :json => response
  end

  protected
    def stat_legend
        {
            "total_points"  => "Fantasy Points",
            "games_played" => "Games Played",
            "fumbles" => "Fumbles",
            "rush_attempts" => "Rushing: Attempts",
            "rush_yards" => "Rushing: Yards",
            "rush_avg" => "Rushing: Yards Per Carry",
            "rush_td" => "Rushing: TD\'s",
            "receptions" => "Receiving: Receptions",
            "rec_yards" => "Receiving: Yards",
            "rec_avg" => "Receiving: Yards Per Catch",
            "rec_td" => "Receiving: TD\'s",
            "pass_attempts" => "Passing: Attempts",
            "pass_complete" => "Passing: Completions",
            "complete_pct" => "Passing: Completion %",
            "pass_yards" => "Passing: Yards",
            "pass_avg" => "Passing: Yards Per Pass",
            "pass_td" => "Passing: TD\'s",
            "interceptions" => "Passing: Interceptions",
            "rating" => "Passing: Passer Rating",
            "total_points" => "Fantasy Points"

          }
    end

    # def stat_legend_rev
    #     {
    #         "Fantasy Points" => "total_points",
    #          "Games Played" => "games_played",
    #          "Fumbles" => "fumbles",
    #          "Rushing: Attempts" => "rush_attempts",
    #          "Rushing: Yards" => "rush_yards",
    #          "Rushing: Yards Per Carry" => "rush_avg",
    #          "Rushing: TD\'s" => "rush_td",
    #          "Receiving: Receptions" => "receptions",
    #          "Receiving: Yards" => "rec_yards",
    #          "Receiving: Yards Per Catch" => "rec_avg",
    #          "Receiving: TD\'s" => "rec_td",
    #          "Passing: Attempts" => "pass_attempts",
    #          "Passing: Completions" => "pass_complete",
    #          "Passing: Completion %" => "complete_pct",
    #          "Passing: Yards" => "pass_yards",
    #          "Passing: Yards Per Pass" => "pass_avg",
    #          "Passing: TD\'s" => "pass_td",
    #          "Passing: Interceptions" => "interceptions",
    #          "Passing: Passer Rating" =>"rating",
    #          "Fantasy Points" => "total_points" 

    #       }
    # end

    def graphable
        graphable = Season.new.attributes.keys

        graphable.delete("id")
        graphable.delete("year")
        graphable.delete("player_id")
        graphable.delete("created_at")
        graphable.delete("updated_at")
        graphable.delete("experience")
        graphable.delete("age")
        graphable.delete("position")
        graphable.delete("team")
        graphable.delete("change_from_last")
        graphable.delete("total_points")

        graphable

    end


end
