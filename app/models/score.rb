class Score < ActiveRecord::Base
  default_scope { order('value DESC') }

  def self.get_place score
    record = where('value > ?', score).first
    index  = all.index record
    index ? index + 2 : 1
  end
end
