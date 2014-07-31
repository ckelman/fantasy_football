class Season < ActiveRecord::Base
  belongs_to :player

  def self.set_all
    self.set_all_ages
    self.set_all_experiences
    self.set_all_change_from_lasts
    self.set_all_positions
  end

  def self.set_all_positions
    self.all.each do |season|
      season.set_position
    end
  end

  def self.set_all_ages
    self.all.each do |season|
      season.set_age
    end
  end

  def self.set_all_experiences
    self.all.each do |season|
      season.set_experience
    end
  end

  def self.set_all_change_from_lasts
    self.all.each do |season|
      season.set_change_from_last
    end
  end

  def set_position
    update_attributes(position: player.position)
  end


  def set_change_from_last
    seasons = player.seasons.sort_by{|s| s[:year]}

    if(seasons[0].year == year)
      update_attributes(change_from_last: nil)
    else
      seasons.each do |season|
        if(year - season.year == 1)
          update_attributes(change_from_last: total_points / season.total_points)
          return
        end
      end
    end
    update_attributes(change_from_last: nil)
  end

  def set_age
    seasons = player.seasons.sort_by{|s| -s[:year]}
    (0..seasons.size-1).each do |i|
      if(seasons[i].year == year && player.age != nil)
        begin
          update_attributes(age: player.age - ( Time.now.year - year))
        rescue
          update_attributes(age: player.experience - ( Time.now.year - year) + 21)
        end
        return
      end
    end
    update_attributes(age: nil)
  end


  def set_experience
    seasons = player.seasons.sort_by{|s| -s[:year]}
    (0..seasons.size-1).each do |i|
      if(seasons[i].year == year && player.experience != nil)
        update_attributes(experience: player.experience - ( Time.now.year - year))
        return
      end
    end
    update_attributes(experience: nil)
  end



end
