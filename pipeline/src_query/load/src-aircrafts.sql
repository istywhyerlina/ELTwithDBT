INSERT INTO pactravel.aircrafts 
    (aircraft_name,
    aircraft_iata,
    aircraft_icao,
    aircraft_id) 

SELECT
    aircraft_name,
    aircraft_iata,
    aircraft_icao,
    aircraft_id
FROM olist.customers
