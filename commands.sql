-- Show a list of all rooms which pertain to a property 
SELECT addresses.addr_line_1 AS "Address Line 1",
       addresses.addr_postcode AS "Postcode",
       cities.city_name AS "City", room_price AS "Room Price", room_details AS "Details"
FROM rooms
JOIN properties ON properties.property_id = rooms.property_id
JOIN addresses ON properties.prop_addr = addresses.addr_id 
JOIN cities ON cities.city_id = addresses.addr_id 
WHERE properties.tracking_id = 'F2L6IJSG7U0UVI4H';

-- Show a list of all available properties in an area
SELECT addresses.addr_line_1 AS "Address Line 1", 
       addresses.addr_line_2 AS "Address Line 2",
       addresses.addr_postcode AS "Postcode", 
       cities.city_name AS "City Name",
       properties.prop_price AS "Price", 
FROM addresses
JOIN properties ON addresses.addr_id = properties.prop_addr
JOIN cities ON cities.city_id = addresses.addr_city
WHERE cities.city_name = 'Plymouth';

-- Search for a 2 bed property


-- Return all payments by a user
SELECT 

-- Search by cost (range)
SELECT addresses.addr_line_1 AS "Address Line 1", addresses.addr_line_2 AS "Address Line 2", 
       addresses.addr_postcode AS "Postcode", cities.city_name AS "City", 
       properties.prop_price AS "Price", properties.prop_status AS "Status"
FROM properties
JOIN addresses ON addresses.addr_id = properties.prop_addr
JOIN cities ON cities.city_id = addresses.addr_city
WHERE properties.prop_price BETWEEN 200 AND 800;


-- User login query

-- Insert a new user

-- Update a users password

-- Insert a new property

-- Insert a new room





TO DO : Refine address table to add a District column
		Create hash map to hold 
		Create common SQL query functions
		Create a messages table that belongs to user (inbox table)



[06/02/2014 12:41:34] Jamie Shepherd: Location search
Property search
Room count search
Search by cost (between)
New user insert
User login (user+pass the same, 1 row)
Insert a new property
Return all payments by a user