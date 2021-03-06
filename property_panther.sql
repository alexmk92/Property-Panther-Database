/*******************************************
*  	     Property Panther Database Code	   
*	     Author:  PRCSE		    		   
*        Date Created: 24/01/2014		   
*        Version: 3.0			   
********************************************/

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
	prop_track_code  	VARCHAR2(10)
						CONSTRAINT properties_tracking_id_nn
							NOT NULL,
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
	addr_district       VARCHAR2(100),
	city_name			VARCHAR2(100)
						CONSTRAINT cities_city_name_chk
							CHECK(REGEXP_LIKE(city_name,
								'[A-Za-z]{1,100}'))
						CONSTRAINT cities_city_name_nn
							NOT NULL,
	prop_details		VARCHAR2(1500)
						CONSTRAINT properties_prop_details_nn
							NOT NULL,
	prop_num_rooms		NUMBER(2) DEFAULT 1
						CONSTRAINT properties_num_rooms_nn
							NOT NULL,
	prop_status			VARCHAR2(20) DEFAULT 'VACANT'
						CONSTRAINT properties_prop_status_chk
							CHECK( UPPER(prop_status) = 'VACANT' OR 
								   UPPER(prop_status) = 'FULL' 
								 )
						CONSTRAINT prop_status_nn
							NOT NULL,
	google_map_code     VARCHAR2(512),
	date_added          DATE DEFAULT SYSDATE
						CONSTRAINT properties_prop_added_nn
							NOT NULL
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

		IF :NEW.prop_track_code IS NULL THEN
			SELECT DBMS_RANDOM.STRING ('X', 8)
			INTO :NEW.prop_track_code
			FROM sys.dual;
		END IF;
		-- Set the date
		IF :NEW.date_added IS NULL THEN
			:NEW.date_added := SYSDATE;
		END IF;
	END IF;

	-- Perform any formatting
	:NEW.prop_status     := TRIM(UPPER(:NEW.prop_status));
	:NEW.prop_details    := TRIM(:NEW.prop_details);
	:NEW.prop_track_code := TRIM(UPPER(:NEW.prop_track_code));
	:NEW.addr_line_1     := TRIM(UPPER(:NEW.addr_line_1));
	:NEW.addr_line_2     := TRIM(UPPER(:NEW.addr_line_2));
	:NEW.addr_postcode   := replace(:NEW.addr_postcode, ' ', '');
	:NEW.addr_postcode   := TRIM(UPPER(:NEW.addr_postcode));
	:NEW.addr_district   := TRIM(UPPER(:NEW.addr_district));
	:NEW.city_name       := TRIM(UPPER(:NEW.city_name));
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
							REFERENCES properties(property_id) ON DELETE SET NULL
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
							CHECK( UPPER(room_status) = 'VACANT' OR 
								   UPPER(room_status) = 'OCCUPIED' 
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
	END IF;

	-- Provide any formatting
	:NEW.room_status  := TRIM(UPPER(:NEW.room_status));
	:NEW.room_details := TRIM(:NEW.room_details);
	:NEW.room_price   := TRIM(:NEW.room_price);
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
						CONSTRAINT users_user_pass_nn
							NOT NULL,
	pass_changed		NUMBER(1) DEFAULT 0,
	addr_line_1			VARCHAR2(100)
						CONSTRAINT user_addr_ln_1_chk
							CHECK(REGEXP_LIKE(addr_line_1,
								'[A-Za-z0-9]')),
	addr_line_2			VARCHAR2(100)
						CONSTRAINT user_addr_ln_2_chk
							CHECK(REGEXP_LIKE(addr_line_2,
								'[A-Za-z0-9]')),
	addr_postcode		VARCHAR2(12)
						CONSTRAINT user_addr_post_chk
							CHECK(REGEXP_LIKE(addr_postcode,
								'(([A-PR-UW-Z]{1}[A-IK-Y]?)([0-9]?[A-HJKS-UW]?[ABEHMNPRVWXY]?|[0-9]?[0-9]?))\s?([0-9]{1}[ABD-HJLNP-UW-Z]{2})'
							)),
	city_name			VARCHAR2(100)
						CONSTRAINT city_name_chk
							CHECK(REGEXP_LIKE(city_name,
								'[A-Za-z]{1,100}')),
	user_title			VARCHAR2 (12),
	user_forename		VARCHAR2(50)
						CONSTRAINT users_user_forename_chk
							CHECK(REGEXP_LIKE(user_forename,
								'[A-Za-z-]{1,50}'))
						CONSTRAINT users_user_forename_nn
							NOT NULL,
	user_surname		VARCHAR2(50)
						CONSTRAINT users_user_surname_chk
							CHECK(REGEXP_LIKE(user_surname,
								'[A-Za-z-]{1,50}'))
						CONSTRAINT users_user_surname_nn
							NOT NULL,
	user_phone			VARCHAR2(14) 
						CONSTRAINT users_user_phone_chk
							CHECK(REGEXP_LIKE(user_phone,
								'[0-9]{5}\s?[0-9]{6}')),
	user_permissions 	VARCHAR2(15) DEFAULT 'USER'
						CONSTRAINT users_user_permission_nn
							NOT NULL
						CONSTRAINT users_user_permission_chk
							CHECK
							(	
								UPPER(user_permissions) = 'GUEST' OR
								UPPER(user_permissions) = 'USER'  OR
								UPPER(user_permissions) = 'ADMIN'
							),
	user_property		NUMBER(11) DEFAULT NULL
						CONSTRAINT users_user_house_fk
							REFERENCES properties(property_id) ON DELETE SET NULL,
	user_prop_room		NUMBER(11) DEFAULT NULL
						CONSTRAINT users_user_room_fk
							REFERENCES rooms(room_id) ON DELETE SET NULL,
	session_key         VARCHAR(40)
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

		-- First sign up will give a random password to the user
		IF :NEW.user_pass IS NULL THEN
			SELECT DBMS_RANDOM.STRING ('X', 6)
			INTO :NEW.user_pass
			FROM sys.dual;
		END IF;
	END IF;

	IF UPDATING THEN
		-- Flag that the user has changed their password 
		IF :NEW.user_pass != :OLD.user_pass THEN
			:NEW.pass_changed := 1;
		END IF;
	END IF;

	-- If the users Permissions are NULL then set a default value
	IF :NEW.user_permissions IS NULL THEN
		:NEW.user_permissions := 'USER';
  	END IF;

  	-- Has the password been changed, if not set to 0
  	IF :NEW.pass_changed IS NULL OR :NEW.pass_changed > 2 THEN
		:NEW.pass_changed := 0;
	END IF;

	-- Provide any formatting 
	:NEW.user_title    := TRIM(INITCAP(:NEW.user_title));
	:NEW.user_forename := TRIM(INITCAP(:NEW.user_forename));
	:NEW.user_surname  := TRIM(INITCAP(:NEW.user_surname));
	:NEW.user_email    := TRIM(LOWER(:NEW.user_email));
	:NEW.user_phone    := replace(:NEW.user_phone , ' ', '');
	:NEW.user_pass     := replace(:NEW.user_pass , ' ', '');
	:NEW.addr_line_1   := TRIM(UPPER(:NEW.addr_line_1));
	:NEW.addr_line_2   := TRIM(UPPER(:NEW.addr_line_2));
	:NEW.addr_postcode := replace(:NEW.addr_postcode, ' ', '');
	:NEW.addr_postcode := TRIM(UPPER(:NEW.addr_postcode));
END;

CREATE OR REPLACE TRIGGER trg_users_after
AFTER INSERT OR UPDATE ON users FOR EACH ROW
	BEGIN
	IF INSERTING THEN
	  	-- Alert a user that they need to change their password
		IF :NEW.pass_changed = 0 THEN
			send_message(:NEW.user_id, null, 'ALERT','Hello, ' || :NEW.user_forename || ' ' || :NEW.user_surname || 
				         ', and thank-you for registering with property panther!  Please login with the username: ' || 
				         :NEW.user_email || ' and the password: ' || :NEW.user_pass || ', it is important you change this temporary password for security reasons!', null, 0);
		END IF;
	END IF;

	IF UPDATING THEN 
		-- Update the user rooms table
		IF :NEW.user_prop_room IS NOT NULL THEN
			UPDATE rooms
			SET rooms.room_status = 'OCCUPIED'
			WHERE rooms.room_id = :NEW.user_prop_room;
		-- If Null, the user has moved out, set vacancy accordingly
		ELSIF :NEW.user_prop_room IS NULL THEN
			-- Check they lived at a property before, else do nothing
			IF :OLD.user_prop_room IS NOT NULL THEN 
				UPDATE rooms
				SET rooms.room_status = 'VACANT'
				WHERE rooms.room_id = :OLD.user_prop_room;
			END IF;
		END IF;
	END IF;
END;



/*******************************************
*                NOTES TABLE               *
********************************************/
CREATE TABLE notes
(
	note_id 			NUMBER(11)
						CONSTRAINT notes_note_id_pk
							PRIMARY KEY
						CONSTRAINT notes_note_id_nn
							NOT NULL,
	user_id 			NUMBER(11)
						CONSTRAINT notes_user_id_fk
							REFERENCES users(user_id) ON DELETE CASCADE,
	note_body			VARCHAR2(250)
						CONSTRAINT notes_note_body_nn
							NOT NULL,
	note_date			DATE DEFAULT SYSDATE			
);

CREATE SEQUENCE seq_note_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_notes
BEFORE INSERT OR UPDATE ON notes FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.note_id IS NULL THEN
			SELECT seq_note_id.nextval
			INTO :NEW.note_id
			FROM sys.dual;
		END IF;
	END IF;

	-- if default fails
	IF :NEW.note_date IS NULL THEN
		:NEW.note_date := SYSDATE;
    END IF;

	/* Provide any formatting */
	:NEW.note_body := TRIM(:NEW.note_body);
END;

/*******************************************
*               MESSAGES TABLE             *
********************************************/
CREATE TABLE messages
(
	message_id			NUMBER(11)
						CONSTRAINT inbox_message_id_pk
							PRIMARY KEY
						CONSTRAINT inbox_message_id_nn
							NOT NULL,
	message_to 			NUMBER(11)
						CONSTRAINT inbox_message_to_fk
							REFERENCES users(user_id) ON DELETE CASCADE,
	message_from 		NUMBER(11)
						CONSTRAINT inbox_message_from_fk
							REFERENCES users(user_id) ON DELETE CASCADE,
	message_type		VARCHAR2(150) DEFAULT 'INBOX'
						CONSTRAINT inbox_message_type_chk
							CHECK
							(	
								UPPER(message_type) = 'INBOX' OR
								UPPER(message_type) = 'MAINTENANCE' OR
								UPPER(message_type) = 'ALERT'
							)
						CONSTRAINT inbox_message_type_nn
							NOT NULL,
	message_body		VARCHAR2(500)
						CONSTRAINT inbox_message_body_nn
							NOT NULL,
	message_sent		DATE,
	message_read		NUMBER(1) DEFAULT 0,
	request_id          CONSTRAINT inbox_request_id_fk
							REFERENCES requests(request_id) ON DELETE SET NULL
);

CREATE SEQUENCE seq_inbox_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_messages
BEFORE INSERT OR UPDATE ON messages FOR EACH ROW
	BEGIN 
	IF INSERTING THEN
		IF :NEW.message_id IS NULL THEN
			SELECT seq_inbox_id.nextval
			INTO :NEW.message_id
			FROM sys.dual;
		END IF;
	END IF;

	-- Set the sent date to SYSDATE
	IF :NEW.message_sent IS NULL THEN
		:NEW.message_sent := SYSDATE;
	END IF;

	-- Set the default value if the default fails
	IF :NEW.message_read IS NULL THEN
		:NEW.message_read := 0;
	END IF;

	/* Provide any formatting */
	:NEW.message_type := TRIM(UPPER(:NEW.message_type));
	:NEW.message_body := TRIM(:NEW.message_body);
	:NEW.message_from := TRIM(UPPER(:NEW.message_from));
	:NEW.message_to   := TRIM(UPPER(:NEW.message_to));

END;


/*******************************************
*          PROPERTY TRACKING TABLE         *
********************************************/
CREATE TABLE property_tracking
(
	tracking_id 		NUMBER(11)
						CONSTRAINT prop_track_id_pk
							PRIMARY KEY
						CONSTRAINT prop_track_id_nn
							NOT NULL,
	prop_track_id       NUMBER(11)
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
		IF :NEW.tracking_id IS NULL THEN
			SELECT seq_property_tracking_id.nextval
			INTO :NEW.tracking_id
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
							REFERENCES users(user_id) ON DELETE SET NULL,
	reference_id 		VARCHAR2(12)
						CONSTRAINT payments_ref_id_nn
							NOT NULL,
	payment_amount		VARCHAR2(15)
						CONSTRAINT payment_amount_chk
							CHECK(REGEXP_LIKE(payment_amount,
								'-?\+?([0-9]{0,10})(\.[0-9]{2})?$|^-?(100)(\.[0]{1,2})'
							))
						CONSTRAINT payment_amount_nn
							NOT NULL,
	payment_status		VARCHAR(50) 
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
	payment_received    DATE,
	property_id         VARCHAR2(18)
						CONSTRAINT payments_property_id_nn
							NOT NULL
);

CREATE SEQUENCE seq_payment_id   START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_payments
BEFORE INSERT OR UPDATE ON payments FOR EACH ROW
	BEGIN 
	/* If the default fails then set status to RECEIVED */
	IF :NEW.payment_status IS NULL THEN
		:NEW.payment_status := 'PENDING';
	END IF;
	IF :NEW.payment_due IS NULL THEN
		:NEW.payment_due := SYSDATE;
	END IF;

	IF INSERTING THEN
		IF :NEW.payment_id IS NULL THEN
			SELECT seq_payment_id.nextval
			INTO :NEW.payment_id
			FROM sys.dual;
		END IF;
		IF :NEW.reference_id IS NULL THEN
			SELECT DBMS_RANDOM.STRING ('X', 8)
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
	IF :NEW.payment_due > SYSDATE AND :NEW.payment_received IS NULL THEN
		:NEW.payment_status := 'PENDING';
	END IF;
	-- Is the payment overdue?
	IF :NEW.payment_due < SYSDATE AND :NEW.payment_received IS NULL THEN
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

CREATE OR REPLACE TRIGGER trg_payments_after
AFTER INSERT OR UPDATE ON payments FOR EACH ROW
BEGIN
	-- An inserted payment can only be pending
	IF INSERTING THEN
		-- SEND THE ALERT REQUEST TO THE MESSAGE TABLE
		-------------------------------------------------------------------
		-- Msg 1 - Targets the user who paid, message will show from system
		-- Msg 2 - Targets an admin only, message will show from system
		IF :NEW.payment_status = 'PENDING' THEN 
	       send_message(:NEW.user_id, NULL, 'ALERT', getMessage(:NEW.user_id, 'PENDING'), NULL, 0);
	       send_message(NULL, NULL, 'ALERT', getName(:NEW.user_id) || ' is due to pay £' || :NEW.payment_amount || ' on ' || :NEW.payment_due || '.', NULL, 0);
	    END IF;
	END IF;

	IF UPDATING THEN
		-- SEND THE ALERT REQUEST TO THE MESSAGE TABLE
		-------------------------------------------------------------------
		-- Msg 1 - Targets the user who paid, message will show from system
		-- Msg 2 - Targets an admin only, message will show from system
	    IF :NEW.user_id IS NOT NULL THEN 
	      IF :NEW.payment_status = 'PAID' THEN 		
	           send_message(:NEW.user_id, NULL, 'ALERT', getMessage(:NEW.user_id, 'PAID'), NULL, 0);                                          
	           send_message(NULL, NULL, 'ALERT', getName(:NEW.user_id) || ' has just made a payment of £' || :NEW.payment_amount || '.', NULL, 0);  
	        ELSIF :NEW.payment_status = 'PAID LATE' THEN 
	           send_message(:NEW.user_id, NULL, 'ALERT', getMessage(:NEW.user_id, 'PAID LATE'), NULL, 0);
	           send_message(NULL, NULL, 'ALERT', getName(:NEW.user_id) || ' has just made a late payment of £' || :NEW.payment_amount || '.', NULL, 0);
	        ELSIF :NEW.payment_status = 'OVERDUE' THEN 
	           send_message(:NEW.user_id, NULL, 'ALERT', getMessage(:NEW.user_id, 'OVERDUE'), NULL, 0);
	           send_message(NULL, NULL, 'ALERT', getName(:NEW.user_id) || ' has an outstanding payment of £' || :NEW.payment_amount || ', this needs to be addressed.', NULL, 0);
	      END IF;
	    END IF;
	END IF;
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
	tracking_id 		VARCHAR2(10)
						CONSTRAINT requests_tracking_id_nn
							NOT NULL,
	user_id 			NUMBER(11)
						CONSTRAINT requests_user_id_fk
							REFERENCES users(user_id) ON DELETE CASCADE,
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
	request_log_date	DATE DEFAULT SYSDATE,
	request_fin_date	DATE,
	updated_date        DATE DEFAULT NULL
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
			SELECT DBMS_RANDOM.STRING ('X', 8)
			INTO :NEW.tracking_id
			FROM sys.dual;
		END IF;

		-- If a fin date is specifeid then set it (unlogged requests can be logged later)
		IF :NEW.request_status = 'COMPLETED' THEN
			IF :NEW.request_fin_date >= :NEW.request_log_date THEN
				:NEW.request_fin_date := :NEW.request_fin_date;
			END IF;
		END IF;

		-- Sets the log date
		IF :NEW.request_log_date IS NULL THEN 
			:NEW.request_log_date := SYSDATE;
		END IF;
	END IF;

	/* Update the fin date when job status is completed */
	IF UPDATING THEN 
	    -- Ensure the date is set to the last record update
	    IF :NEW.updated_date < SYSDATE OR :NEW.updated_date IS NULL THEN
	    	:NEW.updated_date := SYSDATE;
	    END IF;

		-- Set the date of completion ONLY when status is completed
		IF :NEW.request_status = 'COMPLETED' THEN
			IF SYSDATE >= :OLD.request_log_date THEN
				:NEW.request_fin_date := SYSDATE;
			END IF;
		END IF;

		-- A log date cannot be changed
		IF :NEW.request_log_date IS NOT NULL THEN
			:NEW.request_log_date := :OLD.request_log_date;
		END IF;
	END IF;

	/* If the default fails then set status to RECEIVED */
	IF :NEW.request_status IS NULL THEN
		:NEW.request_status := 'RECEIVED';
	END IF;

	:NEW.request_status  := TRIM(UPPER(:NEW.request_status));
	:NEW.request_details := TRIM(:NEW.request_details);
END;

CREATE OR REPLACE TRIGGER trg_requests_after
AFTER INSERT OR UPDATE ON requests FOR EACH ROW
BEGIN
	IF :NEW.user_id IS NOT NULL THEN
		IF :NEW.request_status = 'RECEIVED' THEN 
		    send_message(:NEW.user_id, NULL, 'MAINTENANCE', getMessage(:NEW.user_id, 'RECEIVED'), :NEW.requests_id, 1);
		END IF;

		IF UPDATING THEN
			-- Send a message
			IF :NEW.request_status = 'SEEN' THEN 
		       send_message(:NEW.user_id, NULL, 'MAINTENANCE', getMessage(:NEW.user_id, 'SEEN'), :NEW.requests_id, 0);
		    ELSIF :NEW.request_status = 'SCHEDULED' THEN 
		       send_message(:NEW.user_id, NULL, 'MAINTENANCE', getMessage(:NEW.user_id, 'SCHEDULED'), :NEW.requests_id, 0);
		    ELSIF :NEW.request_status = 'IN PROGRESS' THEN 
		       send_message(:NEW.user_id, NULL, 'MAINTENANCE', getMessage(:NEW.user_id, 'IN PROGRESS'), :NEW.requests_id, 0);
		    ELSIF :NEW.request_status = 'COMPLETED' THEN
		    	send_message(:NEW.user_id, NULL, 'MAINTENANCE', getMessage(:NEW.user_id, 'COMPLETED'), :NEW.requests_id, 0);
			END IF;
		END IF;
	END IF;
END;

/*******************************************
*                FUNCTIONS                 *
********************************************/
-- SENDS A MESSAGE TO A USER UPON AN ACTION
-- @param - the user who sent the message
-- @param - the user who receives the message
-- @param - the type of message : ALERT, MAINTENANCE, INBOX
-- @param - message (the message)
-- @param - the request_id passed, this can be nulled
-- @param - has a new request been made or are we just updating an object
-- NOTE: If from_user is NULL then render it as SYSTEM on application
CREATE OR REPLACE PROCEDURE send_message( 
	to_user      users.user_id%TYPE, 
	from_user    users.user_id%TYPE,
	msg_type     STRING,
	this_message STRING,
	request_id   requests.requests_id%TYPE,
	made_request NUMBER
)
	AS
	user_name    STRING(50);
    user_last    STRING(50);
BEGIN
    -- Send the message to the user
    IF to_user IS NOT NULL THEN
		INSERT INTO messages 
		VALUES('', to_user, from_user, msg_type, this_message, '', '', request_id);
	END IF;

    -- Prompt the admin that a user made a request
	IF request_id IS NOT NULL AND made_request = 1 THEN

		-- Insert to the messages table
		INSERT INTO messages 
		VALUES('', '', '', msg_type, getName(to_user) || ' has just made a maintenance request.', '', '', request_id);
	
	END IF;

	-- Send a message to the admin noting that a payment has been made
	IF to_user IS NULL AND from_user IS NULL AND this_message IS NOT NULL THEN
	    INSERT INTO messages 
	    VALUES('', '', '', msg_type, this_message, '', '', request_id);
	END IF;
END send_message;

-- RETURNS THE MESSAGE FOR A USER
-- @param  - the user we want to get
-- @param  - the message type we will return : PAID, OVERDUE, PAID LATE...
-- @pragma - uses an autonomous transaction to allow updating independent of the master transaction.
CREATE OR REPLACE FUNCTION getMessage(
	this_user	    users.user_id%TYPE,
	status          STRING
)
	RETURN STRING
IS
	this_message    STRING(500);
    date_booked     DATE;
    date_overdue    DATE;
BEGIN 
  IF this_user IS NOT NULL THEN 
    -- Payment types
    IF status = 'PAID' THEN
      this_message := 'Hello, ' || getName(this_user) || ' just a short message to notify you that we received your payment on time - thank-you!.\n\nRegards,\nThe Property Panther team.';
    ELSIF status = 'PAID LATE' THEN
      this_message := 'Hello, ' || getName(this_user) || ' we have noticed that you paid your rent late this month, please ensure this does not become a habit as we may have to start charging interest on late payments in future.\n\nRegards,\nThe Property Panther team.';
    ELSIF status = 'OVERDUE' THEN
      this_message := 'Hello, ' || getName(this_user) || ' it has come to our attention that you have an outstanding payment, this needs to be paid within the next 7 working days or you risk incurring a fee of up to £500.00.\n\nRegards,\nThe Property Panther team.';
    ELSIF status = 'PENDING' THEN
      this_message := 'Hello, ' || getName(this_user) || ' you have a new payment outstanding on your property. You can also pay your rent in advance if you wish from your dashboard.\n\nRegards,\nThe Property Panther team.';
  
    -- Maintenance request types
    ELSIF status = 'RECEIVED' THEN
      this_message := 'Hello, ' || getName(this_user) || ' your maintenance request has been received as of ' || SYSDATE || ', please continue to watch this space as we process your request.\nCurrent Status: RECEIVED.\n\nRegards,\nThe Property Panther team.';
    ELSIF status = 'SEEN' THEN 
      this_message := 'Hello, ' || getName(this_user) || ' one of our agents has just viewed you request, we are now in the process of booking a time slot for you, you shall be notified on this update.\nCurrent Status: SEEN.\n\nRegards,\nThe Property Panther team.';
    ELSIF status = 'SCHEDULED' THEN 
      this_message := 'Hello, ' || getName(this_user) || ' we have scheduled your request for: ' || SYSDATE || ' if this is of any inconvenience please contact us immediately, any updates shall be forwarded to you.\nCurrent Status: SCHEDULED.\n\nRegards,\nThe Property Panther team.';
    ELSIF status = 'IN PROGRESS' THEN
      this_message := 'Hello, ' || getName(this_user) || ' an enginner has been sent out to your property to complete the outstanding task, we hope this resolves your problem.\nCurrent Status: IN PROGRESS.\n\nRegards,\nThe Property Panther team.';
    ELSIF status = 'COMPLETED' THEN
      this_message := 'Hello, ' || getName(this_user) || ' your request has been successfully completed today (' || SYSDATE || '), thank-you for your patience and co-operation.\nCurrent Status: COMPLETED.\n\nRegards,\nThe Property Panther team.';
    END IF;
  END IF;

	RETURN this_message;
END;


-- RETURNS THE NAME OF A USER
-- @param  - the users id, whose name we want to get
CREATE OR REPLACE FUNCTION getName(
	this_user		users.user_id%TYPE
)
	RETURN STRING
IS
	this_forename	STRING(50);
	this_surname 	STRING(50);
BEGIN
	IF this_user IS NOT NULL THEN 
		-- Populate the name variables
		SELECT user_forename, user_surname
		INTO   this_forename, this_surname
		FROM   users 
		WHERE  user_id = this_user;
	END IF;

	-- Return the concatenated name
	RETURN this_forename || ' ' || this_surname;
END getName;

