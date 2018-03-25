require 'rails_helper'

RSpec.describe BorrowsController, type: :controller do
  let(:owner) { create(:user) }
  let(:borrower) { create(:user) }
  let(:watch) { create(:watch, owner: owner) }

  describe "GET" do
    describe "index" do
      let(:transaction) {
        Transaction.new(borrower: borrower, lender: watch.owner, watch: watch)
      }

      before do
        transaction.save
      end

      it "renders the index template" do
        sign_in_as(borrower) do
          get :index

          expect(assigns[:transactions]).to eq([transaction])
          expect(response).to render_template :index
        end
      end

      it "renders the index template with blank borrowing" do
        sign_in_as(owner) do
          get :index

          expect(assigns[:transactions]).to eq([])
          expect(response).to render_template :index
        end
      end
    end

    describe "lending" do
      let(:transaction) {
        Transaction.new(borrower: borrower, lender: watch.owner, watch: watch)
      }

      before do
        transaction.save
      end

      it "renders the lending template" do
        sign_in_as(owner) do
          get :lending

          expect(assigns[:transactions]).to eq([transaction])
          expect(response).to render_template :lending
        end
      end

      it "renders the lending template with blank borrowing" do
        sign_in_as(borrower) do
          get :lending

          expect(assigns[:transactions]).to eq([])
          expect(response).to render_template :lending
        end
      end
    end
  end

  describe "PATCH" do
    describe "approve" do
      let(:transaction) {
        Transaction.new(borrower: borrower, lender: watch.owner, watch: watch)
      }

      before do
        transaction.save
      end

      it "should approve a borrowing watch correctly." do
        sign_in_as(owner) do
          patch :approve,
          params: {
            id: transaction.id
          }
          transaction.reload
          expect(transaction.borrower).to eq(borrower)
          expect(transaction.lender).to eq(owner)
          expect(transaction.watch).to eq(watch)
          expect(transaction.watch).to eq(watch)
          expect(transaction.state).to eq(Transaction::APPROVE)
          expect(transaction.watch.borrowing?).to be true
          expect(flash[:notice]).to include(Transaction::APPROVE)

          expect(response).to redirect_to lending_path
        end
      end
    end

    describe "reject" do
      let(:transaction) {
        Transaction.new(borrower: borrower, lender: watch.owner, watch: watch)
      }

      before do
        transaction.save
      end

      it "should reject a borrowing watch correctly." do
        sign_in_as(owner) do
          patch :reject,
          params: {
            id: transaction.id
          }
          transaction.reload
          expect(transaction.borrower).to eq(borrower)
          expect(transaction.lender).to eq(owner)
          expect(transaction.watch).to eq(watch)
          expect(transaction.watch).to eq(watch)
          expect(transaction.state).to eq(Transaction::REJECT)
          expect(transaction.watch.borrowing?).to be false
          expect(flash[:notice]).to include(Transaction::REJECT)

          expect(response).to redirect_to lending_path
        end
      end
    end
  end

  describe "DELETE" do
    let(:transaction) {
      Transaction.new(borrower: borrower, lender: watch.owner, watch: watch)
    }

    before do
      transaction.save
    end

    describe "destroy" do
      it "should destroy borrowing correctly." do
        expect {
          sign_in_as(borrower) do
            delete :destroy,
            params: {
              id: transaction.id
            }

            expect(response).to redirect_to borrows_path
          end
        }.to change{Transaction.count}.by(-1)
      end
    end
  end
end
