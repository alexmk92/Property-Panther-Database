/*******************************************
*  	     Property Panther Database Code	   
*	     Author:  PRCSE		    		   
*        Date Created: 24/01/2014		   
*        Version: 2.1					   
********************************************/


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
);

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

	:NEW.city_name := UPPER(SUBSTR(:NEW.city_name,1,1))||SUBSTR(:NEW.city_name,2);

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
	addr_district		VARCHAR2(50)
						CONSTRAINT addresses_district_nn		
							NOT NULL,
	addr_city			NUMBER(11)
						CONSTRAINT addresses_addr_city_fk
							REFERENCES cities(city_id)
						CONSTRAINT addresses_addr_city_nn
							NOT NULL
);

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

	:NEW.addr_line_1   :=  TRIM(UPPER(:NEW.addr_line_1));
	:NEW.addr_line_2   :=  TRIM(UPPER(:NEW.addr_line_2));
	:NEW.addr_postcode :=  replace(:NEW.addr_postcode, ' ', '');
	:NEW.addr_postcode :=  TRIM(UPPER(:NEW.addr_postcode));
	:NEW.addr_district :=  TRIM(UPPER(:NEW.addr_district));
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
	tracking_id  		VARCHAR2(18)
						CONSTRAINT properties_tracking_id_nn
							NOT NULL,
	prop_addr			NUMBER(11)
						CONSTRAINT properties_prop_addr_fk
							REFERENCES addresses(addr_id)
						CONSTRAINT properties_prop_addr_nn
							NOT NULL,
	prop_details		VARCHAR2(1500)
						CONSTRAINT properties_prop_details_nn
							NOT NULL,
	prop_status			VARCHAR2(20) DEFAULT 'VACANT'
						CONSTRAINT properties_prop_status_chk
							CHECK( UPPER(prop_status) = 'VACANT' OR 
								   UPPER(prop_status) = 'FULL' 
								 )
						CONSTRAINT prop_status_nn
							NOT NULL,
	prop_price			VARCHAR2(12) DEFAULT '0.00'
						CONSTRAINT properties_prop_price_chk
							CHECK(REGEXP_LIKE(prop_price,
								'-?\+?([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'))
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
		IF :NEW.tracking_id IS NULL THEN
		SELECT DBMS_RANDOM.STRING ('X', 16)
		INTO :NEW.tracking_id
		FROM sys.dual;
		END IF;
	END IF;

	-- Check whether the property has any available rooms
	IF prop_vacancy_query(:NEW.property_id) = 0 THEN
	   :NEW.prop_status := 'FULL';
	ELSE
	   :NEW.prop_status := 'VACANT';
	END IF;

	-- Perform any formatting
	:NEW.prop_status  := TRIM(:NEW.prop_status);
	:NEW.prop_details := TRIM(:NEW.prop_details);
	:NEW.tracking_id  := TRIM(:NEW.tracking_id);
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
	tracking_id			VARCHAR2(18) 
						CONSTRAINT rooms_tracking_id_nn
							NOT NULL,
	property_id     	NUMBER(11)
						CONSTRAINT rooms_property_id_fk
							REFERENCES properties(property_id)
						CONSTRAINT rooms_property_id_nn
							NOT NULL,
	room_price			VARCHAR2(12) DEFAULT '0.00'
						CONSTRAINT rooms_room_price_chk
							CHECK(REGEXP_LIKE(room_price,
								'([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'))
						CONSTRAINT rooms_room_price_nn
							NOT NULL,
	room_status			VARCHAR2(20) DEFAULT 'VACANT'
						CONSTRAINT room_status_chk
							CHECK( UPPER(prop_status) = 'VACANT' OR 
								   UPPER(prop_status) = 'OCCUPIED' 
								 )
						CONSTRAINT room_status_nn
							NOT NULL,
	room_details		VARCHAR2(1500)
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
		IF :NEW.tracking_id IS NULL THEN
			SELECT DBMS_RANDOM.STRING ('X', 16)
			INTO :NEW.tracking_id
			FROM sys.dual;
		END IF;
	END IF;

	-- Handle the property status
	IF prop_vacancy_query(:NEW.property_id) = 0 THEN
		UPDATE properties
		SET prop_status = 'OCCUPIED'
		WHERE properties.property_id = :NEW.property_id;
	ELSE
		UPDATE properties
		SET prop_status = 'VACANT'
		WHERE properties.property_id = :NEW.property_id;
	END IF;

	-- Provide any formatting
	:NEW.room_status  := TRIM(:NEW.room_status);
	:NEW.room_details := TRIM(:NEW.room_details);
	:NEW.room_price   := TRIM(:NEW.room_price);
