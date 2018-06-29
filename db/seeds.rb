# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
DistributionCenter.create([{name: "Singapore Distribution Center", location: "Singapore"},{name: "Thailand Distribution Center",location: "Thailand"}])
Product.create(name: "Product 1", description: "Insert description of product 1 here.")
Product.create(name: "Product 2", description: "Insert description of product 2 here.")
Product.create(name: "Product 3", description: "Insert description of product 3 here.")
Inventory.create(distribution_center_id: 1, product_id: 1, available_amount: 0, reserved_amount: 0)
Inventory.create(distribution_center_id: 1, product_id: 2, available_amount: 0, reserved_amount: 0)
Inventory.create(distribution_center_id: 1, product_id: 3, available_amount: 0, reserved_amount: 0)
Inventory.create(distribution_center_id: 2, product_id: 1, available_amount: 0, reserved_amount: 0)
Inventory.create(distribution_center_id: 2, product_id: 2, available_amount: 0, reserved_amount: 0)
Inventory.create(distribution_center_id: 2, product_id: 3, available_amount: 0, reserved_amount: 0)
