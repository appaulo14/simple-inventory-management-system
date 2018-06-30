class CreateInventories < ActiveRecord::Migration[5.1]
    def up
        command = """CREATE TABLE inventories(
                  id INTEGER PRIMARY KEY AUTOINCREMENT, 
                  available_amount UNSIGNED BIG INT NOT NULL CONSTRAINT available_amount_cannot_go_below_zero CHECK(available_amount >=0), 
                  reserved_amount UNSIGNED BIG INT NOT NULL CONSTRAINT reserved_amount_cannot_go_below_zero CHECK(reserved_amount >= 0),
                  product_id INTEGER NOT NULL UNIQUE,
                  distribution_center_id INTEGER NOT NULL, 
                  FOREIGN KEY(product_id) REFERENCES products(id), 
                  FOREIGN KEY(distribution_center_id) REFERENCES distribution_centers(id)); """
    
        execute(command)
    end

end
