require 'rails_helper'
require_relative '../../../app/api_models/inventory/remove_from_available_amount.rb'
require_relative './shared_examples.rb'

RSpec.describe RemoveFromAvailableAmount, type: :model do
    describe 'validation' do
        before(:each) do
            inventory_item = FactoryBot.create(:inventory)
            amount         = 5
            @it            = RemoveFromAvailableAmount.new(inventory_item, amount)
        end
    
        it 'should be valid when all attributes are set correctly.' do
            expect(@it.valid?).to eq(true)
        end
        
        it_should_behave_like 'it validates the inventory_item attribute'
        it_should_behave_like 'it validates the amount attribute'
    end
    
    describe 'when running update_db() to update the database' do    
        context 'when everything is good' do
            before(:each) do
                @inventory_item            = FactoryBot.create(:inventory, :available_amount => 5)
                @original_reserved_amount  = @inventory_item.reserved_amount
                @original_available_amount = @inventory_item.available_amount
                @amount_to_remove          = 5
                @it                        = RemoveFromAvailableAmount.new(@inventory_item, @amount_to_remove)
                @operation_result          = @it.update_db()
                @inventory_item.reload()
            end
            
            it 'should return true' do
                expect(@operation_result).to eq(true)
            end
            it 'should remove from the available amount by the specified amount' do
                expect(@inventory_item.available_amount).to eq(@original_available_amount - @amount_to_remove)
            end
            it 'should not modify the reserved amount' do
                expect(@inventory_item.reserved_amount).to eq(@original_reserved_amount)
            end
            it 'should have no validation errors' do
                expect(@it.errors.count).to eq(0)
            end
            it 'should have a success message' do
                expect(@it.update_db_success_msg).to match(/successfully/)
            end
            it 'should have no error message' do
                expect(@it.update_db_error_msg).to eq(nil)
            end
        end
        
        context 'when not valid' do
            before(:each) do
                @inventory_item            = FactoryBot.create(:inventory)
                @original_reserved_amount  = @inventory_item.reserved_amount
                @original_available_amount = @inventory_item.available_amount
                @it                        = RemoveFromAvailableAmount.new(@inventory_item, -1)
                @operation_result          = @it.update_db()
                @inventory_item.reload()
            end
        
            it 'should return false' do
                expect(@operation_result).to eq(false)
            end
            it 'should not update available amount' do
                expect(@inventory_item.available_amount).to eq(@original_available_amount)
            end
            it 'should not update the reserved amount' do
                expect(@inventory_item.reserved_amount).to eq(@original_reserved_amount)
            end
            it 'should populate the validation errors array' do
                expect(@it.errors.count).to be > 0
            end            
            it 'should have no success message' do
                expect(@it.update_db_success_msg).to eq(nil)
            end
            it 'should have no error message' do
                expect(@it.update_db_error_msg).to eq(nil)
            end
        end
        
        context 'when trying to remove more than is available' do
            before(:each) do
                @inventory_item            = FactoryBot.create(:inventory, :available_amount => 5)
                @original_reserved_amount  = @inventory_item.reserved_amount
                @original_available_amount = @inventory_item.available_amount
                @amount_to_remove          = 10
                @it                        = RemoveFromAvailableAmount.new(@inventory_item, @amount_to_remove)
                @operation_result          = @it.update_db()
                @inventory_item.reload()
            end
            
            it 'should return false' do
                expect(@operation_result).to eq(false)
            end
            it 'should not update available amount' do
                expect(@inventory_item.available_amount).to eq(@original_available_amount)
            end
            it 'should not update the reserved amount' do
                expect(@inventory_item.reserved_amount).to eq(@original_reserved_amount)
            end
            it 'should not have any validation errors' do
                expect(@it.errors.count).to eq(0)
            end            
            it 'should have no success message' do
                expect(@it.update_db_success_msg).to eq(nil)
            end
            it 'should have an update db error message' do
                expect(@it.update_db_error_msg).to match(/cannot go below 0/)
            end
        end
    end
end
