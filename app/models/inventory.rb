###
# Model class to represent an inventory item, which is a specific product in 
# a specific distribution center. For example, an inventory item might 
# contain the information on how many Toyota Corollas are available and 
# reserved at the Singapore distribution center.
class Inventory < ApplicationRecord
  belongs_to :product
  belongs_to :distribution_center

  validates_presence_of :product_id, :available_amount, :reserved_amount
  validates :available_amount, numericality: { only_integer: true, greater_than: -1 }
  validates :reserved_amount, numericality: { only_integer: true, greater_than: -1 }
end
