require 'csv'

class InventoryController < ApplicationController
  # GET /inventory
  def index
    @inventory_items = Inventory.where(distribution_center_id: params[:distribution_center_id])
    if not params[:format].present?
        format = "json"
    else
        format = params[:format]
    end
    if format == "json"
        json_response(@inventory_items)
    elsif format == "csv"
        csv_response(@inventory_items)
    else
        return render status: 422, json: {
            message: "The 'format' parameter must be set to either 'json' or 'csv'.",
        }.to_json
    end
  end

  # POST /inventory
  def create
    render status: 422, json: {
        message: "Inventory creation not supported. Did you want to adjust the level available using PUT/PATCH?",
    }.to_json
  end

  # GET /inventory/:id
  def show
    @inventory_item = Inventory.find(params[:id])
    json_response(@inventory_item)
  end

  # PUT/PATCH /inventory/:id
  def update
    # TODO: More parameter validation.
    # TODO: Switch to ViewModel?
    if not params[:operation].present?
        return render status: 422, json: {
            message: "An operation must be specified using the 'operation' parameter as one of the following options: TODO",
        }.to_json
    end
    
    if not params[:amount].present?
        return render status: 422, json: {
            message: "Missing required parameter 'amount'.",
        }.to_json
    end
    operation = params[:operation]

    if params[:amount] !~ /\A\d+\z/ or params[:amount] == "0"
        return render status: 422, json: {
            message: "Parameter 'amount' must be an integer greater than 0.",
        }.to_json
    end
    amount = params[:amount].to_i
    id     = params[:id]
    case operation
    when 'add_to_available_amount'
        Inventory.update_counters id, :available_amount => amount
    when 'remove_from_available_amount'
        amount = -(amount.abs) # Make sure the amount is negative.
        Inventory.update_counters id, :available_amount => amount
    when 'reserve'
        Inventory.update_counters params[:id], :available_amount => -(amount.abs), :reserved_amount => amount
    when 'move_reserved_back_to_available'
        Inventory.update_counters params[:id], :available_amount => amount, :reserved_amount => -(amount.abs)
    when 'remove_reserved'
        amount = -(amount.abs) # Make sure the amount is negative.
        Inventory.update_counters id, :reserved_amount => amount
    else
        return render status: 422, json: {
            message: "'#{operation}' is not a valid operation. Must be specified as one of the following options: TODO",
        }.to_json
    end
    #head :no_content
  end

  # DELETE /inventory/:id
  def destroy
    render status: 422, json: {
        message: "Inventory deletion not supported. Did you want to adjust the level available using PUT/PATCH?",
    }.to_json
  end

  private

  def inventory_params
    # whitelist params
    params.require(:action_type).permit(:available_amount, :reserved_amount)
  end
end

