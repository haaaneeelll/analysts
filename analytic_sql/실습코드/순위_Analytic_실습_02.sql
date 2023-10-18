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