class Screenshot < ActiveRecord::Base
  attr_accessible :image, :parsed, :session_id, :confirmed

  has_attached_file :image, :styles => { :three_quarters => "75%x75%>" }, :processors => [ :parse_image, :thumbnail ]
  belongs_to :session

  after_save :create_laps, :if => lambda { |s| s.confirmed? }

  def create_laps
    self.parsed.split(/\r\n/).each do |line|
      match = line.match(/^([\d]{2}) (([\d]+:)?[\d]{2}\.[\d]{3}) (([\d]+:)?[\d]{2}\.[\d]{3}) (([\d]+:)?[\d]{2}\.[\d]{3}) (([\d]+:)?[\d]{2}\.[\d]{3})/)

      lap = Lap.find_or_initialize_by_session_id_and_lap_number(session_id, match[1].to_i - 1)
      lap.total = Lap.convert_lap(match[2])
      lap.sector_1 = Lap.convert_lap(match[4])
      lap.sector_2 = Lap.convert_lap(match[6])
      lap.sector_3 = Lap.convert_lap(match[8])

      lap.save
    end
  end
end