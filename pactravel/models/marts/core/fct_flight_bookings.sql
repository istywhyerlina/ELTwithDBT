with stg_flight_bookings as (
    select * , trip_id || flight_number || seat_number as trip_id2
    from {{ ref("stg_pactravel__flight_bookings") }}
),

dim_customers as (
    select *
    from {{ ref("dim_customers") }}
),

dim_airports as (
    select *
    from {{ ref("dim_airports") }}
),

dim_aircrafts as (
    select *
    from {{ ref("dim_aircrafts") }}
),

dim_airlines as (
    select *
    from {{ ref("dim_airlines") }}
),

dim_dates as (
    select *
    from {{ ref("dim_dates") }}
),

dim_times as (
    select *
    from {{ ref("dim_times") }}
),

dim_trip as (
    select *
    from {{ ref("dim_trip") }}
),

final_fct_flight_bookings as (
    select 
        {{ dbt_utils.generate_surrogate_key ( ["fb.trip_id","fb.flight_number","fb.seat_number"] ) }} as sk_booking_id,
        tr.sk_trip_id as trip_id,
        cu.sk_customer_id as customer_id,
        cu.customer_gender as customer_gender,
        cu.customer_country as customer_country,
        fb.flight_number as flight_number,
        al.sk_airline_id as airline_id,
        ac.sk_aircraft_id as aircraft_id,
        ap1.sk_airport_id as airport_src,
        ap2.sk_airport_id as airport_dst,
        dd3.date_id as booking_date_local,
        dd4.date_id as booking_date_utc,
        dd1.date_id as scheduled_departure_date_local,
        dd2.date_id as scheduled_departure_date_utc,
        dt1.time_id as scheduled_departure_time_local,
        dt2.time_id as scheduled_departure_time_utc,
        fb.flight_duration as flight_duration,
        fb.travel_class as travel_class,
        fb.seat_number as seat_number,
        fb.price as price,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from stg_flight_bookings fb
    join dim_trip tr
        on tr.nk_trip_id = fb.trip_id2
    join dim_customers cu
        on cu.nk_customer_id = fb.customer_id
    join dim_airlines al 
        on al.nk_airline_id = fb.airline_id
    join dim_airports ap1 
        on ap1.nk_airport_id = fb.airport_src
    join dim_airports ap2 
        on ap2.nk_airport_id = fb.airport_dst
    join dim_aircrafts ac
        on ac.nk_aircraft_id = fb.aircraft_id
    join dim_dates dd1 
        on dd1.date_actual = DATE(fb.departure_date)
    join dim_dates dd2
        on dd2.date_actual = DATE(fb.departure_date AT TIME ZONE 'UTC')
    join dim_dates dd3 
        on dd3.date_actual = DATE(fb.booking_date)
    join dim_dates dd4
        on dd4.date_actual = DATE(fb.booking_date AT TIME ZONE 'UTC')
    join dim_times dt1
        on dt1.time_actual::time = (fb.departure_time)::time
    join dim_times dt2
        on dt2.time_actual::time = (fb.departure_time AT TIME ZONE 'UTC')::time

)

select * from final_fct_flight_bookings