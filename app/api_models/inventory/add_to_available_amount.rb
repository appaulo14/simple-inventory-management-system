module ApiModel
module Inventory
class AddToAvailableAmount < AbstractInventoryAmountAdjuster
    
    def update_db()
        super

        begin 
            Inventory.update_counters @inventory_item.id, :available_amount => @amount
			@update_db_success_msg = "#{@amount} successfully added to inventory item #{@inventory_item.id}."
			return true
        rescue ActiveRecord::StatementInvalid => ex
            @update_db_error_msg = "Unknown database error."
            return false
        end
    end
end
end
end
