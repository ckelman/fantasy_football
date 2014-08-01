module Analyzer
  def self.cop_by_age_h(inp_position, inp_age)
    total = 0
    seasons = Season.where{position == inp_position }.where{age == inp_age}.where{change_from_last != nil}
    if(seasons.size == 0)
      return nil
    end
    seasons.each do |season|
      total += season.change_from_last
    end
    total/seasons.size
  end

  def self.cop_by_exp_h(inp_position, inp_exp)
    total = 0
    seasons = Season.where{position == inp_position }.where{experience == inp_exp}.where{change_from_last != nil}
    if(seasons.size == 0)
      return nil
    end
    seasons.each do |season|
      total += season.change_from_last 
    end
    total/seasons.size
  end

  def self.points_by_age_h(inp_position, inp_age)
    total = 0
    seasons = Season.where{position == inp_position }.where{age == inp_age}.where{change_from_last != nil}
    if(seasons.size == 0)
      return nil
    end
    seasons.each do |season|
      total += season.total_points * 16 / season.games_played
    end
    total/seasons.size
  end

  def self.points_by_exp_h(inp_position, inp_exp)
    total = 0
    seasons = Season.where{position == inp_position }.where{experience == inp_exp}.where{change_from_last != nil}
    if(seasons.size == 0)
      return nil
    end
    seasons.each do |season|
      total += season.total_points * 16 / season.games_played
    end
    total/seasons.size
  end

  def self.points_by_age_range_h(inp_position, start, fin)
    ans = []
    (start..fin).each do |i|
      points = self.points_by_age_h(inp_position, i)
      ans << {age: i, points: points} if points != nil
    end

    ans.sort_by{|a| -a[:points]}
  end

  def self.points_by_exp_range_h(inp_position, start, fin)
    ans = []
    (start..fin).each do |i|
      points = self.points_by_exp_h(inp_position, i)
      ans << {exp: i, points: points} if points != nil
    end

    ans.sort_by{|a| -a[:points]}
  end

  def self.cop_by_age_range_h(inp_position, start, fin)
    ans = []
    (start..fin).each do |i|
      points = self.cop_by_age_h(inp_position, i)
      ans << {age: i, cop: points} if points != nil
    end

    ans.sort_by{|a| -a[:points]}
  end

  def self.cop_by_exp_range_h(inp_position, start, fin)
    ans = []
    (start..fin).each do |i|
      points = self.cop_by_exp_h(inp_position, i)
      ans << {exp: i, cop: points} if points != nil
    end

    ans.sort_by{|a| -a[:points]}
  end

  def self.avg_points_h(inp_position)
    total = 0
    my_seasons = Season.where{position == inp_position }.where{total_points != 0}
    my_seasons.each do |season|
      total+= season.total_points
    end
    total/my_seasons.size
  end


end
