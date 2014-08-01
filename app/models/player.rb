class Player < ActiveRecord::Base
 has_many :seasons, dependent: :destroy

 require 'populator'
 require 'analyzer'
 require 'qb'
 require 'rb'
 require 'wr'
 require 'te'
 include Analyzer::QB
 include Analyzer::RB
 include Analyzer::WR
 include Analyzer::TE

  #used to easily get a player
  def self.get(input)
    player  = where{name =~ ("%#{input}%")}
    player.nil? ? nil : player.first
  end

  #gets a list of all palyers that match input
  def self.get_all(input)
    where{name =~ ("%#{input}%")}
  end

  #standardizes players positions
  def self.standardize_positions
    where{position =~ ("%#{back}%")}.each do |pl|
      pl.update_attributes(position: 'RB')
    end

    where{position =~ ("%#{receiver}%")}.each do |pl|
      pl.update_attributes(position: 'WR')
    end

    where{position =~ ("%#{quarter}%")}.each do |pl|
      pl.update_attributes(position: 'QB')
    end

    where{position =~ ("%#{tight}%")}.each do |pl|
      pl.update_attributes(position: 'TE')
    end

    where{position =~ ("%#{kick}%")}.each do |pl|
      pl.update_attributes(position: 'K')
    end
  end

  #computes a players average points multiplier
  def average_points
    total = 0
    seasons.each do |season|
      total += season.total_points * 16 / season.games_played
    end
    total/seasons.size
  end

  #computes a players average change in production by age compared to league average
  #returns a multiplier
  def average_cop_pct_age
    my_seasons = seasons.where{change_from_last != nil}.sort_by{|a| a[:change_from_last]}
    return 1 if my_seasons.size == 0
    total = 0
    my_seasons.each do |season|
      my_change = season.change_from_last
      if(position == 'QB')
        norm_change = Analyzer::QB.cop_by_age(season.age)
      elsif(position == 'RB')
        norm_change = Analyzer::RB.cop_by_age(season.age)
      elsif(position == 'WR')
        norm_change = Analyzer::WR.cop_by_age(season.age)
      elsif(position == 'TE')
        norm_change = Analyzer::TE.cop_by_age(season.age)
      else
        return 1
      end
      total += my_change/norm_change
    end
    total/my_seasons.size
  end


  #computes a players average change in production by years in the league compared to league average
  #returns a multiplier
  def average_cop_pct_exp
    my_seasons = seasons.where{change_from_last != nil}.sort_by{|a| a[:change_from_last]}
    return 1 if my_seasons.size == 0
    total = 0
    my_seasons.each do |season|
      my_change = season.change_from_last
      if(position == 'QB')
        norm_change = Analyzer::QB.cop_by_exp(season.experience)
      elsif(position == 'RB')
        norm_change = Analyzer::RB.cop_by_exp(season.experience)
      elsif(position == 'WR')
        norm_change = Analyzer::WR.cop_by_exp(season.experience)
      elsif(position == 'TE')
        norm_change = Analyzer::TE.cop_by_exp(season.experience)
      else
        return 1
      end
      total += my_change/norm_change
    end
    total/my_seasons.size
  end

  #returns a players most recent season
  def last_season
    seasons.sort_by{|s| -s[:year]}.first
  end

  # calculates the players average production compared to league average of that age
  #returns a multiplier
  def average_point_pct
      if(position == 'QB')
        average_points / Analyzer::QB.avg_points
      elsif(position == 'RB')
        average_points / Analyzer::RB.avg_points
      elsif(position == 'WR')
        average_points / Analyzer::WR.avg_points
      elsif(position == 'TE')
        average_points / Analyzer::TE.avg_points
      else
        return nil
      end
  end


  #returns a projection for next year based on average_point_pct and league average
  #for players age
  def proj_points_overall_age
    if(position == 'QB')
      average_point_pct * Analyzer::QB.points_by_age(age)
    elsif(position == 'RB')
      average_point_pct * Analyzer::RB.points_by_age(age)
    elsif(position == 'WR')
      average_point_pct * Analyzer::WR.points_by_age(age)
    elsif(position == 'TE')
      average_point_pct * Analyzer::TE.points_by_age(age)
    else
      return last_season.total_points
    end
  end

  def proj_points_change_age
    if(position == 'QB')
      (average_cop_pct_age * Analyzer::QB.cop_by_age(age)) + last_season.total_points* 16 / last_season.games_played
    elsif(position == 'RB')
      (average_cop_pct_age * Analyzer::RB.cop_by_age(age)) + last_season.total_points* 16 / last_season.games_played
    elsif(position == 'WR')
      (average_cop_pct_age * Analyzer::WR.cop_by_age(age)) + last_season.total_points* 16 / last_season.games_played
    elsif(position == 'TE')
      (average_cop_pct_age * Analyzer::TE.cop_by_age(age)) + last_season.total_points* 16 / last_season.games_played
    else
      return 0
    end
  end

  #returns a projection for next year based on average_point_pct and league average
  #for players experience
  def proj_points_overall_exp
    begin
      if(position == 'QB')
        average_point_pct * Analyzer::QB.points_by_exp(experience)
      elsif(position == 'RB')
        average_point_pct * Analyzer::RB.points_by_exp(experience)
      elsif(position == 'WR')
        average_point_pct * Analyzer::WR.points_by_exp(experience)
      elsif(position == 'TE')
        average_point_pct * Analyzer::TE.points_by_exp(experience)
      else
        return last_season.total_points
      end
    rescue
      return last_season.total_points
    end
  end

  #returns a projection for next year based on average_cop_pct_exp and league average
  #chang of production for players that experience

  def proj_points_change_exp
    begin
      if(position == 'QB')
        (average_cop_pct_exp * Analyzer::QB.cop_by_exp(experience)) + last_season.total_points* 16 / last_season.games_played
      elsif(position == 'RB')
        (average_cop_pct_exp * Analyzer::RB.cop_by_exp(experience)) + last_season.total_points* 16 / last_season.games_played
      elsif(position == 'WR')
        (average_cop_pct_exp * Analyzer::WR.cop_by_exp(experience)) + last_season.total_points* 16 / last_season.games_played
      elsif(position == 'TE')
        (average_cop_pct_exp * Analyzer::TE.cop_by_exp(experience)) + last_season.total_points* 16 / last_season.games_played
      else
        return last_season.total_points
      end
    rescue
      return last_season.total_points
    end
  end





end
