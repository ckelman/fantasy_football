class PlayersController < ApplicationController
  require 'json'
  def show
    @player = Player.find(params[:id])

    @poa = @player.proj_points_overall_age
    @poe = @player.proj_points_overall_exp
    @pca = @player.proj_points_change_age
    @pce = @player.proj_points_change_exp

    @graphable = Season.new.attributes.keys

    @graphable.delete("id")
    @graphable.delete("year")
    @graphable.delete("player_id")
    @graphable.delete("created_at")
    @graphable.delete("updated_at")
    @graphable.delete("experience")
    @graphable.delete("age")
    @graphable.delete("position")
    @graphable.delete("team")
    @graphable.delete("change_from_last")
    @graphable.delete("total_points")

    @stat_legend = {
    "total_points"  => "Fantasy Points",
    "games_played" => "Games Played",
    "rush_attempts" => "Rushing Attempts",
    "rush_yards" => "Rushing Yards",
    "rush_avg" => "Yards Per Carry",
    "rush_td" => "Rushing TD\'s",
    "receptions" => "Receptions",
    "rec_yards" => "Receiving Yards",
    "rec_avg" => "Yards Per Catch",
    "rec_td" => "Receiving TD\'s",
    "pass_attempts" => "Pass Attempts",
    "pass_complete" => "Passes Completed",
    "complete_pct" => "Completion %",
    "pass_yards" => "Passing Yards",
    "pass_avg" => "Yards Per Pass",
    "pass_td" => "Passing TD\'s",
    "interceptions" => "Interceptions",
    "rating" => "Passer Rating",
    "fumbles" => "Fumbles",
    "total_points" => "Fantasy Points"

  }

  end

  def compare

  end

  def index
    @players = Player.where{active == true}
    @rbs = @players.where{position =='RB'}.sort_by{|play| -play.projected_points}
    @wrs = @players.where{position =='WR'}.sort_by{|play| -play.projected_points}
    @qbs = @players.where{position =='QB'}.sort_by{|play| -play.projected_points}
    @count = 0
  end


  def find_player
    player = Player.get(params[:q])
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

end
