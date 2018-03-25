require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe "Field Matchers" do
    it {
      is_expected.to have_field(:state)
      .of_type(String)
      .with_default_value_of(Transaction::PENDING)
    }
    it { is_expected.to have_timestamps }
  end

  describe "Association Matchers" do
    it { is_expected.to belong_to(:borrower) }
    it { is_expected.to belong_to(:lender) }
    it { is_expected.to belong_to(:watch) }
  end

  describe "Validation" do
    let(:lender) { create(:user) }
    let(:borrower) { create(:user) }
    let(:watch) { create(:watch, owner: lender) }

    it "#flood_transaction" do
      transaction1 = Transaction.new(borrower: borrower, lender: lender, watch: watch)
      transaction1.save

      transaction2 = Transaction.new(borrower: borrower, lender: lender, watch: watch)
      transaction2.save

      transaction3 = Transaction.new(borrower: borrower, lender: lender, watch: watch)
      transaction3.save

      expect(transaction1.errors.full_messages).to be_blank
      expect(transaction2.errors.full_messages).to be_present
      expect(transaction3.errors.full_messages).to be_present
    end
  end

  describe "Callback" do
    let(:lender) { create(:user) }
    let(:borrower) { create(:user) }
    let(:watch) { create(:watch, owner: lender) }

    describe "before_save" do
      it "#update_watch_status" do
        transaction = Transaction.new(borrower: borrower, lender: lender, watch: watch)
        transaction.state = Transaction::APPROVE
        transaction.save

        expect(watch.borrowing?).to be true
      end
    end

    describe "before_destroy" do
      it "#returns" do
        transaction = Transaction.new(borrower: borrower, lender: lender, watch: watch)
        transaction.state = Transaction::APPROVE
        transaction.save

        expect(watch.reload.borrowing?).to be true
        transaction.destroy
        expect(watch.reload.borrowing?).to be false
      end
    end
  end
end
