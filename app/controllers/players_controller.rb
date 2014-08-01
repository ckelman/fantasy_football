class PlayersController < ApplicationController
  def show
    @player = Player.find(params[:id])
  end

  def index
    @players = Player.where{active == true}
    @rbs = @players.where{position =='RB'}.sort_by{|play| -play.projected_points}
    @wrs = @players.where{position =='WR'}.sort_by{|play| -play.projected_points}
    @qbs = @players.where{position =='QB'}.sort_by{|play| -play.projected_points}
  end


  def find_player
    player = Player.get(params[:q])
    redirect_to action: 'show', id: player
  end

end
