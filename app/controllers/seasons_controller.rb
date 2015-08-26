class SeasonsController < ApplicationController
	respond_to :js, :html
  def show
    @season = Season.find(params[:id])
  end

  def json_season
  	# res_season = params[:season_id]
  	res_season = Season.first()


  	render :json => res_season
  end

end
