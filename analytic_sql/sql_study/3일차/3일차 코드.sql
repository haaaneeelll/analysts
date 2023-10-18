/******************************************************
to_date, to_timestamp 로 문자열을 Date, Timestamp로 변환.
to_char로 Date, Timestamp를 문자열로 변환. 
*******************************************************/

-- 문자열을 formating에 따라 Date, Timestamp로 변환. 
select to_date('2022-01-01', 'yyyy-mm-dd');

select to_timestamp('2022-01-01', 'yyyy-mm-dd');

select to_timestamp('2022-01-01 14:36:52', 'yyyy-mm-dd hh24:mi:ss')

-- Date를 Timestamp로 변환
select to_date('2022-01-01', 'yyyy-mm-dd')::timestamp;

-- Timestamp를 Text로 변환
select to_timestamp('2022-01-01', 'yyyy-mm-dd')::text;

-- Timestamp를 Date로 변환. 
select to_timestamp('2022-01-01 14:36:52', 'yyyy-mm-dd hh24:mi:ss')::date


-- to_date, to_timestamp, to_char 실습-1
with
temp_01 as (
select a.*
	  , to_char(hiredate, 'yyyy-mm-dd') as hiredate_str
from hr.emp a
)
select empno, ename, hiredate, hiredate_str
	, to_date(hiredate_str, 'yyyy-mm-dd') as hiredate_01
	, to_timestamp(hiredate_str, 'yyyy-mm-dd') as hiretime_01
	--, to_timestamp(hiredate_str, 'yyyy-mm-dd hh24:mi:ss') as hiretime_02
	, to_char(hiredate, 'yyyymmdd hh24:mi:ss') as hiredate_str_01
	, to_char(hiredate, 'month dd yyyy') as hiredate_str_02
	, to_char(hiredate, 'MONTH dd yyyy') as hiredate_str_03
	, to_char(hiredate, 'yyyy month') as hiredate_str_04
	-- w 는 해당 달의 week, d는 일요일(1) 부터 토요일(7)
	, to_char(hiredate, 'MONTH w d') as hiredate_str_05
	-- day는 요일을 문자열로 나타냄. 
	, to_char(hiredate, 'Month, Day') as hiredate_str_06
from temp_01;

-- to_date, to_timestamp, to_char 실습-2 
with
temp_01 as (
select a.*
	  , to_char(hiredate, 'yyyy-mm-dd') as hire_date_str
	  , hiredate::timestamp as hiretime
from hr.emp a
)
select empno, ename, hiredate, hire_date_str, hiretime
	, to_char(hiretime, 'yyyy/mm/dd hh24:mi:ss') as hiretime_01
	, to_char(hiretime, 'yyyy/mm/dd PM hh12:mi:ss') as hiretime_02
	, to_timestamp('2022-03-04 22:10:15', 'yyyy-mm-dd hh24:mi:ss') as timestamp_01
	, to_char(to_timestamp('2022-03-04 22:10:15', 'yyyy-mm-dd hh24:mi:ss'), 'yyyy/mm/dd AM hh12:mi:ss') as timestr_01
from temp_01;  


/********************************************************************
extract와 date_part를 이용하여 Date/Timestamp에서 년,월,일/시간,분,초 추출
*********************************************************************/

-- extract와 date_part를 이용하여 년, 월, 일 추출
select a.* 
	, extract(year from hiredate) as year
	, extract(month from hiredate) as month
	, extract(day from hiredate) as day
from hr.emp a;

select a.*
	, date_part('year', hiredate) as year
	, date_part('month', hiredate) as month
	, date_part('day', hiredate) as day 
from hr.emp a;

-- extract와 date_part를 이용하여 시간, 분, 초 추출. 
select date_part('hour', '2022-02-03 13:04:10'::timestamp) as hour
	, date_part('minute', '2022-02-03 13:04:10'::timestamp) as minute
	, date_part('second', '2022-02-03 13:04:10'::timestamp) as second
;

select extract(hour from '2022-02-03 13:04:10'::timestamp) as hour
	, extract(minute from '2022-02-03 13:04:10'::timestamp) as minute
	, extract(second from '2022-02-03 13:04:10'::timestamp) as second


/******************************************************
날짜와 시간 연산. interval의 활용. 
*******************************************************/

-- 날짜 연산 
-- Date 타입에 숫자값을 더하거나/빼면 숫자값에 해당하는 일자를 더해거나/빼서 날짜 계산. 
select to_date('2022-01-01', 'yyyy-mm-dd') +  2 as date_01;

