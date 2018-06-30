shared_examples_for 'a collection GET request' do
  
    it 'returns a collection' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(@collection.length)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
	
	it 'should maybe handle empty lists correctly.'
	
end

shared_examples_for 'an individual item GET request' do
  context 'when the record exists' do
	before(:each) do
		@item=FactoryBot.create(@mock_name,distribution_center_id: @distribution_center.id)
		get "#{@request_string_prefix}/#{@item.id}"
	end
  
      it 'returns the individual item' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(@item.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
		before(:each) do
			get "#{@request_string_prefix}/1000"
		end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/not found/)
      end
    end
end

shared_examples_for "it validates the 'amount' parameter" do
	before(:each) do
		@item=FactoryBot.create(@mock_name, distribution_center_id: @distribution_center.id)
	end

	context 'when amount parameter is missing' do
		before { patch "#{@request_string_prefix}/#{@item.id}/#{@operation}", params: {} }

		it 'return status code 422' do
			expect(response).to have_http_status(422)
		end

		it 'should give a proper error message' do
			expect(response.body).to match(/must be greater than 0/)
		end
	end

	context 'when amount parameter is not a number' do
		before { patch "#{@request_string_prefix}/#{@item.id}/#{@operation}", params: { amount: 'paul' } }

		it 'return status code 422' do
			expect(response).to have_http_status(422)
		end

		it 'should give a proper error message' do
			expect(response.body).to match(/must be greater than 0/)
		end
	end

	context 'when amount parameter is a negative number' do
		before { patch "#{@request_string_prefix}/#{@item.id}/#{@operation}", params: { amount: -1 } }

		it 'return status code 422' do
			expect(response).to have_http_status(422)
		end

		it 'should give a proper error message' do
			expect(response.body).to match(/must be greater than 0/)
		end
	end

	context 'when amount parameter is 0' do
		before { patch "#{@request_string_prefix}/#{@item.id}/#{@operation}", params: { amount: 0 } }

		it 'return status code 422' do
			expect(response).to have_http_status(422)
		end

		it 'should give a proper error message' do
			expect(response.body).to match(/must be greater than 0/)
		end
	end
end
