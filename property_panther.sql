/*******************************************
*  	     Property Panther Database Code	   
*	     Author:  PRCSE		    		   
*        Date Created: 24/01/2014		   
*        Version: 2.0 					   
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
	tracking_id			VARCHAR2(30) 
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

	:NEW.room_details := TRIM(:NEW.room_details);
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
	tracking_id  		VARCHAR2(18),
	prop_addr			NUMBER(11)
						CONSTRAINT properties_prop_addr_fk
							REFERENCES addresses(addr_id)
						CONSTRAINT properties_prop_addr_nn
							NOT NULL,
	prop_details		VARCHAR2(1500)
						CONSTRAINT properties_prop_details_nn
							NOT NULL,
	num_rooms			NUMBER(11)
						CONSTRAINT properties_num_rooms_nn
							NOT NULL,
	prop_price			VARCHAR2(12) DEFAULT '0.00'
						CONSTRAINT properties_prop_price_chk
							CHECK(REGEXP_LIKE(prop_price,
								'-?\+?([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'))
						CONSTRAINT properties_prop_price_nn
							NOT NULL,
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
		IF :NEW.tracking_id IS NULL THEN
		SELECT DBMS_RANDOM.STRING ('X', 16)
		INTO :NEW.tracking_id
		FROM sys.dual;
		END IF;
	END IF;

	:NEW.prop_details := TRIM(:NEW.prop_details);
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
	student_id 			NUMBER(11)
						CONSTRAINT payments_student_id_fk
							REFERENCES students(student_id)
						CONSTRAINT payments_student_id_nn
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

	:NEW.payment_status := TRIM(UPPER(:NEW.payment_status));
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

INSERT INTO titles(title_name) VALUES('Miss');
INSERT INTO titles(title_name) VALUES('Mrs');
INSERT INTO titles(title_name) VALUES('Ms');
INSERT INTO titles(title_name) VALUES('Sir');
INSERT INTO titles(title_name) VALUES('Mr');

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
	pass_changed		NUMBER(1) DEFAULT 0
						CONSTRAINT users_pass_changed
	user_addr			NUMBER(11)
						CONSTRAINT users_user_addr_fk
							REFERENCES addresses(addr_id),
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
	user_permissions 	NUMBER(11) DEFAULT '0'
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

	IF UPDATING THEN
		/* Flag that the user has changed their password */
		IF(:NEW.user_pass != :OLD.user_pass) THEN
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

	:NEW.addr_line_1   :=  TRIM(UPPER(SUBSTR(:NEW.addr_line_1,1,1))||SUBSTR(:NEW.addr_line_1,2)) ||SUBSTR(:NEW.addr_line_1,3));
	:NEW.addr_line_2   :=  TRIM(UPPER(SUBSTR(:NEW.addr_line_2,1,1))||SUBSTR(:NEW.addr_line_2,2)) ||SUBSTR(:NEW.addr_line_2,3));
	:NEW.addr_postcode :=  replace(:NEW.addr_postcode, ' ', '');
	:NEW.addr_postcode :=  TRIM(UPPER(:NEW.addr_postcode));
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

	:NEW.city_name := UPPER(SUBSTR(:NEW.city_name,1,1))||SUBSTR(:NEW.city_name,2);

END;

/*******************************************
*          PAYMENT TRACKING TABLE          *
********************************************/
CREATE TABLE track_payments 
(
	payment_id 			NUMBER(11)
						CONSTRAINT track_payment_id_nn
							NOT NULL,
	student_id			NUMBER(11)
						CONSTRAINT track_student_id_nn
							NOT NULL,
	payment_amount		VARCHAR2(15)
						CONSTRAINT track_payment_amount_chk
							CHECK(REGEXP_LIKE(payment_amount,
								'-?\+?([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'
							))
						CONSTRAINT track_payment_amount_nn
							NOT NULL,
	payment_status 		VARCHAR2(30) DEFAULT 'PENDING'
						CONSTRAINT track_payment_status_chk
							CHECK( UPPER(payment_status) = 'PENDING' OR 
								   UPPER(payment_status) = 'OVERDUE' OR 
								   UPPER(payment_status) = 'PAID' OR
								   UPPER(payment_status) = 'PAID LATE'
								 )
						CONSTRAINT track_payment_status_nn
							NOT NULL,
	payment_due 		DATE
						CONSTRAINT track_payment_due_nn
							NOT NULL,
	payment_received	DATE DEFAULT NULL
);

CREATE SEQUENCE seq_pay_track_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_track_payments
BEFORE INSERT OR UPDATE ON track_payments FOR EACH ROW
	BEGIN
	IF INSERTING THEN
		IF :NEW.payment_id IS NULL THEN
			SELECT seq_pay_track_id.nextval
			INTO :NEW.payment_id
			FROM sys.dual;
		END IF;

		/* Handle the users payment status automatically on insert */
		IF (:NEW.payment_received != NULL) THEN
			IF(:NEW.payment_received <= :NEW.payment_due) THEN
				:NEW.payment_status = 'PAID'
			END IF;
			IF(:NEW.payment_received > :NEW.payment_due) THEN
				:NEW.payment_stauts = 'OVERDUE';
			END IF;
		END IF;
	END IF;

	IF UPDATING THEN
		/* The user paid late, so update their status to paid late */
		IF(:NEW.payment_status == 'PAID') THEN
			IF(:OLD.payment_received > :OLD.payment_due)
				:NEW.payment_status == 'PAID LATE';
			END IF;
		END IF;
	END IF;

	/* Perform any formatting */
	:NEW.payment_status := TRIM(UPPER(:NEW.payment_status));
	:NEW.payment_amount := TRIM(:NEW.payment_amount);

END;



/*******************************************
*        MAINTENANCE REQUEST TABLE         *
********************************************/
CREATE TABLE requests
(
	requests_id		NUMBER(11)
						CONSTRAINT requests_maintenance_id_pk
							PRIMARY KEY
						CONSTRAINT requests_maintenance_id_nn
							NOT NULL,
	tracking_id 		NUMBER(11)
						CONSTRAINT requests_tracking_id_nn
							NOT NULL,
	user_id 			NUMBER(11)
						CONSTRAINT requests_user_id_fk
							REFERENCES users(user_id)
						CONSTRAINT requests_user_id_nn
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
	request_log_date	DATE DEFAULT SYSDATE
						CONSTRAINT requests_req_log_date_nn
							NOT NULL,
	request_fin_date	DATE DEFAULT NULL
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
		IF(:NEW.request_status == 'COMPLETED') THEN
			IF(:NEW.request_fin_date >= :NEW.request_log_date) THEN
				request_fin_date := :NEW.request_fin_date;
			END IF;
		END IF;
	END IF;

	/* Update the fin date when job status is completed */
	IF UPDATING THEN 
		IF(:NEW.request_status == 'COMPLETED') THEN
			IF(SYSDATE >= :OLD.request_log_date) THEN
				:NEW.request_fin_date := SYSDATE;
			END IF;
		END IF;
	END IF;

	:NEW.request_status := TRIM(UPPER(:NEW.request_stats));
END;

/*******************************************
*     			  FUNCTIONS  			   *
********************************************/


