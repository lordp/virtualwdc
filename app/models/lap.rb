class Lap < ActiveRecord::Base
  belongs_to :session, :counter_cache => true
  belongs_to :race
  belongs_to :driver

  validates :session_id, :numericality => true
  validates :lap_number, :numericality => true

  def full_name
    "##{lap_number}, #{converted_total}"
  end

  def converted_total
    t1 = (total / 60).floor
    t2 = (total % 60).round(3)
    "#{t1}:#{(t2 < 10 ? "0#{t2}" : t2)}"
  end

  def self.convert_lap(lap)
    time = lap.match(/((\d):)?([\d\.]+)/)
    if time[2].nil?
      time[3].to_f
    else
      (time[2].to_i * 60) + time[3].to_f
    end
  end

  def last_lap(field)
    ll = self.session.laps.where(:lap_number => self.lap_number - 1)
    if ll
      ll.first.try(field)
    end
  end

  def fuel_delta
    ll = self.last_lap('fuel')
    ll ? self.fuel - ll : 0
  end

  def position_delta
    ll = self.last_lap('position')
    ll ? ll - self.position : 0
  end

  def nice_top_speed
    if self.speed
      [self.lap_number, self.speed.to_f.round(3)]
    else
      []
    end
  end
end