END;

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
	img_type			VARCHAR2(20) DEFAULT 'GALLERY'
						CONSTRAINT gallery_img_type_chk
							CHECK
							(	
								UPPER(img_type) = 'GALLERY' OR
								UPPER(img_type) = 'COVER'
							));
						CONSTRAINT gallery_img_type_nn
							NOT NULL,
	img_path			VARCHAR2(200)
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

	:NEW.img_type := TRIM(UPPER(:NEW.img_type));
	:NEW.img_path := TRIM(LOWER(:NEW.img_path));
END;

/*******************************************
*				 TITLES TABLE 		       *
********************************************/
CREATE TABLE titles
(title_id 	NUMBER (11)
	CONSTRAINT title_title_id_pk
 		PRIMARY KEY
	CONSTRAINT title_title_id_nn
		NOT NULL,
 title_name	VARCHAR2 (8)
	CONSTRAINT title_title_name_nn NOT NULL,
	CONSTRAINT title_title_name_chk_init
  		CHECK (title_name = INITCAP(title_name))
);

CREATE SEQUENCE seq_title_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_titles
    BEFORE INSERT OR UPDATE OR DELETE ON titles FOR EACH ROW
    BEGIN
    IF INSERTING THEN
        IF :NEW.title_id IS NULL THEN
            SELECT seq_title_id.nextval
            INTO :NEW.title_id
            FROM sys.dual;
        END IF;
    END IF;
   
    :NEW.title_name := INITCAP(:NEW.title_name);
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
								'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}'))
						CONSTRAINT users_user_email_nn
							NOT NULL,   
	user_pass			VARCHAR2(150)
						CONSTRAINT users_user_pass_chk
							CHECK(REGEXP_LIKE(user_pass,
								/* Check for a password 6-40 chars with any char or symbol */
								'([^\.].{6,64})'))
						CONSTRAINT users_user_pass_nn
							NOT NULL,
	pass_changed		NUMBER(1) DEFAULT 0,
	addr_line_1			VARCHAR2(100)
						CONSTRAINT users_addr_ln_1_chk
							CHECK(REGEXP_LIKE(addr_line_1,
								'[A-Za-z0-9]'))
						CONSTRAINT users_addr_ln_1_nn
							NOT NULL,
	addr_line_2			VARCHAR2(100)
						CONSTRAINT users_addr_ln_2_chk
							CHECK(REGEXP_LIKE(addr_line_2,
								'[A-Za-z0-9]')),
	addr_postcode		VARCHAR2(12)
						CONSTRAINT users_addr_post_chk
							CHECK(REGEXP_LIKE(addr_postcode,
								'(([A-PR-UW-Z]{1}[A-IK-Y]?)([0-9]?[A-HJKS-UW]?[ABEHMNPRVWXY]?|[0-9]?[0-9]?))\s?([0-9]{1}[ABD-HJLNP-UW-Z]{2})'
							))
						CONSTRAINT users_addr_post_nn
							NOT NULL,
	addr_city			NUMBER(11)
						CONSTRAINT users_addr_city_fk
							REFERENCES cities(city_id)
						CONSTRAINT users_addr_city_nn
							NOT NULL,
	user_title			NUMBER(11) 
						CONSTRAINT users_user_title_fk
							REFERENCES titles(title_id)
						CONSTRAINT users_user_title_nn
							NOT NULL,
	user_forename		VARCHAR2(50) DEFAULT 'NULL'
						CONSTRAINT users_user_forename_chk
							CHECK(REGEXP_LIKE(user_forename,
								'[A-Za-z-]{1,50}')),
	user_surname		VARCHAR2(50) DEFAULT 'NULL'
						CONSTRAINT users_user_surname_chk
							CHECK(REGEXP_LIKE(user_surname,
								'[A-Za-z-]{1,50}')),
	user_phone			VARCHAR2(14) 
						CONSTRAINT users_user_phone_chk
							CHECK(REGEXP_LIKE(user_phone,
								'[0-9]{5}\s?[0-9]{6}')),
	user_permissions 	NUMBER(11) DEFAULT 0,
						CONSTRAINT users_user_permission_chk
							CHECK(REGEXP_LIKE(user_permissions,
								'[0-5]{1}'))
						CONSTRAINT users_user_permission_nn
							NOT NULL,
	user_property		NUMBER(11) DEFAULT NULL
						CONSTRAINT users_user_house_fk
							REFERENCES properties(property_id),
	user_prop_room		NUMBER(11) DEFAULT NULL
						CONSTRAINT users_user_room_fk
							REFERENCES rooms(room_id)
);

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

	IF UPDATING THEN
		/* Flag that the user has changed their password */
		IF :NEW.user_pass != :OLD.user_pass THEN
			:NEW.pass_changed := 1;
		END IF;
	END IF;

	/* Provide any formatting */
	:NEW.user_forename := TRIM(INITCAP(:NEW.user_forename));
	:NEW.user_surname  := TRIM(INITCAP(:NEW.user_surname));
	:NEW.user_email    := TRIM(LOWER(:NEW.user_email));
	:NEW.user_phone    := replace(:NEW.user_phone , ' ', '');
	:NEW.user_pass     := replace(:NEW.user_pass , ' ', '');
