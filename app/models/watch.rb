class Watch
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :detail, type: String, default: ""
  field :is_borrowing, type: Mongoid::Boolean, default: false

  belongs_to :owner, class_name: "User", required: true
  embeds_many :images, class_name: "Image"
  has_many :transactions, class_name: "Transaction"

  validates_presence_of :name

  def borrowing?
    is_borrowing
  end
end
