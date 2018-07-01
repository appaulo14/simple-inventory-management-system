require_relative './abstract_inventory_api_model.rb'

module ApiModel
module Inventory
class AbstractInventoryAmountAdjuster < ApiModel::Inventory::AbstractInventoryApiModel
  
    attr_accessor :inventory_item
    attr_accessor :amount
	
    attr_accessor :update_db_error_msg
	attr_accessor :update_db_success_msg
	
    validates :inventory_item, :presence => true
    validates :amount, :presence => true,
                       :numericality => { only_integer: true, greater_than: 0 }

    def initialize(inventory_item,amount)
        @inventory_item = inventory_item
        @amount         = amount.to_i
    end
  
    def update_db
        # Implement in sub-classes.
	end
end
end
end
