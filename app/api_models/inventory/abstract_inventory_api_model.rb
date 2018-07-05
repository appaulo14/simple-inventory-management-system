
###
# Abstract class for all inventory-related logic classes. These generally 
# follow a pattern of encapsulating business logic and acting as an 
# intermediary between the controller class and model class(es). This 
# allows for easier validation, maintenance, and testability.
# 
# These classes are design to properly handle concurrent updates to the 
# the same inventory item in a way that no updates are lost. 
class AbstractInventoryApiModel
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  
    # Since this isn't an actual model, it doesn't get saved to the database.
    def persisted?
      return false
    end
end
