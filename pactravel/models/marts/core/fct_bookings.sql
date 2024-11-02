with flight_bookings as (
    select * 
    from {{ ref("fct_flight_bookings") }}
),

hotel_bookings as (
    select * 
    from {{ ref("fct_hotel_bookings") }}
),

dim_trip as (
    select *
    from {{ ref("dim_trip") }}
),

dim_customers as (
    select *
    from {{ ref("dim_customers") }}
),


almost_fct_bookings as (
    select 
        sk_booking_id,
        trip_id,
        customer_id,
        price,
        booking_date_local,
        booking_date_utc,
        scheduled_departure_date_local as trip_date_local,
        scheduled_departure_date_utc as  trip_date_utc,
        'flight' as booking_type,
        created_at,
        updated_at
    from flight_bookings
    
    union all 

    select 
        sk_booking_id,
        trip_id,
        customer_id,
        price,
        booking_date_local,
        booking_date_utc,
        check_in_date_local as trip_date_local,
        check_in_date_utc as trip_date_utc,
        'hotel' as booking_type,
        created_at,
        updated_at
    from hotel_bookings    

),

final_fct_bookings as (
    select
        {{ dbt_utils.generate_surrogate_key ( ["sk_booking_id"] ) }} as sk_booking_id,
        booking_date_local,
        booking_date_utc,
        trip_id,
        trip_date_local,
        trip_date_utc,
        customer_id,
        price,
        booking_type,
        created_at,
        updated_at
    from almost_fct_bookings
)

select * from final_fct_bookings