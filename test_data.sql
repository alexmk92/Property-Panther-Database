/*******************************************
*              TITLES TEST DATA            *
********************************************/
INSERT INTO titles(title_name) VALUES('Miss');
INSERT INTO titles(title_name) VALUES('Mrs');
INSERT INTO titles(title_name) VALUES('Ms');
INSERT INTO titles(title_name) VALUES('Sir');
INSERT INTO titles(title_name) VALUES('Mr');

/*******************************************
*              CITIES TEST DATA            *
********************************************/
INSERT INTO cities VALUES('', 'Buckingham');
INSERT INTO cities VALUES('', 'Mutley Plain');
INSERT INTO cities VALUES('', 'Milton Keynes');
INSERT INTO cities VALUES('', 'Newquay');
INSERT INTO cities VALUES('', 'Plymouth');
INSERT INTO cities VALUES('', 'Cornwall');

/*******************************************
*           ADDRESSES TEST DATA            *
********************************************/
INSERT INTO addresses VALUES('', '1 Cedar Way', '', 'NN84SL', 2);
INSERT INTO addresses VALUES('', 'Flat 5', '8 Laira Place', 'PL4 9JS', 5);
INSERT INTO addresses VALUES('', '6 Morland Drive', '', 'MK8 0 PB', 3);
INSERT INTO addresses VALUES('', '15 Radnor Street', '', 'PL 14 8DR', 3);
INSERT INTO addresses VALUES('', 'Flat 22', '64 Newland Rd.', 'CD29JD', 5);

/*******************************************
*           PROPERTIES TEST DATA           *
********************************************/
INSERT INTO properties VALUES('', '', 5, 'A large 4 bedroom house near the city center', 4, '720.00');
INSERT INTO properties VALUES('', '', 6, 'A small 1 bedroom house next to the University', 1, '350.00');
INSERT INTO properties VALUES('', '', 7, 'Shared living space with 2 bedrooms', 2, '500.00');
INSERT INTO properties VALUES('', '', 8, 'Large 2 bedroom apartment wit open fire and balcony', 2, '600.00');

/*******************************************
*              ROOMS TEST DATA             *
********************************************/
INSERT INTO rooms VALUES('', '', 1, '200.00', 'Small double bedded room with onboard balcony.');
INSERT INTO rooms VALUES('', '', 1, '400.00', 'Large master bedroom with en-suite bathroom and balcony.');
INSERT INTO rooms VALUES('', '', 1, '350.00', 'Medium sized bedroom with en-suite shower and double bed.');
INSERT INTO rooms VALUES('', '', 1, '200.00', 'Small double bedded room with roof spotlights.');
INSERT INTO rooms VALUES('', '', 3, '500.00', 'Large double bedded room with roof spotlights, view of sea and en-suite bathroom.');
INSERT INTO rooms VALUES('', '', 4, '300.00', 'Medium sized room, en-suite bathroom, on board balcony.');
INSERT INTO rooms VALUES('', '', 4, '300.00', 'Medium sized room, en-suite bathroom.');
INSERT INTO rooms VALUES('', '', 5, '100.00', 'Small bedroom, spotlights and double bed.');
INSERT INTO rooms VALUES('', '', 5, '80.00',  'Single bed and disco ball, red lights and curtains.');

/*******************************************
*              GALLERY TEST DATA           *
********************************************/
INSERT INTO gallery VALUES('', 1, 1, 'GALLERY', '../rooms/addr_1_room_1.jpg');
INSERT INTO gallery VALUES('', 1, 2, 'GALLERY', '../rooms/addr_1_room_2.jpg');
INSERT INTO gallery VALUES('', 1, 3, 'GALLERY', '../rooms/addr_1_room_3.jpg');
INSERT INTO gallery VALUES('', 1, 4, 'GALLERY', '../rooms/addr_1_room_4.jpg');
INSERT INTO gallery VALUES('', 2, 5, 'GALLERY', '../rooms/addr_2_room_1.jpg');
INSERT INTO gallery VALUES('', 3, 6, 'GALLERY', '../rooms/addr_3_room_1.jpg');
INSERT INTO gallery VALUES('', 3, 7, 'GALLERY', '../rooms/addr_3_room_2.jpg');
INSERT INTO gallery VALUES('', 4, 8, 'GALLERY', '../rooms/addr_4_room_1.jpg');
INSERT INTO gallery VALUES('', 4, 9, 'GALLERY', '../rooms/addr_4_room_2.jpg');
INSERT INTO gallery VALUES('', 1, '', 'COVER', '../properties/property_1_banner_1.jpg');
INSERT INTO gallery VALUES('', 2, '', 'COVER', '../properties/property_2_banner_1.jpg');
INSERT INTO gallery VALUES('', 3, '', 'COVER', '../properties/property_3_banner_1.jpg');
INSERT INTO gallery VALUES('', 4, '', 'COVER', '../properties/property_4_banner_1.jpg');
INSERT INTO gallery VALUES('', 4, '', 'GALLERY', '../properties/property_4_kitchen.jpg');
INSERT INTO gallery VALUES('', 4, '', 'GALLERY', '../properties/property_4_lounge.jpg');

/*******************************************
*            PAYMENTS TEST DATA            *
********************************************/
INSERT INTO payments VALUES();

/*******************************************
*            REQUESTS TEST DATA            *
********************************************/
INSERT INTO requests VALUES();

/*******************************************
*              USERS TEST DATA             *
********************************************/
INSERT INTO users VALUES();