END;

/*******************************************
*                INBOX TABLE               *
********************************************/
CREATE TABLE inbox
(
	message_id			NUMBER(11)
						CONSTRAINT inbox_message_id_pk
							PRIMARY KEY
						CONSTRAINT inbox_message_id_nn
							NOT NULL,
	message_to 			NUMBER(11)
						CONSTRAINT inbox_message_to_fk
							REFERENCES users(user_id)
						CONSTRAINT inbox_message_to_nn
							NOT NULL,
	message_from 		NUMBER(11)
						CONSTRAINT inbox_message_from_fk
							REFERENCES users(user_id)
						CONSTRAINT inbox_message_from_nn
							NOT NULL,
	message_type		VARCHAR2(150) DEFAULT 'GENERIC MESSAGE'
						CONSTRAINT inbox_message_type_chk
							CHECK
							(	
								UPPER(message_type) = 'GENERIC MESSAGE' OR
								UPPER(message_type) = 'MAINTENANCE REQUEST' OR
								UPPER(message_type) = 'VIEWING REQUEST'
							));
						CONSTRAINT inbox_message_type_nn
							NOT NULL,
	message_body		VARCHAR2(500)
						CONSTRAINT inbox_message_body_nn
							NOT NULL,
	message_sent		DATETIME,
	message_read		NUMBER(1) DEFAULT 0
);

CREATE SEQUENCE seq_inbox_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_inbox
BEFORE INSERT OR UPDATE ON inbox FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.message_id IS NULL THEN
			SELECT seq_inbox_id.nextval
			INTO :NEW.message_id
			FROM sys.dual;
		END IF;
	END IF;

	-- Set the default value if the default fails
	IF :NEW.message_read IS NULL THEN
		:NEW.message_read := 0;
	END IF;

	/* Provide any formatting */
	:NEW.message_type := TRIM(UPPER(:NEW.message_type));
	:NEW.message_body := TRIM(:NEW.message_body);

END;


/*******************************************
*          PROPERTY TRACKING TABLE         *
********************************************/
CREATE TABLE property_tracking
(
	prop_track_id		NUMBER(11)
						CONSTRAINT prop_track_id_pk
							PRIMARY KEY
						CONSTRAINT prop_track_id_nn
							NOT NULL,
	property_id         NUMBER(11)
						CONSTRAINT prop_property_id_fk
							REFERENCES properties(property_id)
						CONSTRAINT prop_property_id_nn
							NOT NULL,
	user_id 			NUMBER(11)
						CONSTRAINT prop_track_user_id_fk
							REFERENCES users(user_id)
						CONSTRAINT prop_track_user_id_nn
							NOT NULL
);

