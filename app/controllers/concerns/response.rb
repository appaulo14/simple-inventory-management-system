require 'csv'

module Response
  def json_response(object, status = :ok, except = [:created_at, :updated_at])
    render json: object, status: status, except: except
  end

  def csv_response(objects, status = :ok)
    csv_string = CSV.generate do |csv|
        csv << objects[0].attribute_names
        objects.all.each do |item|
           csv << item.attributes.values
        end
    end
    render plain: csv_string, status: status
  end
end

