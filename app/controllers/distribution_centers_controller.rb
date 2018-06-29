class DistributionCentersController < ApplicationController
  before_action :set_distribution_center, only: [:show, :show_inventory]

  # GET /distribution_centers
  def index
    @distribution_centers = DistributionCenter.all
    json_response(@distribution_centers)
  end

  # GET /distribution_centers/:id
  def show
    json_response(@distribution_center)
  end

  # GET /distribution_centers/:id/inventory
  def show_inventory
    json_response(@distribution_center.inventory)
  end

  private

  def set_distribution_center
    @distribution_center = DistributionCenter.find(params[:id])
  end

end
