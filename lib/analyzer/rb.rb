module Analyzer
  module RB
    def self.cop_by_age(inp_age)
      Analyzer.cop_by_age_h('RB', inp_age)
    end

    def self.cop_by_exp(inp_exp)
      Analyzer.cop_by_exp_h('RB', inp_exp)
    end

    def self.points_by_age(inp_age)
      Analyzer.points_by_age_h('RB', inp_age)
    end

    def self.points_by_exp(inp_exp)
      Analyzer.points_by_exp_h('RB', inp_exp)
    end

    def self.points_by_age_range(start, fin)
      Analyzer.points_by_age_range_h('RB', start, fin)
    end

    def self.points_by_exp_range(start, fin)
      Analyzer.points_by_exp_range_h('RB', start, fin)
    end

    def self.avg_points
      Analyzer.avg_points_h('RB')
    end



      def usage(inp_weight, inp_touches)
        seasons = []
        total = 0
        players = Player.where{weight <= inp_weight}

        players.each do |player|
          player.seasons.where{rush_attempts + receptions >= inp_touches}.each do |season|
            seasons << season if season.next != nil
          end
        end

        seasons.each do |season|
          total += season.next.change_from_last
        end

        total/seasons.size
      end



  end
end
