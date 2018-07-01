require 'rails_helper'

RSpec.describe Inventory, type: :model do
    it { should belong_to(:product) }
    it { should belong_to(:distribution_center) }

    it { should validate_presence_of(:available_amount) }
    it { should validate_presence_of(:reserved_amount) }
    
    it { should validate_numericality_of(:available_amount) }
    it { should_not allow_value(-1).for(:available_amount) }
    it { should allow_value(0).for(:available_amount) }
    
    it { should validate_numericality_of(:reserved_amount) }
    it { should_not allow_value(-1).for(:reserved_amount) }
    it { should allow_value(0).for(:reserved_amount) }
    
    it 'should be able to handle multiple writers using the increment!() method' do
        FactoryBot.create(:inventory)
        copy_1                    = Inventory.first
        copy_2                    = Inventory.first
        original_available_amount = Inventory.first.available_amount
        
        # Increment using copy_1
        copy_1.increment!(:available_amount,2)
        # copy_2 should not have yet seen the update.
        expect(copy_2.available_amount).to eq(original_available_amount)
        # Decrement using copy_2, even though it's out-of-date.
        copy_2.increment!(:available_amount,3)
        # Reload both from database.
        copy_1.reload()
        copy_2.reload()
        # Confirm both increments were applied correctly.
        expect(copy_1.available_amount).to eq(original_available_amount + 5)
        expect(copy_2.available_amount).to eq(original_available_amount + 5)
    end
    
    it 'should be able to handle multiple writers using the decrement!() method' do
        FactoryBot.create(:inventory,available_amount: 10)
        copy_1                    = Inventory.first
        copy_2                    = Inventory.first
        original_available_amount = Inventory.first.available_amount
        
        # Decrement using copy_1
        copy_1.decrement!(:available_amount,2)
        # copy_2 should not have yet seen the update.
        expect(copy_2.available_amount).to eq(original_available_amount)
        # Decrement using copy_2, even though it's out-of-date.
        copy_2.decrement!(:available_amount,3)
        # Reload both from database.
        copy_1.reload()
        copy_2.reload()
        # Confirm both decrements were applied correctly.
        expect(copy_1.available_amount).to eq(original_available_amount - 5)
        expect(copy_2.available_amount).to eq(original_available_amount - 5)
    end
end
