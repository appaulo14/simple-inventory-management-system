###
# Model class to represent a unique type of an item, such as a Toyota Corolla
# or iPhone 6s gold model A1634.
class Product < ApplicationRecord
  has_many :inventory, dependent: :destroy
  validates_presence_of :name, :description
end
