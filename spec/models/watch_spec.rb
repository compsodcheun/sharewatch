require 'rails_helper'

RSpec.describe Watch, type: :model do
  describe "Field Matchers" do
    it { is_expected.to have_field(:name).of_type(String) }
    it { is_expected.to have_field(:detail).of_type(String).with_default_value_of("") }
  end

  describe "Association Matchers" do
    it { is_expected.to have_one(:own) }
    it { is_expected.to have_many(:images) }
    it { is_expected.to have_many(:transactions) }
  end

  describe "Validation Matchers" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