-- Date 타입에 곱하기나 나누기는 할 수 없음. 
select to_date('2022-01-01', 'yyyy-mm-dd') * 10 as date_01;

-- Timestamp 연산. +7을 하면 아래는 오류를 발생. 
select to_timestamp('2022-01-01 14:36:52', 'yyyy-mm-dd hh24:mi:ss') + 7;

-- Timestamp는 interval 타입을 이용하여 연산 수행. 
select to_timestamp('2022-01-01 14:36:52', 'yyyy-mm-dd hh24:mi:ss') + interval '7 hour' as timestamp_01;

select to_timestamp('2022-01-01 14:36:52', 'yyyy-mm-dd hh24:mi:ss') + interval '2 days' as timestamp_01;

select to_timestamp('2022-01-01 14:36:52', 'yyyy-mm-dd hh24:mi:ss') + interval '2 days 7 hours 30 minutes' as timestamp_01;

-- Date 타입에 interval을 더하면 Timestamp로 변환됨. 
select to_date('2022-01-01', 'yyyy-mm-dd') + interval '2 days' as date_01;

-- interval '2 days'와 같이 ' '내에는 days나 day를 혼용해도 되지만 interval '2' day만 허용. 
select to_date('2022-01-01', 'yyyy-mm-dd') + interval '2' day as date_01;

-- 날짜 간의 차이 구하기. 차이값은 정수형.  
select to_date('2022-01-03', 'yyyy-mm-dd') - to_date('2022-01-01', 'yyyy-mm-dd') as interval_01
	, pg_typeof(to_date('2022-01-03', 'yyyy-mm-dd') - to_date('2022-01-01', 'yyyy-mm-dd')) as type ;

-- Timestamp간의 차이 구하기. 차이값은 interval 
select to_timestamp('2022-01-01 14:36:52', 'yyyy-mm-dd hh24:mi:ss') 
     - to_timestamp('2022-01-01 12:36:52', 'yyyy-mm-dd hh24:mi:ss') as time_01
     , pg_typeof(to_timestamp('2022-01-01 08:36:52', 'yyyy-mm-dd hh24:mi:ss') 
     - to_timestamp('2022-01-01 12:36:52', 'yyyy-mm-dd hh24:mi:ss')) as type
;

-- date + date는 허용하지 않음. 
select to_date('2022-01-03', 'yyyy-mm-dd') +  to_date('2022-01-01', 'yyyy-mm-dd')

-- now(), current_timestamp, current_date, current_time 
-- interval을 년, 월, 일로 표시하기. justify_interval와 age 사용 차이
with 
temp_01 as (
select empno, ename, hiredate, now(), current_timestamp, current_date, current_time
	, date_trunc('second', now()) as now_trunc
	, now() - hiredate as 근속기간
from hr.emp
)
select *
	, date_part('year', 근속기간)
	, justify_interval(근속기간)
	, age(hiredate)
	, date_part('year', justify_interval(근속기간))||'년 '||date_part('month', justify_interval(근속기간))||'월' as 근속년월
	, date_part('year', age(hiredate))||'년 '||date_part('month', age(hiredate))||'월' as 근속년월_01
from temp_01;




/******************************************************
date_trunc 함수를 이용하여 년/월/일/시간/분/초 단위 절삭 
*******************************************************/

select trunc(99.9999, 2);

--date_trunc는 인자로 들어온 기준으로 주어진 날짜를 절삭(?),
select date_trunc('day', '2022-03-03 14:05:32'::timestamp) 

-- date타입을 date_trunc해도 반환값은 timestamp타입임. 
select date_trunc('day', to_date('2022-03-03', 'yyyy-mm-dd')) as date_01;

-- 만약 date 타입을 그대로 유지하려면 ::date로 명시적 형변환 
select date_trunc('day', '2022-03-03'::date)::date as date_01

-- 월, 년으로 절단. 
select date_trunc('month', '2022-03-03'::date)::date as date_01;

-- week의 시작 날짜 구하기. 월요일 기준.
select date_trunc('week', '2022-03-03'::date)::date as date_01;

-- week의 마지막 날짜 구하기. 월요일 기준(일요일이 마지막 날짜)
select (date_trunc('week', '2022-03-03'::date) + interval '6 days')::date as date_01;

-- week의 시작 날짜 구하기. 일요일 기준.
select date_trunc('week', '2022-03-03'::date)::date -1 as date_01;

-- week의 마지막 날짜 구하기. 일요일 기준(토요일이 마지막 날짜)
select (date_trunc('week', '2022-03-03'::date)::date - 1 + interval '6 days')::date as date_01;

-- month의 마지막 날짜 
select (date_trunc('month', '2022-03-03'::date) + interval '1 month' - interval '1 day')::date;

