require 'rails_helper'
require 'action_dispatch/testing/test_process'

RSpec.describe WatchesController, type: :controller do
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
    describe "index" do
      it "renders the index template" do
        sign_in_as(user) do
          get :index

          expect(assigns[:watches]).to eq(
            [
              watch
            ]
          )
          expect(response).to render_template :index
        end
      end
    end

    describe "new" do
      it "renders the new template" do
        sign_in_as(user) do
          get :new

          expect(assigns[:watch].new_record?).to be_truthy
          expect(response).to render_template(:new)
        end
      end
    end

    describe "edit" do
      before do
        watch.owner = user
        watch.save
      end

      it "renders the edit template" do
        sign_in_as(user) do
          get :edit,
          params: {
            id: watch.id
          }

          expect(assigns[:watch].name).to eq(watch.name)
          expect(assigns[:watch].detail).to eq(watch.detail)
          expect(assigns[:watch].images.length).to eq(3)
          expect(response).to render_template :edit
        end
      end
    end
  end

  describe "POST" do
    describe "create" do
      before do
        Watch.destroy_all
      end

      it "should creating new watch correctly." do
        expect {
          sign_in_as(user) do
            post :create,
            params: {
              watch: {
                name: watch.name,
                detail: "watch detail",
                images: [
                  image_jpg_1,
                  image_jpg_2
                ]
              }
            }

            expect(assigns[:watch].name).to eq(watch.name)
            expect(assigns[:watch].detail).to eq("watch detail")
            expect(assigns[:watch].images.length).to eq(2)
            expect(response).to redirect_to watches_path
          end
        }.to change{Watch.count}.by(1)
      end

      it "should display errors." do
        expect {
          sign_in_as(user) do
            post :create,
            params: {
              watch: {
                name: '',
                detail: "watch detail",
                images: [
                  image_jpg_1,
                  image_jpg_2
                ]
              }
            }

            expect(assigns[:watch].name).to eq('')
            expect(assigns[:watch].detail).to eq("watch detail")
            expect(flash[:alert]).to include("Name")
            expect(assigns[:watch].images.length).to eq(0)
            expect(response).to render_template :new
          end
        }.to change{Watch.count}.by(0)
      end
    end

    describe "borrowing" do
      let(:owner) { create(:user) }
      let(:borrower) { create(:user) }
      let(:borrowing_watch) { create(:watch, owner: owner) }

      it "should creating a new borrowing correctly." do
        expect {
          sign_in_as(borrower) do
            post :borrowing,
            params: {
              id: borrowing_watch.id
            }

            transaction = Transaction.all.last
            expect(transaction.borrower).to eq(borrower)
            expect(transaction.lender).to eq(owner)
            expect(transaction.watch).to eq(borrowing_watch)
            expect(transaction.state).to eq(Transaction::PENDING)
            expect(flash[:notice]).to be_present

            expect(response).to redirect_to borrows_path
          end
        }.to change{Transaction.count}.by(1)
      end
    end
  end

  describe "PATCH" do
    before do
      watch.owner = user
      watch.save
    end

    describe "update" do
      it "should updating new watch correctly." do
        sign_in_as(user) do
          patch :update,
          params: {
            id: watch.id,
            watch: {
              name: "watch new name",
              detail: "watch new detail"
            }
          }

          expect(assigns[:watch].name).to eq("watch new name")
          expect(assigns[:watch].detail).to eq("watch new detail")
          expect(response).to redirect_to watches_path
        end
      end

      it "should display errors." do
        sign_in_as(user) do
          patch :update,
          params: {
            id: watch.id,
            watch: {
              name: "",
              detail: "watch new detail"
            }
          }

          expect(assigns[:watch].name).to eq("")
          expect(assigns[:watch].detail).to eq("watch new detail")
          expect(response).to render_template :edit
        end
      end
    end
  end

  describe "DELETE" do
    before do
      watch.owner = user
      watch.save
    end

    describe "destroy" do
      it "should destroy watch correctly." do
        expect {
          sign_in_as(user) do
            delete :destroy,
            params: {
              id: watch.id
            }

            expect(response).to redirect_to watches_path
          end
        }.to change{Watch.count}.by(-1)
      end
    end
  end
end
