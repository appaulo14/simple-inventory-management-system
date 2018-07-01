require_relative './abstract_inventory_amount_adjuster.rb'

class AddToAvailableAmount < AbstractInventoryAmountAdjuster
    
    def update_db()
        # Don't update db if attributes not valid.
        if not valid?
            return false
        end

        begin 
            @inventory_item.increment!(:available_amount,@amount)
			@update_db_success_msg = "#{@amount} successfully added to the available amount of inventory item #{@inventory_item.id}."
			return true
        rescue ActiveRecord::StatementInvalid => ex
            @update_db_error_msg = "Unknown database error."
            return false
        end
    end
end
