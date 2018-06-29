class DistributionCenter < ApplicationRecord
    has_many :inventory, dependent: :destroy
    validates_presence_of :name, :location
end
