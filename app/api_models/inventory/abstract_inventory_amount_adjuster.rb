require_relative './abstract_inventory_api_model.rb'

###
# Abstract class to handle making adjustments to the available and/or 
# reserved amounts of a given inventory item.
class AbstractInventoryAmountAdjuster < AbstractInventoryApiModel
  
    # The inventory item to update in the database.
    attr_accessor :inventory_item
    # The amount by which to update the inventory item in the database.
    attr_accessor :amount
    
    # The error message if an error while updating the database.
    attr_accessor :update_db_error_msg
    # The success message if the database was successfully updated. 
    attr_accessor :update_db_success_msg
    
    # Validation 
    validates :inventory_item, :presence => true
    validates :amount, :presence => true,
                       :numericality => { only_integer: true, greater_than: 0 }

    # Constructor
    def initialize(inventory_item,amount)
        @inventory_item = inventory_item
        @amount         = amount.to_i
    end
  
    ###
    # Update the database using the amount and inventory item set in
    # the attributes.
    def update_db
        # Implement in sub-classes.
    end
end
