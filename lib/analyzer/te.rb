module Analyzer
  module TE
    def self.cop_by_age(inp_age)
      Analyzer.cop_by_age_h('TE', inp_age)
    end

    def self.cop_by_exp(inp_exp)
      Analyzer.cop_by_exp_h('TE', inp_exp)
    end

    def self.points_by_age(inp_age)
      Analyzer.points_by_age_h('TE', inp_age)
    end

    def self.points_by_exp(inp_exp)
      Analyzer.points_by_exp_h('TE', inp_exp)
    end

    def self.points_by_age_range(start, fin)
      Analyzer.points_by_age_range_h('TE', start, fin)
    end

    def self.points_by_exp_range(start, fin)
      Analyzer.points_by_exp_range_h('TE', start, fin)
    end

    def self.avg_points
      Analyzer.avg_points_h('TE')
    end
  end
end
