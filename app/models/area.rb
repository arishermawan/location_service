class Area < ApplicationRecord
  has_many :location

  def enqueue(driver)
    queues = []
    if queue.nil?
      queues = []
    else
      queues = eval(queue)
    end
    puts "----------------------------------------------------------------------#{driver}"
    puts "---------------------------------------------------------------------#{queues}"
    queues << driver  
    puts "-------------------------------------------------#{queues}"
    self.update(queue:queues)
  end

  def dequeue

  end

  def delete(driver)
    queues = eval(queue)
    queues.reject! { |element| element == driver }
    self.update(queue:queues)
  end


end
