require_relative './abstract_inventory_amount_adjuster.rb'

###
# Handles removing from the available amount (on-hand stock) of a 
# given inventory item.
class RemoveFromAvailableAmount < AbstractInventoryAmountAdjuster
    
    def update_db()
        # Don't update db if attributes not valid.
        if not valid?
            return false
        end

        begin 
            @inventory_item.decrement!(:available_amount, @amount.abs)
            @update_db_success_msg = "#{@amount} successfully removed from available amount for inventory item #{@inventory_item.id}."
            return true
        rescue ActiveRecord::StatementInvalid => ex
            if ex.to_s.include? "available_amount_cannot_go_below_zero"
                @inventory_item.reload()
                @update_db_error_msg = "Available inventory amount cannot go below 0. Current amount: #{@inventory_item.available_amount}. Amount attempting to remove: #{amount}."
            else
                @update_db_error_msg = "Unknown database error."
            end
            return false
        end
    end
end
