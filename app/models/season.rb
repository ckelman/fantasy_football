class Season < ActiveRecord::Base
  belongs_to :player
  has_many :games, dependent: :destroy

  def standard_stat(stat)
    attributes[stat].to_f/player.total_stat(stat)*100
  end

  def standard_stats
    my_json = {}

    attributes.keys.each do |atr|
      if attributes[atr].is_a? Numeric 
        my_json[atr] = standard_stat(atr)
      end
    end
    my_json
  end

  def org_games
    games.sort_by{|game| game.date}
  end

  def relevent
    my_points = total_points
    Season.where{total_points - my_points > 50 || total_points - my_points < 50}
  end

  def ppg
    total_points / games_played
  end


  def next
    myYear = year
    player.seasons.where{year - myYear == 1}.first
  end

  def prev
    myYear = year
    player.seasons.where{year - myYear == -1}.first
  end

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
        if(year - season.year == 1 && season.total_points >=50)
          update_attributes(change_from_last: (total_points*16/games_played)/ (season.total_points*16/season.games_played))
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
    seasons = player.seasons.sort_by{|s| s[:year]}
    (0..seasons.size-1).each do |i|
      # if(seasons[i].year == year && player.experience != nil && player.experience != 0)
      #   update_attributes(experience: player.experience - ( Time.now.year - year))
      #   return
      # elsif(seasons[i].year == year)
      if(seasons[i].year == year)
        update_attributes(experience: i+1)
        return
      end
      # end
    end
    update_attributes(experience: nil)
  end



end
