with rentals as (
select *
from hip-weaver-479921-q2.staging_db.stg_rental
) 
,

customers as (
select *
from hip-weaver-479921-q2.staging_db.stg_customer
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
from rentals
left join customers on rentals.customer_id = customers.customer_id
group by 1,2,3
union all

select
'Month' as reporting_period
, date_trunc(rentals.rental_date, month) as reporting_date
, customers.customer_id
, count(*) as total_rentals
from rentals
left join customers on rentals.customer_id = customers.customer_id
group by 1,2,3
union all

select
'Year' as reporting_period
, date_trunc(rentals.rental_date, year) as reporting_date
, customers.customer_id
, count(*) as total_rentals
from rentals
left join customers on rentals.customer_id = customers.customer_id
group by 1,2,3
) 
,

final as (
select
reporting_dates.reporting_period
, reporting_dates.reporting_date
, rentals_per_period.customer_id
, rentals_per_period.total_rentals
from reporting_dates
inner join rentals_per_period
on reporting_dates.reporting_period = rentals_per_period.reporting_period
and reporting_dates.reporting_date =rentals_per_period.reporting_date
where reporting_dates.reporting_period = 'Day'
union all

select
reporting_dates.reporting_period
, reporting_dates.reporting_date
, rentals_per_period.customer_id
, rentals_per_period.total_rentals
from reporting_dates
inner join rentals_per_period
on reporting_dates.reporting_period = rentals_per_period.reporting_period
and reporting_dates.reporting_date = rentals_per_period.reporting_date
where reporting_dates.reporting_period = 'Month'
union all

select
reporting_dates.reporting_period
, reporting_dates.reporting_date
, rentals_per_period.customer_id
, rentals_per_period.total_rentals
from reporting_dates
inner join rentals_per_period
on reporting_dates.reporting_period = rentals_per_period.reporting_period
and reporting_dates.reporting_date = rentals_per_period.reporting_date
where reporting_dates.reporting_period = 'Year'
)

select * from final