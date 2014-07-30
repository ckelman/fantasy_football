class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|

      t.string :name
      t.string :position
      t.integer :height
      t.integer :weight
      t.string :team
      t.integer :age
      t.integer :experience

      t.timestamps
    end
  end
end
