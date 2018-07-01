require 'csv'
require_relative '../api_models/inventory/report.rb'
require_relative '../api_models/inventory/add_to_available_amount.rb'
require_relative '../api_models/inventory/remove_from_available_amount.rb'
require_relative '../api_models/inventory/reserve.rb'
require_relative '../api_models/inventory/move_reserved_back_to_available.rb'
require_relative '../api_models/inventory/remove_reserved.rb'


class InventoryController < ApplicationController
  before_action :confirm_exists_in_distribution_center_and_set_inventory_item,
    :only => [:show, :add_to_available_amount, :remove_from_available_amount, 
              :reserve, :move_reserved_back_to_available, :remove_reserved]
  before_action :set_all_inventory_in_distribution_center,
	:only => [:index]

  # GET /inventory
  def index
    json_response(@inventory_items)
  end

  def report_as_json
    api_model = ApiModel::Inventory::Report.new(params[:distribution_center_id])
	# Skipping querying if parameters are invalid.
	if not api_model.valid?
		return render status: 422, json: { message: api_model.errors }.to_json
	end
	
	begin
		query_results = api_model.query()
		json_response(query_results)
	rescue ActiveRecord::StatementInvalid => ex
		return render status: 409, json: { message: "Unknown database error." }.to_json
	end
  end 
  
  def report_as_csv
	api_model = ApiModel::Inventory::Report.new(params[:distribution_center_id])
	# Skipping querying if parameters are invalid.
	if not api_model.valid?
		return render status: 422, json: { message: api_model.errors }.to_json
	end
	
	begin
		query_results = api_model.query()
		csv_response(query_results)
	rescue ActiveRecord::StatementInvalid => ex
		return render status: 409, json: { message: "Unknown database error." }.to_json
	end
  end

  # GET /distribution_centers/:distribution_center_id/inventory/:id
  def show
    json_response(@inventory_item)
  end

  # We use patch instead of put because patch is specifically for partial updates.
  # See: http://www.rfc-editor.org/rfc/rfc5789.txt
  
  # PATCH /distribution_centers/:distribution_center_id/inventory/:id/add_to_available_amount
  def add_to_available_amount
	api_model                = ApiModel::Inventory::AddToAvailableAmount.new(@inventory_item,params[:amount])
	was_operation_successful = api_model.update_db()
	handle_response_for_update_operation(was_operation_successful,api_model)
  end

  # PATCH /distribution_centers/:distribution_center_id/inventory/:id/remove_from_available_amount
  def remove_from_available_amount
	api_model                = ApiModel::Inventory::RemoveFromAvailableAmount.new(@inventory_item,params[:amount])
	was_operation_successful = api_model.update_db()
	handle_response_for_update_operation(was_operation_successful,api_model)
  end
  
  # PATCH /distribution_centers/:distribution_center_id/inventory/:id/reserve
  def reserve
	api_model                = ApiModel::Inventory::Reserve.new(@inventory_item,params[:amount])
	was_operation_successful = api_model.update_db()
	handle_response_for_update_operation(was_operation_successful,api_model)
  end
  
  # PATCH /distribution_centers/:distribution_center_id/inventory/:id/move_reserved_back_to_available
  def move_reserved_back_to_available
	api_model                = ApiModel::Inventory::MoveReservedBackToAvailable.new(@inventory_item,params[:amount])
	was_operation_successful = api_model.update_db()
	handle_response_for_update_operation(was_operation_successful,api_model)
  end
  
  # PATCH /distribution_centers/:distribution_center_id/inventory/:id/remove_reserved
  def remove_reserved
	api_model                = ApiModel::Inventory::RemoveReserved.new(@inventory_item,params[:amount])
	was_operation_successful = api_model.update_db()
	handle_response_for_update_operation(was_operation_successful,api_model)
  end

  private

	def handle_response_for_query_operation
	end
  
	def handle_response_for_update_operation(was_operation_successful,api_model)
		if was_operation_successful
			return render status: 200, json: { message:  api_model.update_db_success_msg }.to_json
		elsif api_model.errors.count  > 0 # If validation error.
			return render status: 422, json: { message: api_model.errors }.to_json
		else # If Database-elated error. 
			return render status: 409, json: { message: api_model.update_db_error_msg }.to_json
		end
	end
  
    # update_counters() doesn't actually check that an inventory item exists so we do it here. 
    def confirm_exists_in_distribution_center_and_set_inventory_item
        id                     = params[:id]
        distribution_center_id = params[:distribution_center_id]
        @inventory_item = Inventory.where({id: id,distribution_center_id: distribution_center_id}).first
        if @inventory_item.nil?
            return render status: 404, json: { message: "Inventory item with id '#{id}' from distribution center '#{distribution_center_id}' not found." }.to_json
        end
    end

    def set_all_inventory_in_distribution_center
        distribution_center_id = params[:distribution_center_id]
        if not DistributionCenter.exists?(distribution_center_id)
            return render status: 404, json: { message: "Distribution center with id of '#{distribution_center_id}' not found." }.to_json
        end
        @inventory_items = Inventory.where({distribution_center_id: distribution_center_id})
    end

end