CREATE SEQUENCE seq_property_tracking_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_prop_tracking
BEFORE INSERT OR UPDATE ON property_tracking FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.prop_track_id IS NULL THEN
			SELECT seq_property_tracking_id.nextval
			INTO :NEW.prop_track_id
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
	reference_id 		VARCHAR2(18)
						CONSTRAINT payments_ref_id_nn
							NOT NULL,
	payment_amount		VARCHAR2(15)
						CONSTRAINT payment_amount_chk
							CHECK(REGEXP_LIKE(payment_amount,
								'-?\+?([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'
							))
						CONSTRAINT payment_amount_nn
							NOT NULL,
	payment_status		VARCHAR(50) DEFAULT 'PENDING'
						CONSTRAINT payments_pay_status_chk
							CHECK( UPPER(payment_status) = 'PENDING' OR 
								   UPPER(payment_status) = 'OVERDUE' OR 
								   UPPER(payment_status) = 'PAID' OR
								   UPPER(payment_status) = 'PAID LATE'
								 )
						CONSTRAINT payments_pay_status_nn
							NOT NULL,
	payment_due 		DATE
						CONSTRAINT payments_payment_due_nn
							NOT NULL,
	payment_received    DATE DEFAULT NULL,
	property_id         VARCHAR2(18)
						CONSTRAINT payments_property_id_nn
							NOT NULL
);

CREATE SEQUENCE seq_payment_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_payments
BEFORE INSERT OR UPDATE ON payments FOR EACH ROW
	BEGIN 
	/* If the default fails then set status to RECEIVED */
	IF :NEW.payment_status IS NULL THEN
		:NEW.payment_status := 'PENDING';
	END IF;

	IF INSERTING THEN
		IF :NEW.payment_id IS NULL THEN
			SELECT seq_payment_id.nextval
			INTO :NEW.payment_id
			FROM sys.dual;
		END IF;
		IF :NEW.reference_id IS NULL THEN
			SELECT DBMS_RANDOM.STRING ('X', 16)
			INTO :NEW.reference_id
			FROM sys.dual;
		END IF;
	END IF;

	IF UPDATING THEN
		/* The user paid late, so update their status to paid late */
		IF:NEW.payment_status = 'PAID' THEN
			IF:NEW.payment_received > :OLD.payment_due OR :OLD.payment_received > :OLD.payment_due THEN
				:NEW.payment_status := 'PAID LATE';
			END IF;
		END IF;
	END IF;

	/* Handle the users payment status automatically on insert */
	-- Has the user paid on time?
	IF:NEW.payment_received <= :NEW.payment_due THEN
		:NEW.payment_status := 'PAID';
	END IF;
	-- Has the user paid late?
	IF:NEW.payment_received > :NEW.payment_due THEN
		:NEW.payment_status := 'PAID LATE';
	END IF;
	-- Is the payment pending?
	IF SYSDATE < :NEW.payment_due AND :NEW.payment_received IS NULL THEN
		:NEW.payment_status := 'PENDING';
	END IF;
	-- Is the payment overdue?
	IF SYSDATE > :NEW.payment_due AND :NEW.payment_received IS NULL THEN
		:NEW.payment_status := 'OVERDUE';
	END IF;
	-- A future payment cannot of been received, set to current date
	IF :NEW.payment_received > SYSDATE THEN 
		:NEW.payment_received := SYSDATE;
	END IF;

	/* Perform any formatting */
	:NEW.payment_status := TRIM(UPPER(:NEW.payment_status));
	:NEW.payment_amount := TRIM(:NEW.payment_amount);
	:NEW.reference_id   := TRIM(:NEW.reference_id);
END;

