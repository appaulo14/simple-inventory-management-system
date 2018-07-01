# README

# Overview
Simple Inventory Management System provides a way to simply manage inventory levels in multiple distribution centers. 

# REST Resources
There are three main resources:
* __Products:__ A unique type of an item, such as a Toyota Corolla or iPhone 6s gold model A1634. 
* __Distribution Centers:__ Physical places that stores inventory.
* __Inventory:__ An inventory item represents a specific product in a specific distribution center. For example, an inventory item might contain the information on how many Toyota Corollas are available and reserved at the Japan distribution center.  

# Available REST Routes
|Verb  | URI Pattern | Description |
|------|-------------|-------------|
|GET   | /products   | List all products. |       
|GET   | /products/:id | Get the info for the product with the specified id. | 
|GET   | /distribution_centers  | List all distribution centers |    
|GET   | /distribution_centers/:id | Get the info for the distribution center with the specified id. | 
|GET   | /distribution_centers/:distribution_center_id/inventory/report | Report displaying the current stock on hand and current pending shipped inventory in json format. (This is a shortcut to report_as_json URI below.) |
|GET   | /distribution_centers/:distribution_center_id/inventory/report_as_json | Report displaying the current stock on hand and current pending shipped inventory in json format. |  
|GET   | /distribution_centers/:distribution_center_id/inventory/report_as_csv | Report displaying the current stock on hand and current pending shipped inventory in csv format. |  
|GET   | /distribution_centers/:distribution_center_id/inventory | List all inventory  |                                    
|GET   | /distribution_centers/:distribution_center_id/inventory/:id | Get info for inventory item specified by id. |               
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/add_to_available_amount | Add to the current stock on-hand for the specified inventory item. |          
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/remove_from_available_amount | Remove from the current stock on-hand for the specified inventory item. |     
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/reserve | Reserve some or all of the available on-hand stock for the specified inventory item. |   
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/move_reserved_back_to_available | Move reserved stock back to available/on-hand stock for the specified inventory item. | 
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/remove_reserved | Remove reserved stock (such as due to it being shipped out) for the specified inventory item. | 
                                                              

# How to Install Ruby on Rails (If needed)
[Follow the guide here to install Ruby on Rails for your chosen OS](http://installrails.com/)

# Simple Deployment in a development environment
1. Clone repository.
```
git clone https://github.com/appaulo14/simple-inventory-management-system.git
```
2. cd to the newly cloned repository.
```
cd simple-inventory-management-system
```
3. Install the gems for the application.
```
bundle install
```
4. Create the database. 
```
rails db:migrate
rails db:migrate RAILS_ENV=test
```
5. Generate the seed data. 
```
rails db:seed 
```
6. Confirm tests pass.
```
rails spec
```
7. Start the server in development mode. 
```
rails s 
```

# Production Deployment
For production deployment, Ruby on Rails is commonly deployed to a cloud provider such as Amazon Web Services (AWS) or Microsoft Azure for improved scalability, availability, cost, deployment time, and many other benefits.

Below are two guides for deploy on AWS and Azure respectively:
* [Creating and Deploying Ruby Applications on AWS Elastic Beanstalk](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_Ruby.html)
* [Build a Ruby and Postgres web app in Azure App Service on Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-ruby-postgres-app)

### Testing Performance in a Production-Simulation Environment
One tool that can be used to measure the performance and do load testing of the deployed web application is [httperf](https://github.com/httperf/httperf). This should be run on a deployment as similar as possible to the production environment but not on the production environment itself. See [Performance Testing With httperf](http://www.mervine.net/performance-testing-with-httperf) for more best practices and tips. 

### Additional AWS Best Practices 
* [AWS Web Hosting Best Practices](https://d1.awsstatic.com/whitepapers/aws-web-hosting-best-practices.pdf) 
* [AWS Cloud best practices](https://d1.awsstatic.com/whitepapers/AWS_Cloud_Best_Practices.pdf)
* [AWS guidelines for both horizontally and vertically scaling relational database](https://aws.amazon.com/blogs/database/scaling-your-amazon-rds-instance-vertically-and-horizontally/)
* [AWS Cloud Architecture Guidelines in 5 Pillars (Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization)](https://d1.awsstatic.com/whitepapers/architecture/AWS_Well-Architected_Framework.pdf)

### Additional Azure Best Practices
* [Azure reference architecture for scale-able web applications](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/app-service-web-app/scalable-web-app)
* [Scaling out with Azure SQL database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-scale-introduction)


# Further Possible Enhancements
* Switch from SQLite to a more production-ready data such as PostgreSQL or MySQL and tune settings/indexes appropriately. 
* Batch update to reduce the number of requests against the server. 
* More race-condition/load/stress testing.
* Add automated tests for classes under app/api_models. 
* Authentication/Authentication
* Allow client to filter and pagination results
* Allow inventory to be referenced by distribution-center-specific ids. 
* Addition/update/deletion of products/distribution centers/inventory items as needed. 
