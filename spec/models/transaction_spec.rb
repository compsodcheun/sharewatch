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
end
