require 'rails_helper'

RSpec.describe Location, type: :model do
  it "has valid location" do
    expect(build(:location)).to be_valid
  end

  it "has valid with address and coordinate" do
    expect(build(:location)).to be_valid
  end

  it "is invalid without an address" do
    location = build(:location, address: nil)
    location.valid?
    expect(location.errors['address']).to include("can't be blank")
  end

  it "invalid without an coordinate" do
    location = build(:location, coordinate: nil)
    location.valid?
    expect(location.errors['coordinate']).to include("can't be blank")
  end

  it "invalid with duplicate address" do
    location1 = create(:location, address: 'kemayoran')
    location2 = build(:location, address: 'kemayoran')
    location2.valid?
    expect(location2.errors['address']).to include("has already been taken")
  end

  describe 'get_location(address)' do
    before :each do
      @location = create(:location)
    end

    context 'with valid address' do
      it 'request geocode to google api if address does not found in location' do
        new_location = Location.new.get_location('sarinah')
        expect(new_location.class).to eq(Location)
      end

      it 'downcase inputed address' do
        new_location = Location.new.get_location('SARINAH')
        expect(new_location.address).to eq('sarinah')
      end
    end

    context 'with invalid address' do
      it 'return an empty string' do
        wrong_location = Location.new.get_location('kjddklfjdsl')
        expect(wrong_location.empty?).to eq(true)
      end
    end
  end

  context 'saving location if location not found in record' do
    before :each do
      @area = create(:area)
      @location = create(:location, area: @area)
    end
    describe 'save_area_not_exist' do
      it 'save area if not found' do
        expect{
          new_area = Location.new.save_area_not_exist('kota jakarta pusat')
          }.to change(Area, :count).by (1)
      end

      it 'return object location' do
        exist_area = Location.new.save_area_not_exist('kota jakarta selatan')
        expect(exist_area).to eq(@area)
      end
    end

    describe 'location_area_not_exist' do
      it 'save location if not found' do
        expect{
          new_location = Location.new.save_location_not_exist(@area, 'bintaro jakarta', [-6.185512, 106.824948] )
          }.to change(Location, :count).by (1)
      end

      it 'return object location' do
        exist_location = Location.new.save_location_not_exist(@area, 'kolla sabang', [-6.185512, 106.824948] )
        expect(exist_location.class).to eq(Location)
      end
    end
  end

  describe "set_driver_location" do
    before :each do
      @area1 = create(:area, id:1, name: 'central jakarta city')
      @location1 = create(:location, id:1, address:"kolla sabang", area: @area1)

      @area2 = create(:area, id:2, name: 'south jakarta city', queue:"[{:driver=>1, :location=>2, :service=>'goride'}]")
      @location2 = create(:location, id:2, address:"bintaro", area: @area2)

      @driver_params = {address:'kolla sabang', driver_id: 1, location_id: 2, service:'goride' }
    end

    it "enqueue driver in area" do
      Location.new.set_driver_location(@driver_params)
      @area1.reload
      expect(@area1.queue).to eq("[{:driver=>1, :location=>1, :service=>\"goride\"}]")
    end

    it "remove driver from queues if registered in queue before" do
      Location.new.set_driver_location(@driver_params)
      @area2.reload
      expect(@area2.queue).to eq("[]")
    end

    it "return location object" do
      expect(Location.new.set_driver_location(@driver_params)).to eq(@location1)
    end
  end

  describe "google_distance" do
    before :each do
      @get_api = Location.new.google_distance('kolla sabang', 'sarinah mall')
      @invalid_get_api = Location.new.google_distance('', '')
    end
    context "with valid attributes" do
      it "return array from request google api service" do
        expect(@get_api.empty?).to eq(false)
      end

      it "return ok status" do
        expect(@get_api[:status]).to eq('OK')
      end
    end

    context "with invalid attributes" do
      it "return an empty array" do
        expect(@invalid_get_api.empty?).to eq(true)
      end
    end
  end

  describe "distance_result" do
    context "with valid attributes" do
      before :each do
        @location = {origin:'kolla sabang', destination:'sarinah'}
        @result = Location.new.distance_result(@location)
      end

      it "return distance beetween 2 location" do
        expect(@result[:distance]).to eq(0.33)
      end

      it "return origin address" do
        expect(@result[:origin].empty?).not_to eq(true)
      end

      it "return destination address" do
        expect(@result[:destination].empty?).not_to eq(true)
      end

      it "return unit in KM" do
        expect(@result[:unit]).to eq("KM")
      end
    end

    context "with invalid attributes" do
      before :each do
        @location = {origin:'lkjlldajldfj', destination:'dfadfafafdf'}
        @result = Location.new.distance_result(@location)
      end

      it "return zero value" do
        expect(@result[:distance]).to eq(0.0)
      end

      it "return empty origin address" do
        expect(@result[:origin].empty?).to eq(true)
      end

      it "return empty destination address" do
        expect(@result[:destination].empty?).to eq(true)
      end
    end
  end

  describe "get driver" do
    before :each do
      @location1 = Location.new.get_location('kolla sabang')
      @area1 = @location1.area
      @area1.enqueue({driver:1, location:@location1.id, service:'goride'})
      @area1.enqueue({driver:2, location:@location1.id, service:'gocar'})
      @area1.enqueue({driver:3, location:@location1.id, service:'gocar'})
      @area1.enqueue({driver:4, location:@location1.id, service:'goride'})
    end

    it "request a driver in area queue by service type" do
      expect(@location1.get_driver('goride','kolla sabang')).to eq(1)
    end

    it "return empty value when no driver in area queue" do
      @area1.dequeue('goride', @location1)
      @area1.dequeue('goride', @location1)
      expect(@location1.get_driver('goride','kolla sabang')).to eq("")
    end
  end
end
