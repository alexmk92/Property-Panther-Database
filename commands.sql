/* Show a list of all rooms which pertain to a property */
SELECT addresses.addr_line_1 AS "Address Line 1",
       addresses.addr_postcode AS "Postcode",
       cities.city_name AS "City", room_price AS "Room Price", room_details AS "Details"
FROM rooms
JOIN properties ON properties.property_id = rooms.property_id
JOIN addresses ON addresses.addr_id = properties.prop_addr
JOIN cities ON addresses.addr_id = cities.city_id
WHERE properties.tracking_id = 'F2L6IJSG7U0UVI4H';


user tracks a property (track this)
user lives at a property (track this)
user pays for a property (track this)