-- 시분초도 절삭 가능. 
select date_trunc('hour', now());

--date_trunc는 년, 월, 일 단위로 Group by 적용 시 잘 사용됨.
drop table if exists hr.emp_test;

create table hr.emp_test
as
select a.*, hiredate + current_time
from hr.emp a;

select * from hr.emp_test;

-- 입사월로 group by
select date_trunc('month', hiredate) as hire_month, count(*)
from hr.emp_test
group by date_trunc('month', hiredate);

-- 시분초가 포함된 입사일일 경우 시분초를 절삭한 값으로 group by 
select date_trunc('day', hiredate) as hire_day, count(*)
from hr.emp_test
group by date_trunc('day', hiredate);


/************************************
   Group by 실습 - 01 
*************************************/	

-- emp 테이블에서 부서별 최대 급여, 최소 급여, 평균 급여를 구할것. 
select deptno, max(sal) as max_sal, min(sal) as min_sal, round(avg(sal), 2) as avg_sal
from hr.emp
group by deptno
;

-- emp 테이블에서 부서별 최대 급여, 최소 급여, 평균 급여를 구하되 평균 급여가 2000 이상인 경우만 추출. 
select deptno, max(sal) as max_sal, min(sal) as min_sal, round(avg(sal), 2) as avg_sal
from hr.emp
group by deptno
having avg(sal) >= 2000
;

-- emp 테이블에서 부서별 최대 급여, 최소 급여, 평균 급여를 구하되 평균 급여가 2000 이상인 경우만 추출(with 절을 이용)
with
temp_01 as (
select deptno, max(sal) as max_sal, min(sal) as min_sal, round(avg(sal), 2) as avg_sal
from hr.emp
group by deptno
)


select * from temp_01 where avg_sal >= 2000;


-- 부서명 SALES와 RESEARCH 소속 직원별로 과거부터 현재까지 모든 급여를 취합한 평균 급여
select b.empno, max(ename) as ename, avg(c.sal) as avg_sal
from hr.dept a
join hr.emp b on a.deptno =b.deptno 
join hr.emp_salary_hist c on b.empno = c.empno 
where a.dname  in ('SALES', 'RESEARCH')
group by b.empno 


-- 부서명 SALES와 RESEARCH 소속 직원별로 과거부터 현재까지 모든 급여를 취합한 평균 급여(with 절로 풀기)
with 
temp_01 as 
(
select a.dname, b.empno, b.ename, b.job, c.fromdate, c.todate, c.sal 
from hr.dept a
	join hr.emp b on a.deptno = b.deptno
	join hr.emp_salary_hist c on b.empno = c.empno
where  a.dname in('SALES', 'RESEARCH')
order by a.dname, b.empno, c.fromdate
)
select empno, max(ename) as ename, avg(sal) as avg_sal
from temp_01 
group by empno; 

-- 부서명 SALES와 RESEARCH 부서별 평균 급여를 소속 직원들의 과거부터 현재까지 모든 급여를 취합하여 구할것. 
select a.deptno, max(a.dname) as dname, avg(c.sal) as avg_sal, count(*) as cnt 
from hr.dept a
	join hr.emp b on a.deptno = b.deptno
	join hr.emp_salary_hist c on b.empno = c.empno
where  a.dname in('SALES', 'RESEARCH')
group by a.deptno
order by 1;

-- 부서명 SALES와 RESEARCH 부서별 평균 급여를 소속 직원들의 과거부터 현재까지 모든 급여를 취합하여 구할것(with절로 풀기)
with 
temp_01 as 
(
select a.deptno, a.dname, b.empno, b.ename, b.job, c.fromdate, c.todate, c.sal 
from hr.dept a
	join hr.emp b on a.deptno = b.deptno
	join hr.emp_salary_hist c on b.empno = c.empno
where  a.dname in('SALES', 'RESEARCH')
order by a.dname, b.empno, c.fromdate
)
select deptno, max(dname) as dname, avg(sal) as avg_sal
from temp_01 
group by deptno
order by 1; 

/************************************
   Group by 실습 - 02(집계함수와 count(distinct))
*************************************/
-- 추가적인 테스트 테이블 생성. 
drop table if exists hr.emp_test;

create table hr.emp_test
as
select * from hr.emp;

insert into hr.emp_test
select 8000, 'CHMIN', 'ANALYST', 7839, TO_DATE('19810101', 'YYYYMMDD'), 3000, 1000, 20
;

select * from hr.emp_test;

