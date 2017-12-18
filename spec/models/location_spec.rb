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
        new_location = Location.get_location('sarinah')
        expect(new_location.class).to eq(Location)
      end

      it 'downcase inputed address' do
        new_location = Location.get_location('SARINAH')
        expect(new_location.address).to eq('sarinah')
      end

      it 'return an location object' do
        expect(Location.get_location('kolla sabang')).to eq(@location)
      end
    end

    context 'with invalid address' do
      it 'return an empty string' do
        wrong_location = Location.get_location('kjddklfjdsl')
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
          new_area = Location.save_area_not_exist('kota jakarta pusat')
          }.to change(Area, :count).by (1)
      end

      it 'return object location' do
        exist_area = Location.save_area_not_exist('kota jakarta selatan')
        expect(exist_area).to eq(@area)
      end
    end

    describe 'location_area_not_exist' do
      it 'save location if not found' do
        expect{
          new_location = Location.save_location_not_exist(@area, 'bintaro jakarta', [-6.185512, 106.824948] )
          }.to change(Location, :count).by (1)
      end

      it 'return object location' do
        exist_location = Location.save_location_not_exist(@area, 'kolla sabang', [-6.185512, 106.824948] )
        expect(exist_location).to eq(@location)
      end
    end
  end



end
