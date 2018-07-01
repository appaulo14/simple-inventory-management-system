
class AbstractInventoryApiModel
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  
  
    def persisted?
      return false
    end
end
