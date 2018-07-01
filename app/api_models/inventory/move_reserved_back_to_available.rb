require_relative './abstract_inventory_amount_adjuster.rb'

class MoveReservedBackToAvailable < AbstractInventoryAmountAdjuster

    
    def update_db()
        # Don't update db if attributes not valid.
        if not valid?
            return false
        end

        begin 
            Inventory.update_counters @inventory_item.id, :available_amount => amount, :reserved_amount => -(amount.abs)
			@update_db_success_msg = "#{@amount} successfully moved from reserved back to available for inventory item #{@inventory_item.id}."
			return true
        rescue ActiveRecord::StatementInvalid => ex
            if ex.to_s.include? "reserved_amount_cannot_go_below_zero"
                @update_db_error_msg = "Reserved inventory amount cannot go below 0. Current amount: #{@inventory_item.reserved_amount}. Amount attempting to move: #{amount}."
            else
                @update_db_error_msg = "Unknown database error."
            end
            return false
        end
    end
end
