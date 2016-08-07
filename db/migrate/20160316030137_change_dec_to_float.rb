class ChangeDecToFloat < ActiveRecord::Migration
  def change
  	change_column :games, :rec_avg,  :float
  	change_column :games, :rush_avg,  :float
  	change_column :games, :completion_pct,  :float
  	change_column :games, :pass_avg,  :float
  	change_column :games, :qbr,  :float
  	change_column :games, :pass_rating,  :float
  	change_column :games, :points,  :float
  end
end
