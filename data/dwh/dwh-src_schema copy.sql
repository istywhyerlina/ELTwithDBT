CREATE SCHEMA IF NOT EXISTS pactravel AUTHORIZATION postgres;


CREATE TABLE pactravel.aircrafts (
    aircraft_name character varying,
    aircraft_iata character varying,
    aircraft_icao character varying,
    aircraft_id character varying NOT NULL
);


ALTER TABLE pactravel.aircrafts OWNER TO postgres;

--
-- Name: airlines; Type: TABLE; Schema: pactravel; Owner: postgres
--

CREATE TABLE pactravel.airlines (
    airline_id integer NOT NULL,
    airline_name character varying,
    country character varying,
    airline_iata character varying,
    airline_icao character varying,
    alias character varying
);


ALTER TABLE pactravel.airlines OWNER TO postgres;

--
-- Name: airports; Type: TABLE; Schema: pactravel; Owner: postgres
--

CREATE TABLE pactravel.airports (
    airport_id integer NOT NULL,
    airport_name character varying,
    city character varying,
    latitude double precision,
    longitude double precision
);


ALTER TABLE pactravel.airports OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: pactravel; Owner: postgres
--

CREATE TABLE pactravel.customers (
    customer_id integer NOT NULL,
    customer_first_name character varying,
    customer_family_name character varying,
    customer_gender character varying,
    customer_birth_date date,
    customer_country character varying,
    customer_phone_number bigint
);


ALTER TABLE pactravel.customers OWNER TO postgres;

--
-- Name: flight_bookings; Type: TABLE; Schema: pactravel; Owner: postgres
--

CREATE TABLE pactravel.flight_bookings (
    trip_id integer NOT NULL,
    customer_id integer,
    flight_number character varying(32) NOT NULL,
    airline_id integer,
    aircraft_id character varying(32),
    airport_src integer,
    airport_dst integer,
    departure_time time without time zone,
    departure_date date,
    booking_time time without time zone,
    booking_date date,
    flight_duration character varying(32),
    travel_class character varying(32),
    seat_number character varying(32) NOT NULL,
    price integer
);


ALTER TABLE pactravel.flight_bookings OWNER TO postgres;

--
-- Name: hotel; Type: TABLE; Schema: pactravel; Owner: postgres
--

CREATE TABLE pactravel.hotel (
    hotel_id integer NOT NULL,
    hotel_name character varying,
    hotel_address character varying,
    city character varying,
    country character varying,
    hotel_score double precision
);


ALTER TABLE pactravel.hotel OWNER TO postgres;

--
-- Name: hotel_bookings; Type: TABLE; Schema: pactravel; Owner: postgres
--

CREATE TABLE pactravel.hotel_bookings (
    trip_id integer NOT NULL,
    customer_id integer,
    hotel_id integer,
    booking_date date,
    booking_time time without time zone,
    check_in_date date,
    check_out_date date,
    price integer,
    breakfast_included boolean
);


ALTER TABLE pactravel.hotel_bookings OWNER TO postgres;


--
-- Name: aircrafts aircrafts_pkey; Type: CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.aircrafts
    ADD CONSTRAINT aircrafts_pkey PRIMARY KEY (aircraft_id);


--
-- Name: airlines airlines_pkey; Type: CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.airlines
    ADD CONSTRAINT airlines_pkey PRIMARY KEY (airline_id);


--
-- Name: airports airports_pkey; Type: CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.airports
    ADD CONSTRAINT airports_pkey PRIMARY KEY (airport_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: flight_bookings flight_bookings_pkey; Type: CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.flight_bookings
    ADD CONSTRAINT flight_bookings_pkey PRIMARY KEY (trip_id, flight_number, seat_number);


--
-- Name: hotel_bookings hotel_bookings_pkey; Type: CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.hotel_bookings
    ADD CONSTRAINT hotel_bookings_pkey PRIMARY KEY (trip_id);


--
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (hotel_id);


--
-- Name: flight_bookings fk_flight_aircraft; Type: FK CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.flight_bookings
    ADD CONSTRAINT fk_flight_aircraft FOREIGN KEY (aircraft_id) REFERENCES pactravel.aircrafts(aircraft_id);


--
-- Name: flight_bookings fk_flight_airline; Type: FK CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.flight_bookings
    ADD CONSTRAINT fk_flight_airline FOREIGN KEY (airline_id) REFERENCES pactravel.airlines(airline_id);


--
-- Name: flight_bookings fk_flight_airport_dst; Type: FK CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.flight_bookings
    ADD CONSTRAINT fk_flight_airport_dst FOREIGN KEY (airport_dst) REFERENCES pactravel.airports(airport_id);


--
-- Name: flight_bookings fk_flight_airport_src; Type: FK CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.flight_bookings
    ADD CONSTRAINT fk_flight_airport_src FOREIGN KEY (airport_src) REFERENCES pactravel.airports(airport_id);


--
-- Name: flight_bookings fk_flight_customer; Type: FK CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.flight_bookings
    ADD CONSTRAINT fk_flight_customer FOREIGN KEY (customer_id) REFERENCES pactravel.customers(customer_id);


--
-- Name: hotel_bookings fk_hotel_booking_customer; Type: FK CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.hotel_bookings
    ADD CONSTRAINT fk_hotel_booking_customer FOREIGN KEY (customer_id) REFERENCES pactravel.customers(customer_id);


--
-- Name: hotel_bookings fk_hotel_booking_hotel; Type: FK CONSTRAINT; Schema: pactravel; Owner: postgres
--

ALTER TABLE ONLY pactravel.hotel_bookings
    ADD CONSTRAINT fk_hotel_booking_hotel FOREIGN KEY (hotel_id) REFERENCES pactravel.hotel(hotel_id);


--
-- PostgreSQL database dump complete
--

