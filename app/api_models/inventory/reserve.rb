require_relative './abstract_inventory_amount_adjuster.rb'

###
# Handles reserving the given amount from the available amount (on-hand stock)
# to the reserved amount for a given inventory item.
class Reserve < AbstractInventoryAmountAdjuster
    
    def update_db()
        # Don't update db if attributes not valid.
        if not valid?
            return false
        end

        begin 
            Inventory.update_counters @inventory_item.id, :available_amount => -(@amount.abs), :reserved_amount => @amount
	        @update_db_success_msg = "#{@amount} successfully reserved for inventory item #{@inventory_item.id}."
            return true
        rescue ActiveRecord::StatementInvalid => ex
            if ex.to_s.include? "available_amount_cannot_go_below_zero"
                @inventory_item.reload()
                @update_db_error_msg = "Available inventory amount cannot go below 0. Current amount: #{@inventory_item.available_amount}. Amount attempting to reserve: #{amount}."
            else
                @update_db_error_msg = "Unknown database error."
            end
            return false
        end
    end
end
