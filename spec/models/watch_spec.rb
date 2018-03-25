require 'rails_helper'

RSpec.describe Watch, type: :model do
  describe "Field Matchers" do
    it { is_expected.to have_field(:name).of_type(String) }
    it { is_expected.to have_field(:detail).of_type(String)
      .with_default_value_of("")
    }
    it { is_expected.to have_field(:is_borrowing).of_type(Mongoid::Boolean)
      .with_default_value_of(false)
    }
  end

  describe "Association Matchers" do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to embed_many(:images) }
    it { is_expected.to have_many(:transactions) }
  end

  describe "Validation Matchers" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "Methods" do
    it "#borrowing?" do
      watch = create(:watch, owner: create(:user), is_borrowing: true)
      expect(watch.borrowing?).to be true
    end
  end
end
