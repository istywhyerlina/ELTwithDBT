with stg_hotel_bookings as (
    select * 
    from {{ ref("stg_pactravel__hotel_bookings") }}
),

dim_times as (
    select *
    from {{ ref("dim_times") }}
),

dim_customers as (
    select *
    from {{ ref("dim_customers") }}
),

dim_hotel as (
    select *
    from {{ ref("dim_hotel") }}
),


dim_dates as (
    select *
    from {{ ref("dim_dates") }}
),

dim_trip as (
    select *
    from {{ ref("dim_trip") }}
),

final_fct_hotel_bookings as (
    select 
        {{ dbt_utils.generate_surrogate_key ( ["hb.trip_id"] ) }} as sk_booking_id,
        tr.sk_trip_id as trip_id,
        cu.sk_customer_id as customer_id,
        cu.customer_gender as customer_gender,
        cu.customer_country as customer_country,
        h.sk_hotels_id as hotel_id,
        dd1.date_id as check_in_date_local,
        dd2.date_id as check_in_date_utc,
        dd3.date_id as check_out_date_local,
        dd4.date_id as check_out_date_utc,
        dd5.date_id as booking_date_local,
        dd6.date_id as booking_date_utc,
        hb.price as price,
        hb.breakfast_included as breakfast_included,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from stg_hotel_bookings hb
    join dim_trip tr
        on tr.nk_trip_id = cast (hb.trip_id as text)
    join dim_customers cu
        on cu.nk_customer_id = hb.customer_id
    join dim_hotel h 
        on h.nk_hotel_id = hb.hotel_id
    join dim_dates dd1 
        on dd1.date_actual = DATE(hb.check_in_date)
    join dim_dates dd2
        on dd2.date_actual = DATE(hb.check_in_date AT TIME ZONE 'UTC')
    join dim_dates dd3 
        on dd3.date_actual = DATE(hb.check_out_date)
    join dim_dates dd4
        on dd4.date_actual = DATE(hb.check_out_date AT TIME ZONE 'UTC')
    join dim_dates dd5 
        on dd5.date_actual = DATE(hb.booking_date)
    join dim_dates dd6
        on dd6.date_actual = DATE(hb.booking_date AT TIME ZONE 'UTC')

)

select * from final_fct_hotel_bookings