
DROP TABLE IF EXISTS temp1;
CREATE TEMP TABLE temp1 as select * from flight_bookings2;



with batas as(SELECT *,  date_trunc('year', departure_date) first_day, departure_date+departure_time as departure_datetime from temp1),


acak as (SELECT *, random() * (departure_datetime::timestamp - first_day::timestamp) + first_day::timestamp  as rand from batas),
akhir as (select trip_id, customer_id, flight_number, airline_id, aircraft_id, airport_src, airport_dst, departure_time, departure_date, rand::time as booking_time,  rand::date as booking_date, travel_class, seat_number, price from acak)

insert into flight_bookings2 (select * from akhir);


DROP TABLE IF EXISTS temp2;
CREATE TEMP TABLE temp2 as select * from hotel_bookings;



with batas as(SELECT *,  date_trunc('year', check_in_date) first_day, concat(check_in_date,' 12:00:00') as checkin_datetime from temp2),


acak as (SELECT *, random() * (checkin_datetime::timestamp - first_day::timestamp) + first_day::timestamp  as rand from batas),
akhir as (select trip_id, customer_id, hotel_id, rand::time as booking_time,  rand::date as booking_date,  check_in_date, check_out_date,  price, breakfast_included from acak)

insert into hotel_bookings2 (trip_id, customer_id, hotel_id, booking_time,  booking_date,  check_in_date, check_out_date,  price, breakfast_included) (select * from akhir)

--