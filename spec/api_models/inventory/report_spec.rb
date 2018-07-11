require 'rails_helper'
require_relative '../../../app/api_models/inventory/report.rb'

RSpec.describe Report, type: :model do
    describe 'validation' do
        before(:each) do
            @distribution_center = FactoryBot.create(:distribution_center)
            @it                  = Report.new(@distribution_center.id)
        end
    
        it 'should be valid when all attributes are set correctly.' do
            expect(@it.valid?).to eq(true)
        end
        
        describe 'distribution_center_id attribute' do
            it 'should validate presence.' do
                @it.distribution_center_id = nil
                expect(@it.valid?).to eq(false)
            end
            
            it 'should not be valid when 0' do
                @it.distribution_center_id = 0
                expect(@it.valid?).to eq(false)
            end
            
            it 'should not be valid when non-numeric' do
                @it.distribution_center_id = 'paul'
                expect(@it.valid?).to eq(false)
            end
            
            it 'should be valid when greater than 0' do
                @it.distribution_center_id = 1
                expect(@it.valid?).to eq(true)
            end
        end
    end
    
    describe 'when running query() to generate the report' do    
        context 'when everything is good' do
            before(:each) do
                @distribution_center = FactoryBot.create(:distribution_center)
                @inventory_items     = FactoryBot.create_list(:inventory, 10, distribution_center_id: @distribution_center.id) 
                @it                  = Report.new(@distribution_center.id)
                @query_results       = @it.query()
            end
            
            it 'should have 10 results' do
                expect(@query_results.length).to eq(10)
            end
        end
    end
end
