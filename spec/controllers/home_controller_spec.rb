require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  let(:user) { create(:user) }
  let(:guest) { create(:user) }
  let(:watch) { build(:watch) }
  let(:image_jpg_1) { fixture_file_upload('spec/files/IMG_1.jpg', 'image/jpeg') }
  let(:image_jpg_2) { fixture_file_upload('spec/files/IMG_2.jpg', 'image/jpeg') }
  let(:image_jpg_3) { fixture_file_upload('spec/files/IMG_3.jpg', 'image/jpeg') }
  let(:image1) { build(:image) }
  let(:image2) { build(:image) }
  let(:image3) { build(:image) }

  before do
    DatabaseCleaner.clean
    image1.assign_file(image_jpg_1)
    image2.assign_file(image_jpg_2)
    image3.assign_file(image_jpg_3)
    watch.images << [image1, image2, image3]
    watch.save
    watch.owner = user
    watch.save
  end

  describe "GET" do
    describe "index" do
      it "renders the index template" do
        sign_in_as(guest) do
          get :index

          expect(assigns[:watches].count).to eq(1)
          expect(response).to render_template :index
        end
      end
    end
  end
end
