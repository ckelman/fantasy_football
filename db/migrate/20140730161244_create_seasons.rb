class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.integer :year
      t.string :team
      t.integer :games_played

      t.integer :rush_attempts
      t.integer :rush_yards
      t.float :rush_avg
      t.integer :rush_td

      t.integer :receptions
      t.integer :rec_yards
      t.float :rec_avg
      t.integer :rec_td

      t.integer :pass_attempts
      t.integer :pass_complete
      t.float :complete_pct
      t.integer :pass_yards
      t.float :pass_avg
      t.integer :pass_td
      t.integer :interceptions
      t.float :rating

      t.integer :fumbles

      t.integer :total_points

      t.integer :player_id



      t.timestamps
    end
  end
end
