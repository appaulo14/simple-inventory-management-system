class ProductsController < ApplicationController
  # GET /products
  def index
    @products = Product.all
    json_response(@products)
  end
end
