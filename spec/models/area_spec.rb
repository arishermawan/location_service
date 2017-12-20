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
    it "shift element when element has distance less than 3000" do
    end

    it "shift fist element found if distance less than 3000" do
    end
  end

  describe "distance" do
    it "calculate distance between two coordinates" do
    end
  end

end
