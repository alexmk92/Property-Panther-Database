/*******************************************
*  	     Property Panther Database Code	   *
*	     Author:  PRCSE		    		   *
*        Date Created: 24/01/2014		   *
*        Version: 1.0 					   *
********************************************/


/*******************************************
*               GALLERY TABLE              *
********************************************/
CREATE TABLE gallery 
(
	img_id 				NUMBER(11)
						CONSTRAINT gallery_img_id_pk
							PRIMARY KEY
						CONSTRAINT gallery_img_id_nn
							NOT NULL,
	property_id 		NUMBER(11)
						CONSTRAINT gallery_property_id_fk
							REFERENCES properties(property_id)
						CONSTRAINT gallery_property_id_nn
							NOT NULL,
	room_id 			NUMBER(11)
						CONSTRAINT gallery_room_id_fk
							REFERENCES rooms(room_id)
						CONSTRAINT gallery_room_id_nn
							NOT NULL,
	img_type			VARCHAR2(10) DEFAULT 'GALLERY'
						CONSTRAINT gallery_img_type_chk
							CHECK(REGEXP_LIKE(img_type,
									'\b(GALLERY|COVER)\b'))
						CONSTRAINT gallery_img_type_nn
							NOT NULL,
	img_file			BLOB
);

CREATE SEQUENCE seq_img_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_gallery
BEFORE INSERT OR UPDATE ON gallery FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.img_id IS NULL THEN
			SELECT seq_img_id.nextval
			INTO :NEW.img_id
			FROM sys.dual;
		END IF;
	END IF;
END;

/*******************************************
*               ROOMS TABLE                *
********************************************/
CREATE TABLE rooms
(
	room_id 			NUMBER(11)
						CONSTRAINT rooms_room_id_pk
							PRIMARY KEY
						CONSTRAINT rooms_room_id_nn
							NOT NULL,
	property_id     	NUMBER(11)
						CONSTRAINT rooms_property_id_fk
							REFERENCES properties(property_id)
						CONSTRAINT rooms_property_id_nn
							NOT NULL,
	room_price			NUMBER(*, 2) DEFAULT '0.00'
						CONSTRAINT rooms_room_price_chk
							CHECK(REGEXP_LIKE(room_price,
								'[0-9]+\.[0-9]{2}'))
						CONSTRAINT rooms_room_price_nn
							NOT NULL,
	room_details		VARCHAR2(1000)
						CONSTRAINT rooms_room_details_nn
							NOT NULL
);

CREATE SEQUENCE seq_room_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_rooms
BEFORE INSERT OR UPDATE ON rooms FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.room_id IS NULL THEN
			SELECT seq_room_id.nextval
			INTO :NEW.room_id
			FROM sys.dual;
		END IF;
	END IF;
END;

/*******************************************
*             PROPERTIES TABLE             *
********************************************/
CREATE TABLE properties
(
	property_id     	NUMBER(11)
						CONSTRAINT properties_prop_id_pk
							PRIMARY KEY
						CONSTRAINT properties_prop_id_nn
							NOT NULL,
	prop_addr			NUMBER(11)
						CONSTRAINT properties_prop_addr_fk
							REFERENCES addresses(addr_id)
						CONSTRAINT properties_prop_addr_nn
							NOT NULL,
	prop_details		VARCHAR2(1000)
						CONSTRAINT properties_prop_details_nn
							NOT NULL,
	prop_rooms			NUMBER(11)
						CONSTRAINT properties_prop_rooms_fk
							REFERENCES rooms(room_id),
	prop_cover_img		NUMBER(11)
						CONSTRAINT properties_prop_cover_fk
							REFERENCES gallery(property_id)
);

CREATE SEQUENCE seq_property_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_properties
BEFORE INSERT OR UPDATE ON properties FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.property_id IS NULL THEN
			SELECT seq_property_id.nextval
			INTO :NEW.property_id
			FROM sys.dual;
		END IF;
	END IF;
END;

/*******************************************
*              PAYMENTS TABLE              *
********************************************/
CREATE TABLE payments
(
	payment_id			NUMBER(11)
						CONSTRAINT payments_payment_id_pk
							PRIMARY KEY
						CONSTRAINT payments_payment_id_nn
							NOT NULL,
	user_id				NUMBER(11)
						CONSTRAINT payments_user_id_fk
							REFERENCES users(user_id)
						CONSTRAINT payments_user_id_nn
							NOT NULL,
	payment_date    	DATE
						CONSTRAINT payments_payment_date_nn
							NOT NULL,
	payment_due 		DATE
						CONSTRAINT payments_payment_due_nn
							NOT NULL,
	payment_status		VARCHAR(50) DEFAULT 'PENDING'
						CONSTRAINT payments_pay_status_chk
							CHECK( UPPER(payment_status) = 'PENDING' OR 
								   UPPER(payment_status) = 'OVERDUE' OR 
								   UPPER(payment_status) = 'PAID'
								 )
						CONSTRAINT payments_pay_status_nn
							NOT NULL,
	property_id     	NUMBER(11) 
						CONSTRAINT payments_property_id_fk
							REFERENCES properties(property_id)
						CONSTRAINT payments_property_id_nn
							NOT NULL
);

