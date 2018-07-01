# README

# Overview
Simple Inventory Management System provides a way to simply manage inventory levels in multiple distribution centers. 

# REST Resources
There are three main resources:
* __Products:__ A unique type of an item, such as a Toyota Corolla or iPhone 6s gold model A1634. 
* __Distribution Centers:__ Physical places that stores inventory.
* __Inventory:__ A inventory item represents a specific product in a specific distribution center. For example, an inventory item might contain the information on how many Toyota Corollas are available and reserved at the Japan distribution center.  

# Available REST Routes
|Verb  | URI Pattern | Description |
|------|-------------|-------------|
|GET   | /products   | List all products. |       
|GET   | /products/:id | Get the info for the product with the specified id. | 
|GET   | /distribution_centers  | List all distribution centers |    
|GET   | /distribution_centers/:id | Get the info for the distribution center with the specified id. | 
|GET   | /distribution_centers/:distribution_center_id/inventory/report | Report displaying the current stock on hand and current pend shipped inventory in json format (shortcut to report_as_json URI below). |
|GET   | /distribution_centers/:distribution_center_id/inventory/report_as_json | Report displaying the current stock on hand and current pend shipped inventory in json format. |  
|GET   | /distribution_centers/:distribution_center_id/inventory/report_as_csv | Report displaying the current stock on hand and current pend shipped inventory in csv format. |  
|GET   | /distribution_centers/:distribution_center_id/inventory | List all inventory  |                                    
|GET   | /distribution_centers/:distribution_center_id/inventory/:id | Get info for inventory item specified by id. |               
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/add_to_available_amount | Add to the current stock on-hand for the specified inventory item. |          
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/remove_from_available_amount | Remove from the current stock on-hand for the specified inventory item. |     
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/reserve | Reserve some or all of the on-hand stock for the specified inventory item. |   
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/move_reserved_back_to_available | Move reserved stock back to available/on-hand stock for the specified inventory item. | 
|PATCH | /distribution_centers/:distribution_center_id/inventory/:id/remove_reserved | Remove reserved stock (such as due to it being shipped out) for the specified inventory item. | 
                                                              

# How to Install & Run This Web Application
### Installation of Ruby on Rails
[Follow the guide here to install Ruby on Rails for your chosen OS](http://installrails.com/)

# How to run in a simple development environment
1. Extract project to a directory.
1. cd to the directory.
1. 
```
bundle install
```
```
rails db:migrate
```
```
rails db:seed 
```

```
rails -s 
```

# Production Deployment
For production deployment, Ruby on Rails is commonly deployed to a cloud provider such as Amazon Web Services (AWS) or Microsoft Azure for improved scalability, availability, cost, deployment time, and many other benefits.

Below are two guides for deploy on AWS and Azure respectively:
* [Creating and Deploying Ruby Applications on AWS Elastic Beanstalk](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_Ruby.html)
* [Build a Ruby and Postgres web app in Azure App Service on Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-ruby-postgres-app)

# Additional Info On Production Deployment in the Cloud
These days there are many reference architectures, design patterns, and best practices for web application cloud deployments.

#### Example Reference Architecture
![](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/app-service-web-app/images/scalable-web-app.png)

### AWS Best Practices 
* [AWS Web Hosting Best Practices](https://d1.awsstatic.com/whitepapers/aws-web-hosting-best-practices.pdf) 
* [AWS Cloud best practices](https://d1.awsstatic.com/whitepapers/AWS_Cloud_Best_Practices.pdf)
* [AWS guidelines for both horizontally and vertically scaling relational database](https://aws.amazon.com/blogs/database/scaling-your-amazon-rds-instance-vertically-and-horizontally/)
* [AWS Cloud Architecture Guidelines in 5 Pillars (Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization)](https://d1.awsstatic.com/whitepapers/architecture/AWS_Well-Architected_Framework.pdf)

### Azure Best Practices
* [Azure reference architecture for scale-able web applications](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/app-service-web-app/scalable-web-app)
* [Scaling out with Azure SQL database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-scale-introduction)

# Testing Performance in a Deployed, Production-Simulation Environment
One tool that can be used to measure the performance of the deployed web application is [httperf](https://github.com/httperf/httperf). This should be run on a deployment as similar as possible to the production environment but not on the production environment itself of course. See [Performance Testing With httperf](http://www.mervine.net/performance-testing-with-httperf) for more best practices and tips. 

# Further Possible Enhancements
* Switch from SQLite to a production-ready data such as PostgreSQL or MySQL. 
* Addition/update/deletion of products/distribution centers/and inventory items as needed. 
* Improve scaleability to based on requirements.
  * For example: [Azure reference architecture for scaleable web applications](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/app-service-web-app/scalable-web-app)
  * It may be worth having auto-scaling for the web servers and databases, although different methods are needed between the two. 
* Batch update
* Authentication/Authentication
* Allow client to filter and pagination results
* Allow inventory to be referenced by distribution-center-specific ids. 
* Load testing.
  * http://httpd.apache.org/docs/2.2/programs/ab.html
* More concurrency/atomic update testing.
* Cache optimization
* Add automated tests for ApiModel classes. 
