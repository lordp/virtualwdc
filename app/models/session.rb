class Session < ActiveRecord::Base
  attr_accessible :token, :session_type, :driver_id, :track_id, :race_id, :winner, :screenshot_ids

  has_many :laps
  has_many :screenshots

  belongs_to :track
  belongs_to :driver
  belongs_to :race

  SESSION_TYPE_TIME_TRIAL = 10.0
  SESSION_TYPE_QUALIFYING = 170.0

  def name
    "#{driver.try(:name)} on #{track.try(:name)} at #{created_at}"
  end

  def nice_session_type
    case session_type
      when 10.0
        'Time Trial'
      when 170.0
        'Qualifying'
      when nil
        'Unknown'
      else
        'Race'
    end
  end

  def session_time
    case session_type
      when 10.0
      when 170.0
        fastest_lap.try(:total)
      else
        total_time
    end
  end

  def average_lap
    laps.average(:total)
  end

  def fastest_lap
    laps.order(:total).first
  end

  def fuel_remaining
    laps.order(:lap_number).last.fuel.round(3)
  end

  def top_speed
    laps.order(:speed).last
  end

  def total_time
    laps.sum(:total)
  end

  def average_sector(sector)
    laps.average("sector_#{sector}")
  end

  def set_info(ip, length)
    driver = Driver.find_or_create_by_ip(ip)
    track = Track.find_or_create_by_length(length)

    self.update_attributes({ :ip => ip, :driver_id => driver, :track_id => track })
  end

  def set_sector_time(sector, time, lap)
    @lap = Lap.find_or_initialize_by_driver_id_and_race_id_and_lap_number_and_session_id(@driver.id, @race.id, lap, id) if @lap.nil?
    @lap.send("sector_#{sector}=", time)

    @lap.save
  end

  def set_lap_time(total)
    @lap.total = total
    @lap.sector_3 = (total - @lap.sector_2 - @lap.sector_1) if @lap.sector_2 && @lap.sector_1

    @lap.save
    @lap = nil
  end

  def self.generate_token
    Time.now.to_i.to_s(36)
  end

  def self.register(params)
    driver = Driver.name_and_token(params[:driver], params[:token])
    track = Track.find_or_create_by_length(params[:track])
    race = nil
    unless [SESSION_TYPE_QUALIFYING, SESSION_TYPE_TIME_TRIAL].include?(params[:type])
      race = Race.find(params[:race].to_i) if params[:race]
    end
    Session.new(:driver_id => driver.try(:id), :track_id => track.try(:id), :race_id => race.try(:id), :session_type => params[:type])
  end

end