/*******************************************
*        MAINTENANCE REQUEST TABLE         *
********************************************/
CREATE TABLE requests
(
	requests_id			NUMBER(11)
						CONSTRAINT requests_maintenance_id_pk
							PRIMARY KEY
						CONSTRAINT requests_maintenance_id_nn
							NOT NULL,
	tracking_id 		VARCHAR2(20)
						CONSTRAINT requests_tracking_id_nn
							NOT NULL,
	user_id 			NUMBER(11)
						CONSTRAINT requests_user_id_fk
							REFERENCES users(user_id)
						CONSTRAINT requests_user_id_nn
							NOT NULL,
	request_details		VARCHAR2(1500) 
						CONSTRAINT request_details_nn
							NOT NULL,
	request_status		VARCHAR2(30) DEFAULT 'RECEIVED'
						CONSTRAINT requests_req_status_chk
							CHECK( UPPER(request_status) = 'RECEIVED' OR
								   UPPER(request_status) = 'SEEN' OR
								   UPPER(request_status) = 'SCHEDULED' OR
								   UPPER(request_status) = 'IN PROGRESS' OR
								   UPPER(request_status) = 'COMPLETED'
							)
						CONSTRAINT requests_req_status_nn
							NOT NULL,
	request_log_date	DATETIME DEFAULT SYSDATE,
	request_fin_date	DATETIME 
);

CREATE SEQUENCE seq_requests_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_requests
BEFORE INSERT OR UPDATE ON requests FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.requests_id IS NULL THEN
			SELECT seq_requests_id.nextval
			INTO :NEW.requests_id
			FROM sys.dual;
		END IF;
		IF :NEW.tracking_id IS NULL THEN
			SELECT DBMS_RANDOM.STRING ('X', 16)
			INTO :NEW.tracking_id
			FROM sys.dual;
		END IF;

		/* If a fin date is specified then set it */
		IF :NEW.request_status = 'COMPLETED' THEN
			IF :NEW.request_fin_date >= :NEW.request_log_date THEN
				:NEW.request_fin_date := :NEW.request_fin_date;
			END IF;
		END IF;
	END IF;

	/* Update the fin date when job status is completed */
	IF UPDATING THEN 
		IF :NEW.request_status = 'COMPLETED' THEN
			IF SYSDATE >= :OLD.request_log_date THEN
				:NEW.request_fin_date := SYSDATE;
			END IF;
		END IF;
	END IF;

	/* If the default fails then set status to RECEIVED */
	IF :NEW.request_status IS NULL THEN
		:NEW.request_status := 'RECEIVED';
	END IF;

	:NEW.request_status  := TRIM(UPPER(:NEW.request_status));
	:NEW.request_details := TRIM(:NEW.request_details);
END;

/*******************************************
*                FUNCTIONS                 *
********************************************/
CREATE OR REPLACE FUNCTION get_property( this_user NUMBER ) 
	RETURN VARCHAR2 
	AS curr_property properties.tracking_id%TYPE;
BEGIN
	SELECT tracking_id
	INTO curr_property
	FROM users
	JOIN properties ON users.user_property = properties.property_id
	WHERE users.user_id = this_user;

	RETURN UPPER(curr_property);
END get_property;


-- Check for room vacancies and dynamically set the status of house
CREATE OR REPLACE FUNCTION prop_vacancy_query(
    p_property_id       properties.property_id%TYPE
)
  RETURN NUMBER
IS
  v_prop_rooms NUMBER;
  pragma autonomous_transaction;
BEGIN
  SELECT COUNT(room_status) 
    INTO v_prop_rooms
    FROM rooms 
         JOIN properties ON
         properties.property_id = rooms.property_id
   WHERE room_status = 'VACANT'
   AND properties.property_id = p_property_id;
  RETURN v_prop_rooms;
  COMMIT;
END prop_vacancy_query;

-- Select the number of rooms
CREATE OR REPLACE FUNCTION search_x_rooms(
	p_property_id      properties.property_id%TYPE
)
	RETURN NUMBER
IS
	num_rooms NUMBER;
	pragma autonomous_transaction;
BEGIN
	SELECT COUNT(property_id) 
	INTO num_rooms FROM rooms
		JOIN properties ON rooms.property_id = properties.property_id;
	WHERE rooms.property_id = p_property_id;
	RETURN num_rooms;
END search_x_rooms;




Messages TABLE
Property Tracking Table


