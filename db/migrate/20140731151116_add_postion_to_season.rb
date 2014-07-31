class AddPostionToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :position, :string
  end
end
