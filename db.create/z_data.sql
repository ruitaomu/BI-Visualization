INSERT INTO user (user_type, email, password, salt, first_name, last_name, email_confirmed, status, created_on, updated_on) VALUES
(1, 'admin@example.com', MD5('p4ssword|salt'), 'salt', 'Admin', 'User', 1, 'A', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(2, 'employee@example.com', MD5('p4ssword|salt'), 'salt', 'Employee', 'User', 1, 'A', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

