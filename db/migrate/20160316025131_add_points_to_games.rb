class AddPointsToGames < ActiveRecord::Migration
  def change
  	add_column :games, :points, :decimal
  end
end
