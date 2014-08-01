class AddProjectedPointsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :projected_points, :float
  end
end
