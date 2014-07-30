class AddNumberToplayer < ActiveRecord::Migration
  def change
    remove_column :players, :weight
    add_column :players, :number, :string

  end
end
