/* 0. 강의 SQL */

-- order_items 테이블에서 order_id 별 amount 총합까지 표시
select order_id, line_prod_seq, product_id , amount,
sum(amount) over (partition by order_id) as total_sum_by_ord
from nw.order_items;





-- order_items 테이블에서시 order_id별 line_prod_seq순으로  누적 amount 합까지 표시
select order_id, line_prod_seq, product_id , amount
,sum(amount) over (partition by order_id) as total_sum_by_ord
,sum(amount) over (partition by order_id order by line_prod_seq) as cum_sum_by_ord 
from nw.order_items;


-- order_items 테이블에서 order_id별 line_prod_seq순으로  누적 amount 합 - partition 또는 order by 절이 없을 경우 windows. 
select order_id, line_prod_seq, product_id , amount
,sum(amount) over (partition by order_id) as total_sum_by_ord
,sum(amount) over (partition by order_id order by line_prod_seq rows between unbounded preceding and current row) as cum_sum_by_ord
,sum(amount) over () as total_sum
from nw.order_items
where order_id between 10248 and 10250

-- order_items 테이블에서 order_id 별 상품 최대 구매금액, order_id별 상품 누적 최대 구매금액
select order_id, line_prod_seq, product_id , amount,
max(amount) over (partition by order_id order by line_prod_seq) as total_max_by_ord
from nw.order_items;

 



-- order_items 테이블에서 order_id 별 상품 최소 구매금액, order_id별 상품 누적 최소 구매금액
select order_id, line_prod_seq, product_id , amount,
min(amount) over (partition by order_id order by line_prod_seq) as total_min_by_ord
from nw.order_items;

-- order_items 테이블에서 order_id 별 상품 평균 구매금액, order_id별 상품 누적 평균 구매금액
select order_id, line_prod_seq, product_id , amount
,avg(amount) over (partition by order_id) as total_min_by_ord
,avg(amount) over (partition by order_id order by line_prod_seq) as total_min_by_ord
from nw.order_items;


/* 1. aggregation analytic 실습 */ 

-- 직원 정보 및 부서별로 직원 급여의 hiredate순으로 누적 급여합. 
select empno, ename, deptno , sal
, sum(sal) over (partition by deptno) as sal__ord
, sum(sal) over (partition by deptno order by hiredate) as sal_cum_ord
from hr.emp e 




--직원 정보 및 부서별 평균 급여와 개인 급여와의 차이 출력
select empno, ename, deptno, hiredate, sal 
, avg(sal) over (partition by deptno) as avg_sal
, sal - avg(sal) over (partition by deptno) as diff_sal
from hr.emp e 
order by deptno


-- analytic을 사용하지 않고 위와 동일한 결과 출력
with
temp_01 as (
	select deptno, avg(sal) as avg_sal
	from hr.emp group by deptno
)
select empno, ename, a.deptno, hiredate, sal, avg_sal,
sal - avg_sal
from hr.emp a
	join temp_01 b on a.deptno = b.deptno
order by deptno



-- 직원 정보및 부서별 총 급여 대비 개인 급여의 비율 출력(소수점 2자리까지로 비율 출력)
SELECT
    empno,
    ename,
    deptno,
    hiredate,
    sal,
    SUM(sal) OVER (PARTITION BY deptno) AS sum_sal,
    ROUND(sal / SUM(sal) OVER (PARTITION BY deptno), 2) AS ratio_sal
FROM
    hr.emp
ORDER BY
    deptno;




-- 직원 정보 및 부서에서 가장 높은 급여 대비 비율 출력(소수점 2자리까지로 비율 출력)
SELECT
    empno,
    ename,
    deptno,
    hiredate,
    sal,
    max(sal) OVER (PARTITION BY deptno) AS max_sal,
    ROUND(sal / max(sal) OVER (PARTITION BY deptno), 2) AS ratio_sal
FROM
    hr.emp
ORDER BY
    deptno;


-- product_id 총 매출액을 구하고, 전체 매출 대비 개별 상품의 총 매출액 비율을 소수점2자리로 구한 뒤 매출액 비율 내림차순으로 정렬
with
temp_01 as 
(
select product_id, sum(amount) as sum_amount_prod
from nw.order_items 
group by product_id 
) 
select *,
sum(sum_amount_prod) over() as total_sum_amount
, round(sum_amount_prod / sum(sum_amount_prod) over(),4) as amount_ratio
from temp_01

select 
    product_id, 
    sum(amount) as sum_amount_prod,
    sum(sum(amount)) over () as total_sum_amount,
    round(sum(amount) / sum(sum(amount)) over (), 4) as amount_ratio
from nw.order_items 
group by product_id;


select 
    *,
    sum(amount) over (partition by product_id) as total_sum_amount
from nw.order_items 


-- 직원별 개별 상품 매출액, 직원별 가장 높은 상품 매출액을 구하고, 직원별로 가장 높은 매출을 올리는 상품의 매출 금액 대비 개별 상품 매출 비율 구하기

with
temp_01 as (
select a.employee_id , b.product_id , sum(amount) as sum_by_emp_prod
from orders a
 		join order_items b on a.order_id = b.order_id 
 group by a.employee_id, b.product_id
 )
 select * 
,max(sum_by_emp_prod) over(partition by employee_id) as max_amount
,sum_by_emp_prod / max(sum_by_emp_prod) over(partition by employee_id) as ratio_amount
 from temp_01 order by 1,2;



-- 상품별 매출합을 구하되, 상품 카테고리별 매출합의 5% 이상이고, 동일 카테고리에서 상위 3개 매출의 상품 정보 추출. 
-- 1. 상품별 + 상품 카테고리별 총 매출 계산. (상품별 + 상품 카테고리별 총 매출은 결국 상품별 총 매출임)
-- 2. 상품 카테고리별 총 매출 계산 및 동일 카테고리에서 상품별 랭킹 구함
-- 3. 상품 카테고리 매출의 5% 이상인 상품 매출과 매출 기준 top 3 상품 추출.  

with
temp_01 as (
    select 
        a.product_id, 
        a.category_id, 
        sum(amount) as sum_by_prod
    from nw.products a
    join nw.order_items b on a.product_id = b.product_id 
    group by a.product_id, a.category_id
),
temp_02 as (
    select 
        product_id, 
        category_id, 
        sum_by_prod,
        sum(sum_by_prod) over (partition by category_id) as sum_by_cat,
        row_number() over (partition by category_id order by sum_by_prod desc) as rn_cat
    from temp_01
)
select *
from temp_02
where sum_by_prod >= 0.05 * sum_by_cat  -- 5% 이상 매출
   and rn_cat <= 3;  -- 상위 3개 상품
    
	
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
temp_01 as(
	select date_trunc('day', b.order_date)::date as ord_Date , sum(amount) as daily_sum
	from order_items a
		join orders b on a.order_id  = b.order_id 
	group by date_trunc('day', b.order_date)::date
	)
	select  ord_date, daily_sum, avg(daily_sum) over (order by ord_date rows between 2 preceding and current row) ma_3days
from temp_01 order by 1;

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
	, case when row_number () over(order by ord_date) <= 2 then null 
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
	select a.ord_date, coalesce (b.daily_sum,0) as daily_sum
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

