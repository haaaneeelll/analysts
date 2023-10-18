--lag() 현재 행보다 이전 행의 데이터를 가져옴. 동일 부서에서 hiredate순으로 이전 ename을 가져옴. 
select empno, deptno, hiredate, ename,
lag(ename) over (partition by deptno order by hiredate)
from hr.emp e 

-- lead( ) 현재 행보다 다음 행의 데이터를 가져옴. 동일 부서에서 hiredate순으로 다음 ename을 가져옴. 
select empno, deptno, hiredate, ename, 
	lead(ename) over (partition by deptno order by hiredate) as next_ename
from hr.emp;

-- lag() over (order by desc)는 lead() over (order by asc)와 동일하게 동작하므로 혼돈을 방지하기 위해 order by 는 asc로 통일하는것이 좋음. 
select empno, deptno, hiredate, ename
	, lag(ename) over (partition by deptno order by hiredate desc) as lag_desc_ename
	, lead(ename) over (partition by deptno order by hiredate) as lead_desc_ename
from hr.emp; 

-- lag 적용 시 windows에서 가져올 값이 없을 경우 default 값을 설정할 수 있음. 이 경우 반드시 offset을 정해 줘야함. 
select empno, deptno, hiredate, ename
	, lag(ename, 1, 'No Previous') over (partition by deptno order by hiredate) as prev_ename 
from hr.emp;

-- Null 처리를 아래와 같이 수행할 수도 있음. 
select empno, deptno, hiredate, ename
	, coalesce(lag(ename) over (partition by deptno order by hiredate), 'No Previous') as prev_ename 
from hr.emp;

-- 현재일과 1일전 매출데이터와 그 차이를 출력. 1일전 매출 데이터가 없을 경우 현재일 매출 데이터를 출력하고, 차이는 0
with
temp_01 as (
select date_trunc('day', b.order_date)::date as ord_date, sum(amount) as daily_sum
from nw.order_items a
	join nw.orders b on a.order_id = b.order_id
group by date_trunc('day', b.order_date)::date 
)
select ord_date, daily_sum
	, coalesce(lag(daily_sum) over (order by ord_date), daily_sum) as prev_daily_sum
	, daily_sum - coalesce(lag(daily_sum) over (order by ord_date), daily_sum) as diff_prev
from temp_01;

-- 부서별로 가장 hiredate가 오래된 사람의 sal 가져오기.
select *, 
first_value(sal) over(partition by deptno order by hiredate) as first_hiredate_sal
from hr.emp e 

-- 부서별로 가장 hiredate가 최근인 사람의 sal 가져오기. windows절이 rows between unbounded preceding and unbounded following이 되어야 함. 
select empno, ename, deptno, hiredate, sal 
, last_value(sal) over (partition by deptno order by hiredate
						rows between unbounded preceding and unbounded following) as last_hiredate_sal_01
, last_value(sal) over (partition by deptno order by hiredate 
						rows between unbounded preceding and current row) as last_hiredate_sal_02
from emp;

-- last_value() over (order by asc) 대신 first_value() over (order by desc)를 적용 가능. 
select empno, ename, deptno, hiredate, sal 
, last_value(sal) over (partition by deptno order by hiredate rows between unbounded preceding and unbounded following) as last_hiredate_sal
, first_value(sal) over (partition by deptno order by hiredate desc) as last_hiredate_sal
from emp;

-- first_value()와 min() 차이
select empno, ename, deptno, hiredate, sal 
	, first_value(sal) over (partition by deptno order by hiredate) as first_hiredate_sal 
	, min(sal) over (partition by deptno order by hiredate) as min_sal
from emp;


-- 연속된 데이터 흐름에서 값이 Null일 경우 바로 값이 있는 바로 위의 데이터를 가져 오기. 
with ref_days
as (
	select generate_series('1996-07-04'::date , '1996-07-23'::date, '1 day'::interval)::date as ord_date
), 
temp_01 as (
	select date_trunc('day', b.order_date)::date as ord_date, sum(amount) as daily_sum
	from nw.order_items a
		join nw.orders b on a.order_id = b.order_id
	group by date_trunc('day', b.order_date)::date 
),
temp_02 as (
	select a.ord_date, b.daily_sum as daily_sum
	from ref_days a
		left join temp_01 b on a.ord_date = b.ord_date
), 
temp_03 as 
(
select *
, first_value(daily_sum) over (order by ord_date)
, case when daily_sum is null then 0
	else row_number() over () end as rnum
from temp_02
),
temp_04 as (
select *
	, max(lpad(rnum::text, 6, '0')||daily_sum) over (order by ord_date rows between unbounded preceding and current row) as temp_str
from temp_03 order by ord_date
)
select * 
	, substring(temp_str, 7)::float as inherited_daily_sum
from temp_04;

/************************************************
cume_dist, percent_rank, ntile 실습
 *************************************************/

-- cume_dist는 percentile을 파티션내의 건수로 적용하고 0 ~ 1 사이 값으로 변환. 
-- 파티션내의 자신을 포함한 이전 로우수/ 파티션내의 로우 건수로 계산될 수 있음. 
select a.empno, ename, job, sal
	, rank() over(order by sal desc) as rank 
	, cume_dist() over (order by sal desc) as cume_dist
	, cume_dist() over (order by sal desc)*12.0 as xxtile
from hr.emp a;

select * from nw.order_items;

select a.order_id 
	, rank() over(order by amount desc) as rank 
	, cume_dist() over (order by amount desc) as cume_dist
from nw.order_items a;