-- Aggregation은 Null값을 처리하지 않음. 
select deptno, count(*) as cnt
	, sum(comm), max(comm), min(comm), avg(comm)
from hr.emp_test
group by deptno;

select mgr, count(*), sum(comm)
from hr.emp
group by mgr;

-- max, min 함수는 숫자열 뿐만 아니라, 문자열,날짜/시간 타입에도 적용가능. 
select deptno, max(job), min(ename), max(hiredate), min(hiredate) --, sum(ename) --, avg(ename)
from hr.emp
group by deptno;

-- count(distinct 컬럼명)은 지정된 컬럼명으로 중복을 제거한 고유한 건수를 추출
select count(distinct job) from hr.emp_test;

select deptno, count(*) as cnt, count(distinct job) as job from hr.emp_test group by deptno;


/************************************
   Group by 실습 - 03(Group by절에 가공 컬럼 및 case when 적용)
*************************************/
-- emp 테이블에서 입사년도별 평균 급여 구하기.  
select deptno, count(*)
from hr.emp 
group by deptno;

select *, to_char(hiredate, 'yyyy') as hireyear
from hr.emp 

select to_char(hiredate, 'yyyy-mm') as hireyear, count(*)
from hr.emp a
group by to_char(hiredate, 'yyyy-mm')  
order by 1;

select to_char(hiredate, 'yyyy') as hireyear, avg(sal)
from hr.emp a
group by to_char(hiredate, 'yyyy')  


-- 1000미만, 1000-1999, 2000-2999와 같이 1000단위 범위내에 sal이 있는 레벨로 group by 하고 해당 건수를 구함. 
select floor(sal/1000)*1000, count(*) from hr.emp
group by floor(sal/1000)*1000;

select *, floor(sal/1000)*1000 as bin_range --, sal/1000, floor(sal/1000)
from hr.emp; 

-- job이 SALESMAN인 경우와 그렇지 않은 경우만 나누어서 평균/최소/최대 급여를 구하기. 
select *, case when job = 'SALESMAN' then sal end as sales_sal
	, case when job = 'MANAGER' then sal end as manager_sal
from hr.emp

---
select case when job = 'SALESMAN' then 'SALESMAN' else 'OTHERS' end, avg(sal), min(sal), max(sal), count(*)
from hr.emp a
group by case when job = 'SALESMAN' then 'SALESMAN'
		else 'OTHERS' end


		
/************************************
   Group by 실습 - 04(Group by와 Aggregate 함수의 case when 을 이용한 pivoting)
*************************************/

select job, sum(sal) as sales_sum
from hr.emp a
group by job;


-- deptno로 group by하고 job으로 pivoting 
select 
	sum(case when job = 'SALESMAN' then sal end) as sales_sum
	, sum(case when job = 'MANAGER' then sal end) as manager_sum
	, sum(case when job = 'ANALYST' then sal end) as analyst_sum
	, sum(case when job = 'CLERK' then sal end) as clerk_sum
	, sum(case when job = 'PRESIDENT' then sal end) as president_sum
from hr.emp;

-- deptno + job 별로 group by 		     
select deptno, job, sum(sal) as sal_sum
from hr.emp
group by deptno, job;


-- deptno로 group by하고 job으로 pivoting 
select deptno, sum(sal) as sal_sum
	, sum(case when job = 'SALESMAN' then sal end) as sales_sum
	, sum(case when job = 'MANAGER' then sal end) as manager_sum
	, sum(case when job = 'ANALYST' then sal end) as analyst_sum
	, sum(case when job = 'CLERK' then sal end) as clerk_sum
	, sum(case when job = 'PRESIDENT' then sal end) as president_sum
from hr.emp
group by deptno;

-- group by Pivoting시 조건에 따른 건수 계산 유형(count case when then 1 else null end)
select deptno, count(*) as cnt
	, count(case when job = 'SALESMAN' then 1 end) as sales_cnt
	, count(case when job = 'MANAGER' then 1 end) as manager_cnt
	, count(case when job = 'ANALYST' then 1 end) as analyst_cnt
	, count(case when job = 'CLERK' then 1 end) as clerk_cnt
	, count(case when job = 'PRESIDENT' then 1 end) as president_cnt
from hr.emp
group by deptno;

-- group by Pivoting시 조건에 따른 건수 계산 시 잘못된 사례(count case when then 1 else null end)
select deptno, count(*) as cnt
	, count(case when job = 'SALESMAN' then 1 else 0 end) as sales_cnt
	, count(case when job = 'MANAGER' then 1 else 0 end) as manager_cnt
	, count(case when job = 'ANALYST' then 1 else 0 end) as analyst_cnt
	, count(case when job = 'CLERK' then 1 else 0 end) as clerk_cnt
	, count(case when job = 'PRESIDENT' then 1 else 0 end) as president_cnt
