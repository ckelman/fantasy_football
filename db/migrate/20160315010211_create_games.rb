class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|

    	t.integer :season_id

    	t.date :date
    	t.string :opponent
    	t.string :score
    	t.boolean :win
    	t.integer :receptions
    	t.integer :targets
    	t.integer :rec_yards
    	t.decimal :rec_avg
    	t.integer :rec_lng
    	t.integer :rec_td

    	t.integer :rush_att
    	t.integer :rush_yards
    	t.decimal :rush_avg
    	t.integer :rush_lng
    	t.integer :rush_td
    	t.integer :fumbles
    	t.integer :fumbles_lost

    	t.integer :completions
    	t.integer :attempts
    	t.integer :pass_yards
    	t.decimal :completion_pct
    	t.decimal :pass_avg
    	t.integer :pass_lng
    	t.integer :pass_td
    	t.integer :interceptions
    	t.decimal :qbr
    	t.decimal :pass_rating



      t.timestamps
    end
  end
end
