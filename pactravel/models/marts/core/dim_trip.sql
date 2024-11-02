with stg_flight_bookings as (
    select * 
    from {{ ref("stg_pactravel__flight_bookings") }}
),
stg_hotel_bookings as (
    select * 
    from {{ ref("stg_pactravel__hotel_bookings") }}
),
almost_dim_trip as (
    select 
        trip_id || flight_number || seat_number as nk_trip_id,
        departure_date as trip_date
    from stg_flight_bookings
    
    union all 

    select 
        cast (trip_id as text) as nk_trip_id,
        check_in_date as trip_date
    from stg_hotel_bookings    

),



final_dim_trip as (
    select
        {{ dbt_utils.generate_surrogate_key( ["nk_trip_id"] ) }} as sk_trip_id,
        *,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from almost_dim_trip
)

select * from final_dim_trip