from hr.emp
group by deptno;

-- group by Pivoting시 조건에 따른 건수 계산 시 sum()을 이용
select deptno, count(*) as cnt
	, sum(case when job = 'SALESMAN' then 1 else 0 end) as sales_cnt
	, sum(case when job = 'MANAGER' then 1 else 0 end) as manager_cnt
	, sum(case when job = 'ANALYST' then 1 else 0 end) as analyst_cnt
	, sum(case when job = 'CLERK' then 1 else 0 end) as clerk_cnt
	, sum(case when job = 'PRESIDENT' then 1 else 0 end) as president_cnt
from hr.emp
group by deptno;

/************************************
   Group by rollup 
*************************************/

--deptno + job레벨 외에 dept내의 전체 job 레벨(결국 dept레벨), 전체 Aggregation 수행. 
select deptno, job, sum(sal) 
from hr.emp 
group by rollup(deptno, job)
order by 1,2 ;

-- 상품 카테고리 + 상품별 매출합 구하기
select c.category_name, b.product_name, sum(amount) 
from nw.order_items a
	join nw.products b on a.product_id = b.product_id
	join nw.categories c on b.category_id = c.category_id
group by c.category_name, b.product_name
order by 1, 2
;

-- 상품 카테고리 + 상품별 매출합 구하되, 상품 카테고리 별 소계 매출합 및 전체 상품의 매출합을 함께 구하기 
select c.category_name, b.product_name, sum(amount) 
from nw.order_items a
	join nw.products b on a.product_id = b.product_id
	join nw.categories c on b.category_id = c.category_id
group by rollup(c.category_name, b.product_name)
order by 1, 2
;

-- 년+월+일별 매출합 구하기
-- 월 또는 일을 01, 02와 같은 형태로 표시하려면 to_char()함수, 1, 2와 같은 숫자값으로 표시하려면 date_part()함수 사용. 
select to_char(b.order_date, 'yyyy') as year
	, to_char(b.order_date, 'mm') as month
	, to_char(b.order_date, 'dd') as day
	, sum(a.amount) as sum_amount
from nw.order_items a
	join nw.orders b on a.order_id = b.order_id
group by to_char(b.order_date, 'yyyy'), to_char(b.order_date, 'mm'), to_char(b.order_date, 'dd')
order by 1, 2, 3;

-- 년+월+일별 매출합 구하되, 월별 소계 매출합, 년별 매출합, 전체 매출합을 함께 구하기
with 
temp_01 as (
select to_char(b.order_date, 'yyyy') as year
	, to_char(b.order_date, 'mm') as month
	, to_char(b.order_date, 'dd') as day
	, sum(a.amount) as sum_amount
from nw.order_items a
	join nw.orders b on a.order_id = b.order_id
group by rollup(to_char(b.order_date, 'yyyy'), to_char(b.order_date, 'mm'), to_char(b.order_date, 'dd'))
)
select case when year is null then '총매출' else year end as year
	, case when year is null then null
		else case when month is null then '년 총매출' else month end
	  end as month 
	, case when year is null or month is null then null
		else case when day is null then '월 총매출' else day end
	  end as day
	, sum_amount
from temp_01
order by year, month, day
;


/************************************
   Group by cube
*************************************/

-- deptno, job의 가능한 결합으로 Group by 수행. 
select deptno, job, sum(sal)
from hr.emp
group by cube(deptno, job)
order by 1, 2;

-- 상품 카테고리 + 상품별 + 주문처리직원별 매출
select c.category_name, b.product_name, e.last_name||e.first_name as emp_name, sum(amount) 
from nw.order_items a
	join nw.products b on a.product_id = b.product_id
	join nw.categories c on b.category_id = c.category_id
	join nw.orders d on a.order_id = d.order_id
	join nw.employees e on d.employee_id = e.employee_id
group by c.category_name, b.product_name, e.last_name||e.first_name
order by 1, 2, 3
;

--상품 카테고리, 상품별, 주문처리직원별 가능한 결합으로 Group by 수행
select c.category_name, b.product_name, e.last_name||e.first_name as emp_name, sum(amount) 
from nw.order_items a
	join nw.products b on a.product_id = b.product_id
	join nw.categories c on b.category_id = c.category_id
	join nw.orders d on a.order_id = d.order_id
	join nw.employees e on d.employee_id = e.employee_id
group by cube(c.category_name, b.product_name, e.last_name||e.first_name)
order by 1, 2, 3
;
