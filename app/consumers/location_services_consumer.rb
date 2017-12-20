class LocationServicesConsumer < Racecar::Consumer
  subscribes_to "locationServices"

  def process(message)
    puts "-------------#{message.value}--------------------"
    
    array = message.value.split('-->')
    order_value = eval(array.second)

    address = order_value[:pickup]
    service = order_value[:service]
    order_id = order_value[:order_id]

    get_driver = Location.new.get_driver(service, address)
    puts "--------------- YOU GET -----------------"
    puts "---------------    A    -----------------"
    puts "--------------- DRIVER  -----------------"
    puts "--------------- #{get_driver}  -----------------"
    send_driver_to_order_services(order_id, get_driver)
    sleep(5)

    # puts "#{message.value}"
  end

  def send_driver_to_order_services(order_id, driver)
    require 'kafka'
    kafka = Kafka.new( seed_brokers: ['localhost:9092'], client_id: 'transaction-service')

    found_driver = Hash.new
    found_driver[:order_id] = order_id
    found_driver[:driver_id] = driver
    kafka.deliver_message("PATCH-->#{found_driver.to_json}", topic: 'orderServices')
  end
end
