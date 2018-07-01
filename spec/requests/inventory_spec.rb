require 'rails_helper'


RSpec.describe 'Inventory API', type: :request do
  # initialize test data
  before(:each) do
    @distribution_center= FactoryBot.create(:distribution_center)
  end

  describe 'GET /distribution_centers/:distribution_center_id/inventory' do
    let!(:inventory_items) { create_list(:inventory, 10, distribution_center_id: @distribution_center.id) }
    # make HTTP get request before each example
	before (:each) do
	  @collection = inventory_items
	  get "/distribution_centers/#{@distribution_center.id}/inventory"
    end
	
	it_should_behave_like 'a collection GET request'
	
  end
  
  describe 'GET /distribution_centers/:distribution_center_id/inventory/:id' do
	before (:each) do
		@mock_name             = :inventory
		@request_string_prefix = "/distribution_centers/#{@distribution_center.id}/inventory"
	end
	
	it_should_behave_like 'an individual item GET request'
  end

  context 'for a PATCH operation when inventory item does not exist' do
    it 'raises a routing error' do
      expect{ patch "/distribution_centers/#{@distribution_center.id}/inventory/1000000"}.to raise_error(ActionController::RoutingError)
    end
  end

  # Rails uses PATCH for partial updates. See https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/
  describe 'PATCH /distribution_centers/:distribution_center_id/inventory/:id/add_to_available_amount' do
	let!(:inventory) { create(:inventory, distribution_center_id: @distribution_center.id) }
	before (:each) do
		@mock_name             = :inventory
		@request_string_prefix = "/distribution_centers/#{@distribution_center.id}/inventory"
	end
	
	context 'when adding to the available amount of inventory' do
		before (:each) do
			@operation = 'add_to_available_amount'
		end
		it_should_behave_like "it validates the 'amount' parameter"
	
		context 'when amount parameter is a positive integer' do
			let(:valid_attributes) { { amount: 2 } }
			let!(:inventory) { create(:inventory, distribution_center_id: @distribution_center.id, available_amount: 5, reserved_amount: 10) }
			before { patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: valid_attributes }

			it 'updates the available_amount' do
				inventory.reload()
				expect(inventory.available_amount).to eq(7)
			end

			it 'does not update the reserved_amount' do
				inventory.reload()
				expect(inventory.reserved_amount).to eq(10)
			end

			it 'returns status code 200' do
				expect(response).to have_http_status(200)
			end

			context 'when multiple simultaneous users' do
				# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
				it 'should handle race conditions correctly.' do
					expect(ActiveRecord::Base.connection.pool.size).to eq(5)
					concurrency_level = 4
					inventory         = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id,available_amount: 0)
					fail_occurred     = false
					wait_for_it       = true
					
					threads = concurrency_level.times.map do |i|
					  Thread.new do
						true while wait_for_it
						  patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: {amount: 1}
					  end
					end
					wait_for_it = false
					threads.each(&:join)

					inventory.reload()
					expect(inventory.available_amount).to eq(concurrency_level)
				end
			end
		end
	end

	describe 'PATCH /distribution_centers/:distribution_center_id/inventory/:id/remove_from_available_amount' do
		before (:each) do
			@operation = 'remove_from_available_amount'
		end
		
		it_should_behave_like "it validates the 'amount' parameter"
		
		it 'should raise an exception and not modify anything when amount parameter tries to remove to below 0' do
			inventory = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id, available_amount: 5, reserved_amount: 10)
			patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: { amount: 6 } 
			expect(response.status).to eq(409)
			inventory.reload()
			expect(inventory.available_amount).to eq(5)
			expect(inventory.reserved_amount).to eq(10)
		end

		context 'when amount parameter is <= to the available amount' do
			let(:valid_attributes) { { amount: 5 } }
			let!(:inventory) { create(:inventory, distribution_center_id: @distribution_center.id, available_amount: 5, reserved_amount: 10) }
			before { patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: valid_attributes }

			it 'updates the available_amount' do
				inventory.reload()
				expect(inventory.available_amount).to eq(0)
			end

			it 'does not update the reserved_amount' do
				inventory.reload()
				expect(inventory.reserved_amount).to eq(10)
			end

			it 'returns status code 200' do
				expect(response).to have_http_status(200)
			end

			context 'when multiple simultaneous users' do
				# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
				it 'should handle race conditions correctly.' do
					expect(ActiveRecord::Base.connection.pool.size).to eq(5)
					concurrency_level = 4
					inventory         = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id, available_amount: concurrency_level - 1)
					fail_occurred     = false
					wait_for_it       = true
					
					threads = concurrency_level.times.map do |i|
					  Thread.new do
						true while wait_for_it
						   patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: {amount: 1}
							if (response.status == 409)
							   fail_occurred = true
						   end
					  end
					end
					wait_for_it = false
					threads.each(&:join)

					inventory.reload()	
					expect(fail_occurred).to eq(true)
					expect(inventory.available_amount).to eq(0)
				end
			end
		end
	end
		
	describe 'PATCH /distribution_centers/:distribution_center_id/inventory/:id/reserve' do
		before (:each) do
			@operation = 'reserve'
		end
	
		it_should_behave_like "it validates the 'amount' parameter"
	
		it 'should raise return 409 response and not modify anything if the request tries to reserve than is available' do
			inventory = FactoryBot.create(:inventory, distribution_center_id: @distribution_center.id, available_amount: 5, reserved_amount: 10)
			patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: { amount: 6 }
			expect(response.status).to eq(409)
			inventory.reload()
			expect(inventory.available_amount).to eq(5)
			expect(inventory.reserved_amount).to eq(10)
		end
		
		context 'when amount parameter is <= to the available amount.' do
			let(:valid_attributes) { { operation: @operation, amount: 5 } }
			let!(:inventory) { create(:inventory, distribution_center_id: @distribution_center.id, available_amount: 5, reserved_amount: 0) }
			before { patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: valid_attributes }

			it 'removes from the available_amount' do
				inventory.reload()
				expect(inventory.available_amount).to eq(0)
			end

			it 'adds to the reserved_amount' do
				inventory.reload()
				expect(inventory.reserved_amount).to eq(5)
			end

			it 'returns status code 200' do
				expect(response).to have_http_status(200)
			end

			context 'when multiple simultaneous users' do
				# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
				it 'should handle race conditions correctly.' do
					expect(ActiveRecord::Base.connection.pool.size).to eq(5)
					concurrency_level = 4
					inventory         = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id,available_amount: concurrency_level - 1,reserved_amount: 0)
					fail_occurred     = false
					wait_for_it       = true
					
					threads = concurrency_level.times.map do |i|
					  Thread.new do
						true while wait_for_it
						patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: {amount: 1}
						if response.status == 409
							fail_occurred = true
						end
					  end
					end
					wait_for_it = false
					threads.each(&:join)

					inventory.reload()	
					expect(fail_occurred).to eq(true)
					expect(inventory.available_amount).to eq(0)
					expect(inventory.reserved_amount).to eq(concurrency_level-1)
				end
			end
		end
	end
		
	describe 'PATCH /distribution_centers/:distribution_center_id/inventory/:id/move_reserved_back_to_available' do
		before (:each) do
			@operation = 'move_reserved_back_to_available'
		end
	
		it_should_behave_like "it validates the 'amount' parameter"
	
		it 'should return a 409 response and not modify anything if the request tries to move back to available more than there is' do
			inventory = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id, available_amount: 0, reserved_amount: 5)
			patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: { amount: 6 }
			expect(response.status).to eq(409)
			inventory.reload()
			expect(inventory.available_amount).to eq(0)
			expect(inventory.reserved_amount).to eq(5)
		end
		
		context 'when amount parameter is <= to the reserved amount.' do
			let!(:inventory) { create(:inventory, distribution_center_id: @distribution_center.id, available_amount: 0, reserved_amount: 5) }
			before { patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: {amount: 5} }

			it 'removes from the reserved_amount' do
				inventory.reload()
				expect(inventory.reserved_amount).to eq(0)
			end

			it 'adds to the available_amount' do
				inventory.reload()
				expect(inventory.available_amount).to eq(5)
			end

			it 'returns status code 200' do
				expect(response).to have_http_status(200)
			end

			context 'when multiple simultaneous users' do
				# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
				it 'should handle race conditions correctly.' do
					expect(ActiveRecord::Base.connection.pool.size).to eq(5)
					concurrency_level = 4
					inventory         = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id, available_amount: 0,reserved_amount:  concurrency_level - 1)
					fail_occurred     = false
					wait_for_it       = true
					
					threads = concurrency_level.times.map do |i|
					  Thread.new do
						true while wait_for_it
						patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: {amount: 1}
						if response.status == 409
							fail_occurred = true
						end
					  end
					end
					wait_for_it = false
					threads.each(&:join)

					inventory.reload()	
					expect(fail_occurred).to eq(true)
					expect(inventory.available_amount).to eq(concurrency_level-1)
					expect(inventory.reserved_amount).to eq(0)
				end
			end
		end
	end
			
	describe 'PATCH /distribution_centers/:distribution_center_id/inventory/:id/removed_reserved' do
		before (:each) do
			@operation = 'remove_reserved'
		end
	
		it_should_behave_like "it validates the 'amount' parameter"
	
		it 'should return a 409 response and not modify anything if the request tries to remove move than there is' do
			inventory = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id,available_amount: 0, reserved_amount: 5)
			patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: { amount: 6 }
			expect(response.status).to eq(409)
			inventory.reload()
			expect(inventory.available_amount).to eq(0)
			expect(inventory.reserved_amount).to eq(5)
		end
	
		context 'when amount parameter is <= to the reserved amount.' do
			let(:valid_attributes) { { amount: 5 } }
			let!(:inventory) { create(:inventory, distribution_center_id: @distribution_center.id, available_amount: 0, reserved_amount: 5) }
			before { patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: valid_attributes }

			it 'removes from the reserved_amount' do
				inventory.reload()
				expect(inventory.reserved_amount).to eq(0)
			end

			it 'does not change the available amount' do
				inventory.reload()
				expect(inventory.available_amount).to eq(0)
			end

			it 'returns status code 200' do
				expect(response).to have_http_status(200)
			end

			context 'when multiple simultaneous users' do
				# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
				it 'should handle race conditions correctly.' do
					expect(ActiveRecord::Base.connection.pool.size).to eq(5)
					concurrency_level = 4
					inventory         = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id,reserved_amount: concurrency_level - 1)
					fail_occurred     = false
					wait_for_it       = true
					
					threads = concurrency_level.times.map do |i|
					  Thread.new do
						true while wait_for_it
						   patch "#{@request_string_prefix}/#{inventory.id}/#{@operation}", params: {amount: 1}
						   if response.status == 409
							   fail_occurred = true
						   end
					  end
					end
					wait_for_it = false
					threads.each(&:join)

					inventory.reload()	
					expect(fail_occurred).to eq(true)
					expect(inventory.reserved_amount).to eq(0)
				end
			end
		end
	end
	
	describe 'PATCH /distribution_centers/:distribution_center_id/inventory/:id/report' do
		it 'should describe reports'
	end

# POST is not supported for inventory items because for this example 
# inventory items cannot be created for a distribution center.
 it 'should not allow POST operations when given inventory id' do
      inventory = FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id)
      expect{post "/distribution_centers/#{@distribution_center.id}/inventory/#{inventory.id}", params: {}}.to raise_error(ActionController::RoutingError)
  end

 it 'should not allow POST operations whithout an inventory id' do
      expect{post "/distribution_centers/#{@distribution_center.id}/inventory", params: {}}.to raise_error(ActionController::RoutingError)
  end

  # DELETE /distribution_centers/:distribution_center_id/inventory/:id'
  it 'should not allow DELETE operations' do 
      inventory=FactoryBot.create(:inventory,distribution_center_id: @distribution_center.id)
      expect {delete "/distribution_centers/#{@distribution_center.id}/inventory/#{inventory.id}", params: {}}.to raise_error(ActionController::RoutingError)
  end
end

