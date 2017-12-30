class Location < ApplicationRecord

  belongs_to :area

  validates :address, presence:true, uniqueness:true
  validates :coordinate, presence:true

  def api_key
    api = 'AIzaSyAT3fcxh_TKujSW6d6fP9cUtrexk0eEvAE'
  end

  def gmaps
    gmaps = GoogleMapsService::Client.new(key: api_key)
  end

  def set_driver_location(driver_params)
    driver_address = driver_params[:address]
    driver_id = driver_params[:driver_id].to_i
    location_id = driver_params[:location_id]
    service = driver_params[:service]
    location = get_location(driver_address)
    new_area = location.area

    if !location_id.nil?
      old_location = Location.find(location_id)
      old_area = old_location.area
      old_area.delete({driver:driver_id, location:old_location.id, service:service})
    end
      new_area.enqueue({driver:driver_id, location:location.id, service:service})
    location
  end

  def get_location(address)
    result = ''
    if !address.nil? && !address.empty?
      address.downcase!
      get_api = gmaps.geocode(address)
      if !get_api.empty?
        area = get_api[0][:address_components]
        city = get_city(area)
        check_area = save_area_not_exist(city)
        geometry = get_api[0][:geometry][:location]
        coordinate = [geometry[:lat], geometry[:lng]]
        check_location = save_location_not_exist(check_area, address, coordinate)
        result = check_location
      end
    end
    result
  end

  def get_city(area)
    city = ''
    area.each do |type|
      if type[:types][0]=="administrative_area_level_2"
        city = type[:short_name].downcase
      end
    end
    city
  end

  def save_area_not_exist(area)
    check_area = Area.find_by(name: area)
    if check_area == nil
      check_area = Area.create(name: area)
    end
    check_area
  end

  def save_location_not_exist(area, address, coordinate)
    check_location = Location.find_by(address: address)
    if check_location == nil
      check_location = area.location.create(address: address, coordinate: coordinate)
    end
    check_location
  end

  def google_distance(pickup, destination)
    matrix = []
    origins = pickup
    destinations = destination
    if !origins.empty? && !destinations.empty?
      matrix = gmaps.distance_matrix(origins, destinations, mode: 'driving', language: 'en-AU', avoid: 'tolls')
    end
    matrix
  end


  def distance_result(distance_params)
    result = Hash.new
    origin = distance_params[:origin]
    destination = distance_params[:destination]
    api = google_distance(origin, destination)

    distance = 0
    origin_address = []
    destination_address = []

    if !api.empty?
       if api[:rows][0][:elements][0][:status] == "OK"
        distance = api[:rows][0][:elements][0][:distance][:value]
        distance = (distance.to_f / 1000).round(2)
      end

      origin_address = api[:origin_addresses]
      origin_address.reject! { |address| address.empty? }

      destination_address = api[:destination_addresses]
      destination_address.reject! { |address| address.empty? }
    end
    result[:origin] = origin_address
    result[:destination] = destination_address
    result[:distance] = distance
    result[:unit] = "KM"
    result
  end

  def get_driver(service, pickup)
    pickup_location = get_location(pickup)
    area = pickup_location.area
    driver = area.dequeue(service, pickup_location)
    driver
  end
end
