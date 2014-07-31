class AddAgeExperienceToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :experience, :integer
    add_column :seasons, :age, :integer
  end
end
