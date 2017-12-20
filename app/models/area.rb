class Area < ApplicationRecord
  has_many :location

  def enqueue(driver)
    queues = []
    if !queue.nil?
      queues = eval(queue)
    end
    queues << driver
    self.update(queue:queues)
  end

  def dequeue(service, location)
    result = ''
    drivers = eval(queue)
    origin_coordinate = eval(location.coordinate)
    vehicles = drivers.select do |driver|
      driver[:service] == service
    end

    drivers_dist = vehicles.reduce(Hash.new) do |hash, driver|
      driver_id = driver[:driver]
      driver_coordinate = eval(Location.find(driver[:location]).coordinate)
      hash[driver_id] = distance(origin_coordinate, driver_coordinate)
      hash
    end
    nearest = drivers_dist.select { |driver, length| length < 3000 }
    if !nearest.empty?
      get_driver = drivers.find{ |driver| driver[:driver]==nearest.first.first }
      result = drivers.delete(get_driver)
      result = result[:driver]
      self.update(queue:drivers)
    end
    result
  end

  def delete(driver)
    queues = eval(queue)
    queues.delete(driver)
    self.update(queue:queues)
  end

  def distance(loc1, loc2)
    rad_per_deg = Math::PI/180
    rkm = 6371
    rm = rkm * 1000
    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg
    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c
  end

end