CREATE SEQUENCE seq_payment_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_payments
BEFORE INSERT OR UPDATE ON payments FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.payment_id IS NULL THEN
			SELECT seq_payment_id.nextval
			INTO :NEW.payment_id
			FROM sys.dual;
		END IF;
	END IF;
END;

/*******************************************
*                USERS TABLE               *
********************************************/
CREATE TABLE users
(
	user_id 			NUMBER(11)
						CONSTRAINT users_user_id_pk
							PRIMARY KEY
						CONSTRAINT users_user_id_nn
							NOT NULL,
	user_email			VARCHAR2(150)
						CONSTRAINT users_user_email_chk
							CHECK(REGEXP_LIKE(user_email,
								'[A-Za-z0-9_\-.+-]+@[A-Za-z0-9].+'))
						CONSTRAINT users_user_email_nn
							NOT NULL,   
	user_pass			VARCHAR2(150)
						CONSTRAINT users_user_pass_chk
							CHECK(REGEXP_LIKE(user_pass,
								/* Check for a password 6-40 chars with any char or symbol */
								'((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%]).{6,40})'))
						CONSTRAINT users_user_pass_nn
							NOT NULL,
	user_addr			NUMBER(11)
						CONSTRAINT users_user_addr_fk
							REFERENCES addresses(addr_id)
	user_permissions 	NUMBER(11) DEFAULT '0'
						CONSTRAINT users_user_permission_nn
							NOT NULL,
	user_property			NUMBER(11)
						CONSTRAINT users_user_house_fk
							REFERENCES properties(property_id)
)

CREATE SEQUENCE seq_user_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_users
BEFORE INSERT OR UPDATE ON users FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.user_id IS NULL THEN
			SELECT seq_user_id.nextval
			INTO :NEW.user_id
			FROM sys.dual;
		END IF;
	END IF;
END;

/*******************************************
*              ADDRESSES TABLE             *
********************************************/
CREATE TABLE addresses 
(
	addr_id				NUMBER(11)
						CONSTRAINT addresses_addr_id_pk
							PRIMARY KEY
						CONSTRAINT addresses_addr_id_nn
							NOT NULL,
	addr_line_1			VARCHAR2(100)
						CONSTRAINT addresses_addr_ln_1_chk
							CHECK(REGEXP_LIKE(addr_line_1,
								'[A-Za-z0-9]'))
						CONSTRAINT addresses_addr_ln_1_nn
							NOT NULL,
	addr_line_2			VARCHAR2(100)
						CONSTRAINT addresses_addr_ln_2_chk
							CHECK(REGEXP_LIKE(addr_line_2,
								'[A-Za-z0-9]')),
	addr_postcode		VARCHAR2(12)
						CONSTRAINT addresses_addr_post_chk
							CHECK(REGEXP_LIKE(addr_postcode,
								'(([A-PR-UW-Z]{1}[A-IK-Y]?)([0-9]?[A-HJKS-UW]?[ABEHMNPRVWXY]?|[0-9]?[0-9]?))\s?([0-9]{1}[ABD-HJLNP-UW-Z]{2})'
							))
						CONSTRAINT addresses_addr_post_nn
							NOT NULL,
	addr_city			NUMBER(11)
						CONSTRAINT addresses_addr_city_fk
							REFERENCES cities(city_id)
						CONSTRAINT addresses_addr_city_nn
							NOT NULL
)

CREATE SEQUENCE seq_addr_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_addresses
BEFORE INSERT OR UPDATE ON addresses FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.addr_id IS NULL THEN
			SELECT seq_addr_id.nextval
			INTO :NEW.addr_id
			FROM sys.dual;
		END IF;
	END IF;
END;

/*******************************************
*                CITIES TABLE              *
********************************************/
CREATE TABLE cities 
(
	city_id				NUMBER(11)
						CONSTRAINT cities_city_id_pk
							PRIMARY KEY
						CONSTRAINT cities_city_id_nn
							NOT NULL,
	city_name			VARCHAR2(100)
						CONSTRAINT cities_city_name_chk
							CHECK(REGEXP_LIKE(city_name,
								'[A-Za-z]{1,100}'))
						CONSTRAINT cities_city_name_nn
							NOT NULL
)

CREATE SEQUENCE seq_city_id START WITH 1 INCREMENT BY 1

CREATE OR REPLACE TRIGGER trg_cities
BEFORE INSERT OR UPDATE ON cities FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.city_id IS NULL THEN
			SELECT seq_city_id.nextval
			INTO :NEW.city_id
			FROM sys.dual;
		END IF;
	END IF;
END;



