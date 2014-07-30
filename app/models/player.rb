class Player < ActiveRecord::Base
 has_many :seasons, dependent: :destroy



end
