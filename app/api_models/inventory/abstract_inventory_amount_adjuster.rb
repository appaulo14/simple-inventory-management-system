module ApiModel
module Inventory
class AbstractInventoryAmountAdjuster
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  
    attr_accessor :inventory_item
    attr_accessor :amount
	
    attr_accessor :update_db_error_msg
	attr_accessor :update_db_success_msg
	
    validates :inventory_item, :presence => true
    validates :amount, :presence => true,
                       :numericality => { only_integer: true, greater_than: 0 }

    def initialize(inventory_item,amount)
        @inventory_item = inventory_item
        @amount         = amount
    end
  
    def update_db
		# Run validation. 
        if not valid?
            return false
        end
	end
  
    def persisted?
	  return false
    end
end
end
end