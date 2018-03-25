require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:user) { create(:user) }
  let(:watch) { build(:watch) }
  let(:image_jpg_1) { fixture_file_upload('spec/files/IMG_1.jpg', 'image/jpeg') }
  let(:image_jpg_2) { fixture_file_upload('spec/files/IMG_2.jpg', 'image/jpeg') }
  let(:image_jpg_3) { fixture_file_upload('spec/files/IMG_3.jpg', 'image/jpeg') }
  let(:image1) { build(:image) }
  let(:image2) { build(:image) }
  let(:image3) { build(:image) }

  before do
    image1.assign_file(image_jpg_1)
    image2.assign_file(image_jpg_2)
    image3.assign_file(image_jpg_3)
    watch.images << [image1, image2, image3]
    watch.save
    watch.owner = user
    watch.save
  end

  describe "GET" do
    describe "download" do
      it "renders the raw image data correctly." do
        sign_in_as(user) do
          get :download,
            params: {
              id: image1.id,
              watch_id: watch.id,
              thumbnail: false
            }

            tmp_file = "#{Rails.root}/tmp/image"

            File.open(tmp_file, 'wb') do |f|
              f.write response.body
            end

            this_image = File.open(tmp_file)

            expect(this_image.size).to eq(image_jpg_1.size)
            File.delete(tmp_file) if File.exist?(tmp_file)
            expect(response).to have_http_status(200)
        end
      end

      it "renders the thumbnail image data correctly." do
        sign_in_as(user) do
          get :download,
            params: {
              id: image1.id,
              watch_id: watch.id,
              thumbnail: true
            }

            tmp_file = "#{Rails.root}/tmp/image"

            File.open(tmp_file, 'wb') do |f|
              f.write response.body
            end

            this_image = File.open(tmp_file)

            expect(this_image.size < image_jpg_1.size).to be_truthy
            File.delete(tmp_file) if File.exist?(tmp_file)
            expect(response).to have_http_status(200)
        end
      end
    end
  end
end