-- percent_rank는 rank를 0 ~ 1 사이 값으로 정규화 시킴. 
-- (파티션내의 rank() 값 - 1) / (파티션내의 로우 건수 - 1)
select a.empno, ename, job, sal
    , rank() over(order by sal desc) as rank 
	, percent_rank() over (order by sal desc) as percent_rank
	, 1.0 * (rank() over(order by sal desc) -1 )/11 as percent_rank_calc
from hr.emp a;

-- ntile은 지정된 숫자만큼의 분위를 정하여 그룹핑하는데 사용. 
select a.empno, ename, job, sal
	, ntile(5) over (order by sal desc) as ntile
from hr.emp a;


-- 상품 매출 순위 상위 10%의 상품 및 매출액
with 
temp_01 as ( 
	select product_id, sum(amount) as sum_amount
	from nw.orders a 
		join nw.order_items b 
			on a.order_id = b.order_id
	group by product_id
)
select * from (
	select a.product_id, b.product_name, a.sum_amount
		, cume_dist() over (order by sum_amount) as percentile_norm
		, 1.0 * row_number() over (order by sum_amount)/count(*) over () as rnum_norm
	from temp_01 a
		join nw.products b on a.product_id = b.product_id
) a where percentile_norm >= 0.9;

/************************************************
percentile_disc/percentile_cont 실습
 *************************************************/

-- 4분위별 sal 값을 반환. 
select percentile_disc(0.25) within group (order by sal) as qt_1
	, percentile_disc(0.5) within group (order by sal) as qt_2
	, percentile_disc(0.75) within group (order by sal) as qt_3
	, percentile_disc(1.0) within group (order by sal) as qt_4
from hr.emp;  

-- percentile_disc는 cume_dist의 inverse 값을 반환. 
-- percentile_disc는 0 ~ 1 사이의 분위수값을 입력하면 해당 분위수 값 이상인 것 중에서 최소 cume_dist 값을 가지는 값을 반환
with
temp_01 as 
(
	select percentile_disc(0.25) within group (order by sal) as qt_1
	, percentile_disc(0.5) within group (order by sal) as qt_2
	, percentile_disc(0.75) within group (order by sal) as qt_3
	, percentile_disc(1.0) within group (order by sal) as qt_4
from hr.emp
)
select a.empno, ename, sal
	, cume_dist() over (order by sal) as cume_dist
	, b.qt_1, b.qt_2, b.qt_3, b.qt_4
from hr.emp a
	cross join temp_01 b
order by sal;  


-- products 테이블에서 category별 percentile_disc 구하기 
with
temp_01 as 
(
	select a.category_id, max(b.category_name) as category_name 
	, percentile_disc(0.25) within group (order by unit_price) as qt_1
	, percentile_disc(0.5) within group (order by unit_price) as qt_2
	, percentile_disc(0.75) within group (order by unit_price) as qt_3
	, percentile_disc(1.0) within group (order by unit_price) as qt_4
from nw.products a
	join nw.categories b on a.category_id = b.category_id
group by a.category_id
)
select * from temp_01;  

-- percentile_disc와 cume_dist 비교하기 
with
temp_01 as 
(
	select a.category_id, max(b.category_name) as category_name 
	, percentile_disc(0.25) within group (order by unit_price) as qt_1
	, percentile_disc(0.5) within group (order by unit_price) as qt_2
	, percentile_disc(0.75) within group (order by unit_price) as qt_3
	, percentile_disc(1.0) within group (order by unit_price) as qt_4
from nw.products a
	join nw.categories b on a.category_id = b.category_id
group by a.category_id
)
select product_id, product_name, a.category_id, b.category_name
	, unit_price
	, cume_dist() over (partition by a.category_id order by unit_price) as cume_dist_by_cat
	, b.qt_1, b.qt_2, b.qt_3, b.qt_4
from nw.products a 
	join temp_01 b on a.category_id = b.category_id;



--입력 받은 분위수가 특정 로우를 정확하게 지정하지 못하고, 두 로우 사이일때 
--percentile_cont는 보간법을 이용하여 보정하며, percentile_cont는 두 로우에서 작은 값을 반환
select 'cont' as gubun 
	, percentile_cont(0.25) within group (order by sal) as qt_1
	, percentile_cont(0.5) within group (order by sal) as qt_2
	, percentile_cont(0.75) within group (order by sal) as qt_3
	, percentile_cont(1.0) within group (order by sal) as qt_4
from hr.emp
union all
select 'disc' as gubun 
	, percentile_disc(0.25) within group (order by sal) as qt_1
	, percentile_disc(0.5) within group (order by sal) as qt_2
	, percentile_disc(0.75) within group (order by sal) as qt_3
	, percentile_disc(1.0) within group (order by sal) as qt_4
from hr.emp;

-- percentile_cont와 percentile_disc를 cume_dist와 비교. 
with 
temp_01 as ( 
select 'cont' as gubun 
	, percentile_cont(0.25) within group (order by sal) as qt_1
	, percentile_cont(0.5) within group (order by sal) as qt_2
	, percentile_cont(0.75) within group (order by sal) as qt_3
	, percentile_cont(1.0) within group (order by sal) as qt_4
from hr.emp
union all
select 'disc' as gubun 
	, percentile_disc(0.25) within group (order by sal) as qt_1
	, percentile_disc(0.5) within group (order by sal) as qt_2
	, percentile_disc(0.75) within group (order by sal) as qt_3
	, percentile_disc(1.0) within group (order by sal) as qt_4
from hr.emp
)
select a.empno, ename, sal
	, cume_dist() over (order by sal)
	, b.qt_1, b.qt_2, b.qt_3, b.qt_4
from hr.emp a
	cross join temp_01 b
where b.gubun = 'disc'
; 