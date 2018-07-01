class AddNameToDistributionCenters < ActiveRecord::Migration[5.1]
  def change
    add_column :distribution_centers, :name, :string
  end
end
