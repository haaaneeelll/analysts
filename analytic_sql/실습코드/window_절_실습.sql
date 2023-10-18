/************************************************
강의 실습 - windows 절
 *************************************************/

/* rows between unbounded preceding and current row */
select *, sum(unit_price) over (order by unit_price) as unit_price_sum from products;

select *, sum(unit_price) over (order by unit_price rows between unbounded preceding and current row) as unit_price_sum from products;

select *, sum(unit_price) over (order by unit_price rows unbounded preceding) as unit_price_sum from products;

/* 중앙합, 중앙 평균(Centered average) */
select product_id, product_name, category_id, unit_price
	, sum(unit_price) over (partition by category_id order by unit_price rows between 1 preceding and 1 following) as unit_price_sum 
	, avg(unit_price) over (partition by category_id order by unit_price rows between 1 preceding and 1 following) as unit_price_avg 
from products;

/* rows between current row and unbounded following */
select product_id, product_name, category_id, unit_price
, sum(unit_price) over (partition by category_id order by unit_price rows between current row and unbounded following) as unit_price_sum 
from products;


/* range와 rows의 차이 */
with
temp_01 as (
select c.category_id, date_trunc('day', b.order_date) as ord_date, sum(a.amount) sum_by_daily_cat
from order_items a
	join orders b on a.order_id = b.order_id 
	join products c on a.product_id = c.product_id 
group by c.category_id, date_trunc('day', b.order_date) 
order by 1, 2
)
select *
	, sum(sum_by_daily_cat) over (partition by category_id order by ord_date 
	                              rows between 2 preceding and current row)
	, sum(sum_by_daily_cat) over (partition by category_id order by ord_date 
	                              range between interval '2' day preceding and current row)
from temp_01;

/************************************************
이동평균 실습
 *************************************************/

-- 3일 이동 평균 매출
with
temp_01 as (
select date_trunc('day', b.order_date)::date as ord_date, sum(amount) as daily_sum
from order_items a
	join orders b on a.order_id = b.order_id
group by date_trunc('day', b.order_date)::date 
)
select ord_date, daily_sum
	, avg(daily_sum) over (order by ord_date 
	                              rows between 2 preceding and current row) as ma_3days
from temp_01;

-- 3일 중앙 평균 매출
with
temp_01 as (
select date_trunc('day', b.order_date)::date as ord_date, sum(amount) as daily_sum
from order_items a
	join orders b on a.order_id = b.order_id
group by date_trunc('day', b.order_date)::date 
)
select ord_date, daily_sum
	, avg(daily_sum) over (order by ord_date 
	                              rows between 1 preceding and 1 following) as ca_3days
from temp_01;

-- N 이동 평균에서 맨 처음 N-1 개의 데이터의 경우 정확히 N이동 평균을 구할 수 없을 때 Null 처리 하기. 
with
temp_01 as (
select date_trunc('day', b.order_date)::date as ord_date, sum(amount) as daily_sum
from order_items a
	join orders b on a.order_id = b.order_id
group by date_trunc('day', b.order_date)::date 
)
select ord_date, daily_sum
	, avg(daily_sum) over (order by ord_date 
	                              rows between 2 preceding and current row) as ma_3days_01
	, case when  row_number() over (order by ord_date) <= 2 then null 
	             else avg(daily_sum) over (order by ord_date 
	                              rows between 2 preceding and current row) 
	             end as ma_3days_02
from temp_01;

-- 또는 아래와 같이 작성
with
temp_01 as (
select date_trunc('day', b.order_date)::date as ord_date, sum(amount) as daily_sum
from order_items a
	join orders b on a.order_id = b.order_id
group by date_trunc('day', b.order_date)::date 
), 
temp_02 as (
select ord_date, daily_sum
	, avg(daily_sum) over (order by ord_date 
	                              rows between 2 preceding and current row) as ma_3days_01
	, row_number() over (order by ord_date) as rn
from temp_01
)
select ord_date, daily_sum
	, ma_3days_01
	, case when rn <= 2 then null 
		   else ma_3days_01 end as ma_3days_02
from temp_02;

-- 연속된 매출 일자에서 매출이 Null일때와 그렇지 않을 때의 Aggregate Analytic 결과 차이. 
with ref_days
as (
	select generate_series('1996-07-04'::date , '1996-07-23'::date, '1 day'::interval)::date as ord_date
), 
temp_01 as (
	select date_trunc('day', b.order_date)::date as ord_date, sum(amount) as daily_sum
	from order_items a
		join orders b on a.order_id = b.order_id
	group by date_trunc('day', b.order_date)::date 
),
temp_02 as (
	select a.ord_date, b.daily_sum as daily_sum
	from ref_days a
		left join temp_01 b on a.ord_date = b.ord_date
)
select ord_date, daily_sum
	, avg(daily_sum) over (order by ord_date rows between 2 preceding and current row) as ma_3days
from temp_02;

/************************************************
range와 rows 적용 시 유의 사항
 *************************************************/
-- range와 rows의 차이: order by 시 동일 row 처리 차이 - 1
select empno, deptno, sal
	, avg(sal) over (partition by deptno order by sal) as avg_default
	, avg(sal) over (partition by deptno order by sal range between unbounded preceding and current row) as avg_range
	, avg(sal) over (partition by deptno order by sal rows between unbounded preceding and current row) as avg_rows
	, sum(sal) over (partition by deptno order by sal) as sum_default
	, sum(sal) over (partition by deptno order by sal rows between unbounded preceding and current row) as sum_rows
from hr.emp;

-- range와 rows의 차이: order by 시 동일 row 처리 차이 - 2
select empno, deptno, sal, date_trunc('month', hiredate)::date as hiremonth
	, avg(sal) over (partition by deptno order by date_trunc('month', hiredate)) as avg_default
	, avg(sal) over (partition by deptno order by date_trunc('month', hiredate) range between unbounded preceding and current row) as avg_range
	, avg(sal) over (partition by deptno order by date_trunc('month', hiredate) rows between unbounded preceding and current row) as avg_rows
	, sum(sal) over (partition by deptno order by date_trunc('month', hiredate)) as sum_default
	, sum(sal) over (partition by deptno order by date_trunc('month', hiredate) rows between unbounded preceding and current row) as sum_rows
from hr.emp;

