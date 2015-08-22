module PlayerHelper
	def seasons_as_json(seasons)
  seasons.collect do |season|
    {
      :id => season.id,
      :rush_yards => season.rush_yards
    }
  end.to_json
end
end
