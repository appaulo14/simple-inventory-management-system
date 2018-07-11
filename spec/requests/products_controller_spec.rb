require 'rails_helper'
require_relative './shared_examples.rb'

RSpec.describe 'Products API', type: :request do
  describe 'GET /products' do
    let!(:products) { create_list(:product, 10) }
    # make HTTP get request before each example
    before (:each) do
      @collection = products
      get "/products"
    end
    
    it_should_behave_like 'a collection GET request'
    
  end
  
  describe 'GET /products/:id' do
    before (:each) do
        @mock_name             = :product
        @request_string_prefix = "/products"
    end
    
    it_should_behave_like 'an individual item GET request'
  end
end