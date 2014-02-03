/* Show a list of all rooms which pertain to a property */
SELECT addresses.addr_line_1, addresses.addr_postcode, 
       cities.city_name, room_price, room_details
FROM rooms
JOIN properties ON properties.property_id = rooms.property_id
JOIN addresses ON addresses.addr_id = properties.prop_addr
JOIN cities ON addresses.addr_id = cities.city_id
WHERE rooms.property_id = 3;


user tracks a property (track this)
user lives at a property (track this)
user pays for a property (track this)