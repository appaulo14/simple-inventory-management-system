###
# Model class to represent a distribution center, a physical place 
# that stores inventory.
class DistributionCenter < ApplicationRecord
    has_many :inventory, dependent: :destroy
    validates_presence_of :name, :location
end
