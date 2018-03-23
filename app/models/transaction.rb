class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  PENDING = 'pending'.freeze
  APPROVE = 'approve'.freeze
  REJECT = 'reject'.freeze

  field :state, type: String, default: Transaction::PENDING

  belongs_to :watch, class_name: "Watch"
  belongs_to :lender, class_name: "User"
  belongs_to :borrower, class_name: "User"
end
