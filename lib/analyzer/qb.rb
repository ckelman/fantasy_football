module Analyzer

  module QB
    def self.cop_by_age(inp_age)
      Analyzer.cop_by_age_h('QB', inp_age)
    end

    def self.cop_by_exp(inp_exp)
      Analyzer.cop_by_exp_h('QB', inp_exp)
    end

    def self.points_by_age(inp_age)
      Analyzer.points_by_age_h('QB', inp_age)
    end

    def self.points_by_exp(inp_exp)
      Analyzer.points_by_exp_h('QB', inp_exp)
    end

    def self.points_by_age_range(start, fin)
      Analyzer.points_by_age_range_h('QB', start, fin)
    end

    def self.points_by_exp_range(start, fin)
      Analyzer.points_by_exp_range_h('QB', start, fin)
    end

    def self.avg_points
      Analyzer.avg_points_h('QB')
    end

  end
end
