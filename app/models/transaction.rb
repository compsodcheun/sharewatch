class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :skip_flood

  PENDING = 'pending'.freeze
  APPROVE = 'approve'.freeze
  REJECT = 'reject'.freeze

  field :state, type: String, default: Transaction::PENDING

  belongs_to :watch, class_name: "Watch"
  belongs_to :lender, class_name: "User", inverse_of: :lending
  belongs_to :borrower, class_name: "User", inverse_of: :borrowing

  validate :flood_transaction, unless: :skip_flood
  before_save :update_watch_status
  before_destroy :returns

  def self.color
    {
      "#{Transaction::PENDING}" => 'warning',
      "#{Transaction::APPROVE}" => 'success',
      "#{Transaction::REJECT}" => 'danger'
    }
  end

  def update_watch_status
    if state.eql? Transaction::APPROVE
      watch.is_borrowing = true
      watch.save
    end
  end

  def returns
    if state.eql? Transaction::APPROVE
      watch.is_borrowing = false
      watch.save
    end
  end

  def flood_transaction
    flood_transaction = Transaction.where(
      watch: watch,
      borrower: borrower,
      state: Transaction::PENDING
    ).present?
    errors.add(:base, "You have already borrowing this watch!") if flood_transaction
  end
end
