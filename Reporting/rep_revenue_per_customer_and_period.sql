create table if not exists hip-weaver-479921-q2.reporting_db.rep_revenue_per_customer_and_period as

with rentals as (
select r.*
from hip-weaver-479921-q2.staging_db.stg_rental r
left join hip-weaver-479921-q2.staging_db.stg_inventory i 
  on r.inventory_id = i.inventory_id
left join hip-weaver-479921-q2.staging_db.stg_film f
  on i.film_id = f.film_id
where f.film_title != 'GOODFELLAS SALUTE'

)
,

customers as (
select *
from hip-weaver-479921-q2.staging_db.stg_customer
) 
,

payments as (
select *
from hip-weaver-479921-q2.staging_db.stg_payment
)
,

reporting_dates as (
select *
from hip-weaver-479921-q2.reporting_db.reporting_periods_table
where reporting_period in ('Day','Month','Year')
) 
,

rentals_per_period as (
select
'Day' as reporting_period
, date_trunc(rentals.rental_date, day) as reporting_date
, customers.customer_id
, count(*) as total_rentals
, sum(payments.payment_amount) as total_payment_amount
from rentals
left join customers on rentals.customer_id = customers.customer_id
left join payments on rentals.rental_id = payments.rental_id
group by 1,2,3
union all

select
'Month' as reporting_period
, date_trunc(rentals.rental_date, month) as reporting_date
, customers.customer_id
, count(*) as total_rentals
, sum(payments.payment_amount) as total_payment_amount
from rentals
left join customers on rentals.customer_id = customers.customer_id
left join payments on rentals.rental_id = payments.rental_id
group by 1,2,3
union all

select
'Year' as reporting_period
, date_trunc(rentals.rental_date, year) as reporting_date
, customers.customer_id
, count(*) as total_rentals
, sum(payments.payment_amount) as total_payment_amount
from rentals
left join customers on rentals.customer_id = customers.customer_id
left join payments on rentals.rental_id = payments.rental_id
group by 1,2,3
) 
,

final as (
select
reporting_dates.reporting_period
, reporting_dates.reporting_date
, rentals_per_period.customer_id
, rentals_per_period.total_rentals
, coalesce(rentals_per_period.total_payment_amount, 0) as total_payment_amount
from reporting_dates
left join rentals_per_period
on reporting_dates.reporting_period = rentals_per_period.reporting_period
and reporting_dates.reporting_date = rentals_per_period.reporting_date
)

select * from final
order by reporting_period, reporting_date, customer_id