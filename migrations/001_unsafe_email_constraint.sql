-- Deliberately unsafe migration for Schema Airlock rehearsal.
-- The INSERT fails because existing cus_1002 has a NULL email.
BEGIN;
CREATE TABLE customers_new (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  joined_on TEXT NOT NULL
);
INSERT INTO customers_new (id, name, email, joined_on)
  SELECT id, name, email, joined_on FROM customers;
DROP TABLE customers;
ALTER TABLE customers_new RENAME TO customers;
COMMIT;
