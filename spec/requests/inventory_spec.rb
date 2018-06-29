require 'rails_helper'
#require 'shared_examples.rb'
#require 'shared_examples.rb'

# TODO: Test larger inventory values.

RSpec.describe 'Inventory API', type: :request do
  # initialize test data
  let!(:distribution_center) {create(:distribution_center)}

  describe 'GET /distribution_centers/:distribution_center_id/inventory' do
    let!(:inventory_items) { create_list(:inventory, 10, distribution_center_id: distribution_center.id) }
    # make HTTP get request before each example
	before (:each) do
	  @collection = inventory_items
	  get "/distribution_centers/#{distribution_center.id}/inventory"
    end
	
	it_should_behave_like 'a collection GET request'
	
  end
  
  describe 'GET /distribution_centers/:distribution_center_id/inventory/:id' do
	before (:each) do
		@mock_name             = :inventory
		@request_string_prefix = "/distribution_centers/#{distribution_center.id}/inventory"
	end
	
	it_should_behave_like 'an individual item GET request'
  end

  # Rails uses PATCH for partial updates. See https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/
  describe 'PATCH /distribution_centers/:distribution_center_id/inventory/:id' do
	before (:each) do
		@mock_name             = :inventory
		@request_string_prefix = "/distribution_centers/#{distribution_center.id}/inventory"
	end
	
	context 'when inventory item does not exist' do
	  before { patch "/distribution_centers/#{distribution_center.id}/inventory/1000000" }

	  it 'returns status code 404' do
		expect(response).to have_http_status(404)
	  end

	  it 'returns a not found message' do
		expect(response.body).to match(/Couldn't find/)
	  end
	end
  
	context 'when inventory item exists' do
		let!(:inventory) { create(:inventory, distribution_center_id: distribution_center.id) }
	
		context 'when operation parameter contains an invalid operation' do 
			let(:invalid_attributes) {{ operation: 'not_a_real_operation', amount:5 }}
			before { patch "/distribution_centers/#{distribution_center.id}/inventory/#{inventory.id}", params: invalid_attributes }
			
			it 'return status code 422' do
				expect(response).to have_http_status(422)
			end
			
			it 'should give a proper error message' do
				expect(response.body).to match(/not a valid operation/)
			end
		end
	
		context 'when operation parameter not specified' do
			let(:invalid_attributes) {{}}
			before { patch "/distribution_centers/#{distribution_center.id}/inventory/#{inventory.id}", params: invalid_attributes }
			
			it 'return status code 422' do
				expect(response).to have_http_status(422)
			end
			
			it 'should give a proper error message' do
				expect(response.body).to match(/An operation must be specified using the 'operation' parameter/)
			end
		end
	
		context 'when adding to the available amount of inventory' do
			before (:each) do
				@operation = 'add_to_available_amount'
			end
			it_should_behave_like "it validates the 'amount' parameter"
		
			context 'when amount parameter is a positive integer' do
				let(:valid_attributes) { { operation: @operation, amount: 2 } }
				let!(:inventory) { create(:inventory, distribution_center_id: distribution_center.id, available_amount: 5, reserved_amount: 10) }
				before { patch "#{@request_string_prefix}/#{inventory.id}", params: valid_attributes }

				it 'has no response body' do
					expect(response.body).to be_empty
				end

				it 'updates the available_amount' do
					inventory.reload()
					expect(inventory.available_amount).to eq(7)
				end

				it 'does not update the reserved_amount' do
					inventory.reload()
					expect(inventory.reserved_amount).to eq(10)
				end

				it 'returns status code 204' do
					expect(response).to have_http_status(204)
				end

				context 'when multiple simultaneous users' do
					# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
					it 'should handle race conditions correctly.' do
						expect(ActiveRecord::Base.connection.pool.size).to eq(5)
						concurrency_level = 4
						inventory         = FactoryBot.create(:inventory,available_amount: 0)
						fail_occurred     = false
						wait_for_it       = true
						
						threads = concurrency_level.times.map do |i|
						  Thread.new do
							true while wait_for_it
							begin
							   patch "#{@request_string_prefix}/#{inventory.id}", params: {operation: @operation, amount: 1}
							rescue ActiveRecord::StatementInvalid
							  fail_occurred = true
							end
						  end
						end
						wait_for_it = false
						threads.each(&:join)

						inventory.reload()	
						expect(fail_occurred).to eq(false)
						expect(inventory.available_amount).to eq(concurrency_level)
					end
				end
				
			end
		end

		context 'when removing from the available amount of inventory' do
			before (:each) do
				@operation = 'remove_from_available_amount'
			end
			
			it_should_behave_like "it validates the 'amount' parameter"
			
			it 'should raise an exception and not modify anything when amount parameter tries to remove to below 0' do
				inventory = FactoryBot.create(:inventory,available_amount: 5, reserved_amount: 10)
				expect {patch "#{@request_string_prefix}/#{inventory.id}", params: { operation: @operation, amount: 6 } }.to raise_error(ActiveRecord::StatementInvalid)
				inventory.reload()
				expect(inventory.available_amount).to eq(5)
				expect(inventory.reserved_amount).to eq(10)
			end

			context 'when amount parameter is <= to the available amount' do
				let(:valid_attributes) { { operation: @operation, amount: 5 } }
				let!(:inventory) { create(:inventory, distribution_center_id: distribution_center.id, available_amount: 5, reserved_amount: 10) }
				before { patch "#{@request_string_prefix}/#{inventory.id}", params: valid_attributes }

				it 'has no response body' do
					expect(response.body).to be_empty
				end

				it 'updates the available_amount' do
					inventory.reload()
					expect(inventory.available_amount).to eq(0)
				end

				it 'does not update the reserved_amount' do
					inventory.reload()
					expect(inventory.reserved_amount).to eq(10)
				end

				it 'returns status code 204' do
					expect(response).to have_http_status(204)
				end

				context 'when multiple simultaneous users' do
					# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
					it 'should handle race conditions correctly.' do
						expect(ActiveRecord::Base.connection.pool.size).to eq(5)
						concurrency_level = 4
						inventory         = FactoryBot.create(:inventory,available_amount: concurrency_level - 1)
						fail_occurred     = false
						wait_for_it       = true
						
						threads = concurrency_level.times.map do |i|
						  Thread.new do
							true while wait_for_it
							begin
							   patch "#{@request_string_prefix}/#{inventory.id}", params: {operation: @operation, amount: 1}
							rescue ActiveRecord::StatementInvalid
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
		
		context 'when reserving items' do
			before (:each) do
				@operation = 'reserve'
			end
		
			it_should_behave_like "it validates the 'amount' parameter"
		
			it 'should raise an exception and not modify anything if the request tries to reserve from than is available' do
				inventory = FactoryBot.create(:inventory,available_amount: 5, reserved_amount: 10)
				expect {patch "#{@request_string_prefix}/#{inventory.id}", params: { operation: @operation, amount: 6 } }.to raise_error(ActiveRecord::StatementInvalid)
				inventory.reload()
				expect(inventory.available_amount).to eq(5)
				expect(inventory.reserved_amount).to eq(10)
			end
			
			context 'when amount parameter is <= to the available amount.' do
				let(:valid_attributes) { { operation: @operation, amount: 5 } }
				let!(:inventory) { create(:inventory, distribution_center_id: distribution_center.id, available_amount: 5, reserved_amount: 0) }
				before { patch "#{@request_string_prefix}/#{inventory.id}", params: valid_attributes }

				it 'has no response body' do
					expect(response.body).to be_empty
				end

				it 'removes from the available_amount' do
					inventory.reload()
					expect(inventory.available_amount).to eq(0)
				end

				it 'adds to the reserved_amount' do
					inventory.reload()
					expect(inventory.reserved_amount).to eq(5)
				end

				it 'returns status code 204' do
					expect(response).to have_http_status(204)
				end

				context 'when multiple simultaneous users' do
					# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
					it 'should handle race conditions correctly.' do
						expect(ActiveRecord::Base.connection.pool.size).to eq(5)
						concurrency_level = 4
						inventory         = FactoryBot.create(:inventory,available_amount: concurrency_level - 1,reserved_amount: 0)
						fail_occurred     = false
						wait_for_it       = true
						
						threads = concurrency_level.times.map do |i|
						  Thread.new do
							true while wait_for_it
							begin
							   patch "#{@request_string_prefix}/#{inventory.id}", params: {operation: @operation, amount: 1}
							rescue ActiveRecord::StatementInvalid
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
		
		context 'when moving reserved items back to the available inventory' do
			before (:each) do
				@operation = 'move_reserved_back_to_available'
			end
		
			it_should_behave_like "it validates the 'amount' parameter"
		
			it 'should raise an exception and not modify anything if the request tries to move back to available more than there is' do
				inventory = FactoryBot.create(:inventory,available_amount: 0, reserved_amount: 5)
				expect {patch "#{@request_string_prefix}/#{inventory.id}", params: { operation: @operation, amount: 6 } }.to raise_error(ActiveRecord::StatementInvalid)
				inventory.reload()
				expect(inventory.available_amount).to eq(0)
				expect(inventory.reserved_amount).to eq(5)
			end
			
			context 'when amount parameter is <= to the reserved amount.' do
				let(:valid_attributes) { { operation: @operation, amount: 5 } }
				let!(:inventory) { create(:inventory, distribution_center_id: distribution_center.id, available_amount: 0, reserved_amount: 5) }
				before { patch "#{@request_string_prefix}/#{inventory.id}", params: valid_attributes }

				it 'has no response body' do
					expect(response.body).to be_empty
				end

				it 'removes from the reserved_amount' do
					inventory.reload()
					expect(inventory.reserved_amount).to eq(0)
				end

				it 'adds to the available_amount' do
					inventory.reload()
					expect(inventory.available_amount).to eq(5)
				end

				it 'returns status code 204' do
					expect(response).to have_http_status(204)
				end

				context 'when multiple simultaneous users' do
					# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
					it 'should handle race conditions correctly.' do
						expect(ActiveRecord::Base.connection.pool.size).to eq(5)
						concurrency_level = 4
						inventory         = FactoryBot.create(:inventory,available_amount: 0,reserved_amount:  concurrency_level - 1)
						fail_occurred     = false
						wait_for_it       = true
						
						threads = concurrency_level.times.map do |i|
						  Thread.new do
							true while wait_for_it
							begin
							   patch "#{@request_string_prefix}/#{inventory.id}", params: {operation: @operation, amount: 1}
							rescue ActiveRecord::StatementInvalid
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
			
		context 'when removing items from reserved inventory' do
			before (:each) do
				@operation = 'remove_reserved'
			end
		
			it_should_behave_like "it validates the 'amount' parameter"
		
			it 'should raise an exception and not modify anything if the request tries to remove move than there is' do
				inventory = FactoryBot.create(:inventory,available_amount: 0, reserved_amount: 5)
				expect {patch "#{@request_string_prefix}/#{inventory.id}", params: { operation: @operation, amount: 6 } }.to raise_error(ActiveRecord::StatementInvalid)
				inventory.reload()
				expect(inventory.available_amount).to eq(0)
				expect(inventory.reserved_amount).to eq(5)
			end
		
			context 'when amount parameter is <= to the reserved amount.' do
				let(:valid_attributes) { { operation: @operation, amount: 5 } }
				let!(:inventory) { create(:inventory, distribution_center_id: distribution_center.id, available_amount: 0, reserved_amount: 5) }
				before { patch "#{@request_string_prefix}/#{inventory.id}", params: valid_attributes }

				it 'has no response body' do
					expect(response.body).to be_empty
				end

				it 'removes from the reserved_amount' do
					inventory.reload()
					expect(inventory.reserved_amount).to eq(0)
				end

				it 'does not change the available amount' do
					inventory.reload()
					expect(inventory.available_amount).to eq(0)
				end

				it 'returns status code 204' do
					expect(response).to have_http_status(204)
				end

				context 'when multiple simultaneous users' do
					# Based off https://blog.arkency.com/2015/09/testing-race-conditions/
					it 'should handle race conditions correctly.' do
						expect(ActiveRecord::Base.connection.pool.size).to eq(5)
						concurrency_level = 4
						inventory         = FactoryBot.create(:inventory,reserved_amount: concurrency_level - 1)
						fail_occurred     = false
						wait_for_it       = true
						
						threads = concurrency_level.times.map do |i|
						  Thread.new do
							true while wait_for_it
							begin
							   patch "#{@request_string_prefix}/#{inventory.id}", params: {operation: @operation, amount: 1}
							rescue ActiveRecord::StatementInvalid
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
		
	end
  end

  it 'should test patch too'
  
  it 'should have better error message for constraint failures that raise exceptions.'
  
  # Test POST /distribution_centers/:distribution_center_id/inventory
  # POST is not supported for inventory items because for this example 
  # inventory items cannot be created for a distribution center.
  describe 'POST /distribution_centers/:distribution_center_id/inventory' do
	  let!(:inventory) { create(:inventory, distribution_center_id: distribution_center.id )}
      before { post "/distribution_centers/#{distribution_center.id}/inventory/", params: {} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(/not supported/)
      end
    end
  
  # Test DELETE /distribution_centers/:distribution_center_id/inventory/:id
  # DELETE not supported for inventory items.
  describe 'DELETE /distribution_centers/:distribution_center_id/inventory/:id' do
      let!(:inventory) { create(:inventory, distribution_center_id: distribution_center.id) }
      before { delete "/distribution_centers/#{distribution_center.id}/inventory/#{inventory.id}", params: {} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(/not supported/)
      end
    end
end

