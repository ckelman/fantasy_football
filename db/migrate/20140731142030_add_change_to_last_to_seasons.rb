class AddChangeToLastToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :change_from_last, :float
  end
end
