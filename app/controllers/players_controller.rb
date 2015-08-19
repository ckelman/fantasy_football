class PlayersController < ApplicationController
  require 'json'
  def show
    @player = Player.find(params[:id])

    @poa = @player.proj_points_overall_age
    @poe = @player.proj_points_overall_exp
    @pca = @player.proj_points_change_age
    @pce = @player.proj_points_change_exp

    @seasons = @player.seasons.to_json

    @json_seasons = {};

    sl = @seasons.length

    for i in 0..sl 
      @json_seasons["#{i}"] = @seasons[i];
    end

    puts @json_seasons

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

end
