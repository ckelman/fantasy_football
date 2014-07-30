class DeleteTotalPointForrealInSeasons < ActiveRecord::Migration
  def change
    remove_column :seasons, :total_points
    add_column :seasons, :total_points, :float
  end
end
