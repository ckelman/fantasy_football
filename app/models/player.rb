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

  def get_season(year)
    seasons.where(year: year)[0]
  end

  def max_stat(stat)
    stat_list = seasons.map{|s| s[stat].to_f}
    stat_list.max
  end

  def total_stat(stat)
    stat_list = seasons.map{|s| s[stat].to_f}
    sum = 0
    stat_list.each { |s| sum += s }
    sum
  end

  def org_seasons
    seasons.sort_by{|sea| sea.year}
  end

  #gets a list of all palyers that match input
  def self.get_all(input)
    where{name =~ ("%#{input}%")}
  end

  def self.active
    where{active == true}
  end

  def season(the_year)
    seasons.where{year == the_year}.first
  end

  #standardizes players positions
  def self.standardize_positions
    where{(position =~ ("%#{back}%")) | (number=~ ("%#{running}%"))}.each do |pl|
      pl.update_attributes(position: 'RB')
    end

    where{(position =~ ("%#{receiver}%")) | (number=~ ("%#{receiver}%"))}.each do |pl|
      pl.update_attributes(position: 'WR')
    end

    where{(position =~ ("%#{quarter}%")) | (number=~ ("%#{quarter}%"))}.each do |pl|
      pl.update_attributes(position: 'QB')
    end

    where{(position =~ ("%#{tight}%")) | (number=~ ("%#{tight}%"))}.each do |pl|
      pl.update_attributes(position: 'TE')
    end

    where{(position =~ ("%#{kick}%")) | (number=~ ("%#{kick}%"))}.each do |pl|
      pl.update_attributes(position: 'K')
    end
  end

  def self.set_actives
    all.each do |player|
      player.set_active
    end
  end

  def set_active
    update_attributes(active: org_seasons.last== nil || org_seasons.last.year == 2015)
  end

  #computes a players average points multiplier
  def average_points
    begin
      total = 0
      seasons.each do |season|
        total += season.total_points * 16 / season.games_played
      end
      (total/seasons.size).round(1)
    rescue
      0
    end
  end

  #computes a players average change in production by age compared to league average
  #returns a multiplier
  def average_cop_pct_age
    my_seasons = seasons.where{change_from_last != nil}
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
    my_seasons = seasons.where{change_from_last != nil}
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

  def last_points
    season = seasons.sort_by{|s| -s[:year]}.first
    if season != nil
      return season.total_points
    else
      return 0
    end
  end

  def last_ppg
    season = seasons.sort_by{|s| -s[:year]}.first
    if season != nil
      return (season.total_points/season.games_played).round(1)
    else
      return 0
    end
  end

  # calculates the players average production compared to league average of that age
  #returns a multiplier

  #needs work.  Needs to compare individual seasons by age or exp
  def average_point_pct_age
    total = 0
    my_seasons = seasons.where{(games_played >= 8) | (total_points >= 50)}
    my_seasons.each do |season|
      if(position == 'QB')
        total += season.ppg * 16 / Analyzer::QB.points_by_age(season.age)
      elsif(position == 'RB')
        total += season.ppg * 16 / Analyzer::RB.points_by_age(season.age)
      elsif(position == 'WR')
        total += season.ppg * 16 / Analyzer::WR.points_by_age(season.age)
      elsif(position == 'TE')
        total += season.ppg * 16 / Analyzer::TE.points_by_age(season.age)
      end
    end
      total/my_seasons.size
  end

    def average_point_pct_exp
    total = 0
    my_seasons = seasons.where{(games_played >= 8) | (total_points >= 50)}
    my_seasons.each do |season|
      if(position == 'QB')
        total += season.ppg * 16 / Analyzer::QB.points_by_exp(season.experience)
      elsif(position == 'RB')
        total += season.ppg * 16 / Analyzer::RB.points_by_exp(season.experience)
      elsif(position == 'WR')
        total += season.ppg * 16 / Analyzer::WR.points_by_exp(season.experience)
      elsif(position == 'TE')
        total += season.ppg * 16 / Analyzer::TE.points_by_exp(season.experience)
      end
    end
      total/my_seasons.size
  end

  def self.calc_all_projected_points
    all.each do |player|
      p player.name
      player.calc_projected_points
    end
  end


  #once the overalls are fixed re add them to the calculations
  def calc_projected_points
    begin
      update_attributes(
        projected_points:
        ((( proj_points_overall_age + proj_points_overall_exp +
          proj_points_change_age + proj_points_change_exp )/4).round(1))
      )
    rescue
      update_attributes( projected_points: 0)
    end
  end

  def projected_ppg
    (projected_points/16).round(1)
  end


  #returns a projection for next year based on average_point_pct and league average
  #for players age

  #needs work
  def proj_points_overall_age
    begin
      if(position == 'QB')
        (average_point_pct_age * Analyzer::QB.points_by_age(age)).round(1)
      elsif(position == 'RB')
        (average_point_pct_age * Analyzer::RB.points_by_age(age)).round(1)
      elsif(position == 'WR')
        (average_point_pct_age * Analyzer::WR.points_by_age(age)).round(1)
      elsif(position == 'TE')
        (average_point_pct_age * Analyzer::TE.points_by_age(age)).round(1)
      else
        return ((last_season.total_points *2 + average_points) /3).round(1)
      end
    rescue
      return ((last_season.total_points*2 + average_points) /3).round(1)
    end
  end

  def proj_points_change_age
    begin
      if(position == 'QB')
        ((average_cop_pct_age * Analyzer::QB.cop_by_age(age)) + last_season.total_points* 16 / last_season.games_played).round(1)
      elsif(position == 'RB')
        ((average_cop_pct_age * Analyzer::RB.cop_by_age(age)) + last_season.total_points* 16 / last_season.games_played).round(1)
      elsif(position == 'WR')
        ((average_cop_pct_age * Analyzer::WR.cop_by_age(age)) + last_season.total_points* 16 / last_season.games_played).round(1)
      elsif(position == 'TE')
        ((average_cop_pct_age * Analyzer::TE.cop_by_age(age)) + last_season.total_points* 16 / last_season.games_played).round(1)
      else
        return ((last_season.total_points*2 + average_points) /3).round(1)
      end
    rescue
      return ((last_season.total_points*2 + average_points) /3).round(1)
    end
  end

  #returns a projection for next year based on average_point_pct and league average
  #for players experience

  #needs work
  def proj_points_overall_exp
    begin
      if(position == 'QB')
        (average_point_pct_exp * Analyzer::QB.points_by_exp(experience)).round(1)
      elsif(position == 'RB')
        (average_point_pct_exp * Analyzer::RB.points_by_exp(experience)).round(1)
      elsif(position == 'WR')
        (average_point_pct_exp * Analyzer::WR.points_by_exp(experience)).round(1)
      elsif(position == 'TE')
        (average_point_pct_exp * Analyzer::TE.points_by_exp(experience)).round(1)
      else
        return ((last_season.total_points*2 + average_points) /3).round(1)
      end
    rescue
      return ((last_season.total_points*2 + average_points) /3).round(1)
    end
  end

  #returns a projection for next year based on average_cop_pct_exp and league average
  #chang of production for players that experience

  def proj_points_change_exp
    begin
      if(position == 'QB')
        ((average_cop_pct_exp * Analyzer::QB.cop_by_exp(experience)) * last_season.total_points* 16 / last_season.games_played).round(1)
      elsif(position == 'RB')
        ((average_cop_pct_exp * Analyzer::RB.cop_by_exp(experience)) * last_season.total_points* 16 / last_season.games_played).round(1)
      elsif(position == 'WR')
        ((average_cop_pct_exp * Analyzer::WR.cop_by_exp(experience)) * last_season.total_points* 16 / last_season.games_played).round(1)
      elsif(position == 'TE')
        ((average_cop_pct_exp * Analyzer::TE.cop_by_exp(experience)) * last_season.total_points* 16 / last_season.games_played).round(1)
      else
        return ((last_season.total_points*2 + average_points) /3).round(1)
      end
    rescue
      return ((last_season.total_points*2 + average_points) /3).round(1)
    end
  end

  def remove_nils
    attributes.keys.each do |attribute|
      if attributes[attribute] == nil
        update_attribute(attribute, 0)
      end
      
    end
  end

  def self.remove_all_nils
    Player.all.each do |player|
      player.remove_nils
    end
  end





end
