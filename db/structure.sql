CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "products" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "description" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "distribution_centers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "location" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "name" varchar);
CREATE TABLE inventories(
                  id INTEGER PRIMARY KEY AUTOINCREMENT, 
                  available_amount UNSIGNED BIG INT NOT NULL CONSTRAINT available_amount_cannot_go_below_zero CHECK(available_amount >=0), 
                  reserved_amount UNSIGNED BIG INT NOT NULL CONSTRAINT reserved_amount_cannot_go_below_zero CHECK(reserved_amount >= 0),
                  product_id INTEGER NOT NULL UNIQUE,
                  distribution_center_id INTEGER NOT NULL, 
                  FOREIGN KEY(product_id) REFERENCES products(id), 
                  FOREIGN KEY(distribution_center_id) REFERENCES distribution_centers(id));
INSERT INTO "schema_migrations" (version) VALUES
('20180624085219'),
('20180624085350'),
('20180624090312'),
('20180624101331');


