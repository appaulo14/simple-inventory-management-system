require 'rails_helper'


RSpec.describe 'Distribution Center API', type: :request do
  describe 'GET /distribution_centers' do
    let!(:distribution_centers) { create_list(:distribution_center, 10) }
    # make HTTP get request before each example
	before (:each) do
	  @collection = distribution_centers
	  get "/distribution_centers"
    end
	
	it_should_behave_like 'a collection GET request'
	
  end
  
  describe 'GET /distribution_centers/:id' do
	before (:each) do
		@mock_name             = :distribution_center
		@request_string_prefix = "/distribution_centers"
	end
	
	it_should_behave_like 'an individual item GET request'
  end
end