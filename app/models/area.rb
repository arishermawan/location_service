class Area < ApplicationRecord
  has_many :location

  def enqueue(driver)
    queues = []
    if !queue.nil?
      queues = eval(queue)
    end
    puts "-------------------------------------------------------#{queues}"
    queues << driver
    puts "-------------------------------------------------------#{queues}"
    self.update(queue:queues)
  end

  def dequeue

  end

  def delete(driver)
        puts "------------------------------------111111111111111111111111111111#{driver}"
    queues = eval(queue)
    queues.reject! { |element| element == driver }
    self.update(queue:queues)
    puts "------------------------------------------1111111111111111111111111111"
  end


end
