class AddWeightDropHeight < ActiveRecord::Migration
  def change
  	remove_column :players, :height
    add_column :players, :weight, :integer
  end
end
