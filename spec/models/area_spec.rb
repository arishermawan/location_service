require 'rails_helper'

RSpec.describe Area, type: :model do

  describe "enqueue " do
    before :each do
      @area = create(:area, queue:"[{:driver=>1, :location=>2, :service=>'gocar'}]")
    end

    it "add element to queue" do
      @area.enqueue({driver:2, location:2, service:'goride'})
      @area.reload
      expect(@area.queue).to eq("[{:driver=>1, :location=>2, :service=>\"gocar\"}, {:driver=>2, :location=>2, :service=>\"goride\"}]")
    end
  end

  describe "delete" do
    before :each do
      @area = create(:area, queue:"[{:driver=>1, :location=>2, :service=>'gocar'}]")
    end

    it "remove element from queue" do
      @area.delete({driver:1, location:2, service:'gocar'})
      @area.reload
      expect(@area.queue).to eq("[]")
    end
  end

  describe "dequeue" do
    before :each do
      @location1 = Location.new.get_location('kolla sabang')
      @area1 = @location1.area
      @area1.enqueue({driver:1, location:@location1.id, service:'goride'})
      @area1.enqueue({driver:2, location:@location1.id, service:'gocar'})
      @area1.enqueue({driver:3, location:@location1.id, service:'gocar'})
      @area1.enqueue({driver:4, location:@location1.id, service:'goride'})
    end
    it "shift element when element has distance less than 3000" do
      expect(@area1.dequeue('goride', @location1)).to eq(1)
    end

    it "shift element by service request" do
      @area1.dequeue('goride', @location1)
      @area1.reload
      expect(@area1.dequeue('goride', @location1)).to eq(4)
    end
  end

  describe "distance" do
    it "calculate distance between two coordinates" do
      location1 = Location.new.get_location('kolla sabang')
      location2 = Location.new.get_location('sarinah mall')

      coordinate1 = eval(location1.coordinate)
      coordinate2 = eval(location2.coordinate)
      distance = Area.new.distance(coordinate1, coordinate2)
      expect(distance).to eq(273.93839816530476)
    end
  end

end
