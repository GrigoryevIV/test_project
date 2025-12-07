-- init.sql -- create users table and seed
CREATE TABLE IF NOT EXISTS users (
  id serial PRIMARY KEY,
  name varchar(100) NOT NULL,
  email varchar(150) NOT NULL UNIQUE
);

INSERT INTO users (name, email)
VALUES ('Ahmed Ali', 'ahmed@example.com'),
       ('Mona Saleh', 'mona@example.com')
ON CONFLICT DO NOTHING;