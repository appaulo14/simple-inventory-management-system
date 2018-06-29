class CreateInventories < ActiveRecord::Migration[5.1]
#  def change
#    create_table :inventories do |t|
#      t.integer :level_available
#      t.integer :level_reserved
#      t.references :product, foreign_key: true
#      t.references :distribution_center, foreign_key: true#

#      t.timestamps
#    end
#  end
    def up
        command = """CREATE TABLE inventories(
                  id INTEGER PRIMARY KEY AUTOINCREMENT, 
                  available_amount UNSIGNED BIG INT NOT NULL CHECK(available_amount >=0), 
                  reserved_amount UNSIGNED BIG INT NOT NULL CHECK(reserved_amount >= 0),
                  product_id INTEGER NOT NULL UNIQUE,
                  distribution_center_id INTEGER NOT NULL, 
                  FOREIGN KEY(product_id) REFERENCES products(id), 
                  FOREIGN KEY(distribution_center_id) REFERENCES distribution_centers(id)); """
    
        execute(command)
    end

end
