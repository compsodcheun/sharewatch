class Watch
  include Mongoid::Document

  field :name, type: String
  field :detail, type: String, default: ""

  has_one :own, class_name: "User"
  has_many :images, class_name: "Image"
  has_many :transactions, class_name: "Transaction"

  validates_presence_of :name
end
