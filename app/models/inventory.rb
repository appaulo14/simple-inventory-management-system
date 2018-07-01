class Inventory < ApplicationRecord
  belongs_to :product
  belongs_to :distribution_center

  validates :product_id, uniqueness: true
  validates_presence_of :available_amount, :reserved_amount
  validates :available_amount, numericality: { only_integer: true, greater_than: -1 }
  validates :reserved_amount, numericality: { only_integer: true, greater_than: -1 }
end
