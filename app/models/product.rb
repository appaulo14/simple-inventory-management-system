class Product < ApplicationRecord
  has_many :inventory, dependent: :destroy
  validates_presence_of :name, :description
end
