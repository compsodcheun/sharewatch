require 'rails_helper'
require 'action_dispatch/testing/test_process'

RSpec.describe Image, type: :model do
  describe "Field Matchers" do
    it { is_expected.to have_field(:name).of_type(String) }
    it { is_expected.to have_field(:raw_id).of_type(BSON::ObjectId) }
    it { is_expected.to have_field(:thumbnail_id).of_type(BSON::ObjectId) }
  end

  describe "Association Matchers" do
    it { is_expected.to be_embedded_in(:watch) }
  end

  describe "Validation Matchers" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "Methods" do
    let(:image_jpg_1) {
      Rack::Test::UploadedFile.new(
        File.open(File.join(Rails.root, '/spec/files/IMG_1.jpg'))
      )
    }
    let(:image_jpg_2) {
      Rack::Test::UploadedFile.new(
        File.open(File.join(Rails.root, '/spec/files/IMG_2.jpg'))
      )
    }
    let(:image_jpg_3) {
      Rack::Test::UploadedFile.new(
        File.open(File.join(Rails.root, '/spec/files/IMG_3.jpg'))
      )
    }
    let(:image1) { build(:image) }
    let(:image2) { build(:image) }
    let(:image3) { build(:image) }
    let(:watch) { build(:watch) }

    before do
      DatabaseCleaner.clean
      image1.assign_file(image_jpg_1)
      image2.assign_file(image_jpg_2)
      image3.assign_file(image_jpg_3)
      watch.images << [image1, image2, image3]
      watch.owner = create(:user)
      watch.save
    end

    it "#assign_file" do
      db = Mongoid::Config.clients[:default][:database]
      host = Mongoid::Config.clients[:default][:hosts]
      client = Mongo::Client.new(host, database: db)
      collection = client.collections.select { |c| c.name.eql?('fs.files') }.first
      gird_fs_record = collection.find.map(&:as_json)

      # [0, 2, 4] is raw image index
      expect(gird_fs_record[0]["filename"]).to include('IMG_1.jpg')
      expect(gird_fs_record[2]["filename"]).to include('IMG_2.jpg')
      expect(gird_fs_record[4]["filename"]).to include('IMG_3.jpg')
      expect(gird_fs_record[0]["length"]).to eq(image_jpg_1.size)
      expect(gird_fs_record[2]["length"]).to eq(image_jpg_2.size)
      expect(gird_fs_record[4]["length"]).to eq(image_jpg_3.size)
      expect(gird_fs_record[1]["length"] < image_jpg_1.size).to be_truthy
      expect(gird_fs_record[3]["length"] < image_jpg_2.size).to be_truthy
      expect(gird_fs_record[5]["length"] < image_jpg_3.size).to be_truthy
      expect(image1.get_raw).to be_present
      expect(image2.get_raw).to be_present
      expect(image3.get_raw).to be_present
      expect(image1.get_thumbnail).to be_present
      expect(image2.get_thumbnail).to be_present
      expect(image3.get_thumbnail).to be_present
      expect(gird_fs_record.count).to eq(6)
      client.close
    end

    it "#get_raw" do
      tmp_file = "#{Rails.root}/tmp/image"

      File.open(tmp_file, 'wb') do |f|
        f.write image1.get_raw
      end

      this_image = File.open(tmp_file)

      expect(this_image.size).to eq(image_jpg_1.size)
      File.delete(tmp_file) if File.exist?(tmp_file)
    end

    it "#get_thumbnail" do
      tmp_file = "#{Rails.root}/tmp/image"

      File.open(tmp_file, 'wb') do |f|
        f.write image1.get_thumbnail
      end

      this_thumbnail = File.open(tmp_file)

      expect(this_thumbnail.size < image_jpg_1.size).to be_truthy
      File.delete(tmp_file) if File.exist?(tmp_file)
    end

    it "#delete_grid_fs" do
      image1.delete_grid_fs

      db = Mongoid::Config.clients[:default][:database]
      host = Mongoid::Config.clients[:default][:hosts]
      client = Mongo::Client.new(host, database: db)
      collection = client.collections.select { |c| c.name.eql?('fs.files') }.first
      gird_fs_count = collection.count
      client.close

      expect(gird_fs_count).to eq(4)
    end
  end
end
