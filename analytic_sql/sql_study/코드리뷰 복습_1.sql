
-- 부서명 SALES와 RESEARCH의 소속 직원들의 부서명, 직원번호, 직원명, JOB 그리고 과거 급여 정보 추출 
select d.dname , e.empno , e.ename , e.job , e.sal 
from hr.emp e 
join hr.dept d 
on e.deptno = d.deptno 
join hr.emp_salary_hist esh 
on esh.empno = e.empno 
where d.dname = 'SALES' or d.dname  = 'RESEARCH'


-- 부서명 SALES와 RESEARCH의 소속 직원들의 부서명, 직원번호, 직원명, JOB 그리고 과거 급여 정보중 1983년 이전 데이터는 무시하고 데이터 추출 
select d.dname , e.empno , e.ename , e.job , esh.sal 
from hr.emp e 
join hr.dept d 
on e.deptno = d.deptno 
join hr.emp_salary_hist esh 
on esh.empno = e.empno 
where d.dname in ('SALES', 'RESEARCH')
  AND esh.fromdate >= TO_DATE('1983-01-01', 'YYYY-MM-DD');



-- 부서명 SALES와 RESEARCH 소속 직원별로 과거부터 현재까지 모든 급여를 취합한 평균 급여
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


-- 직원명 SMITH의 과거 소속 부서 정보를 구할 것. 
select *
from hr.emp a
join hr.emp_dept_hist b on a.empno  = b.empno 
join hr.dept c on c.deptno = a.deptno 
where a.ename = 'SMITH'



-- 고객명 Antonio Moreno이 1997년에 주문한 주문 정보를 주문 아이디, 주문일자, 배송일자, 배송 주소를 고객 주소와 함께 구할것.  
select *
from nw.customers a
join nw.orders b on a.customer_id = b.customer_id 
where a.contact_name  = 'Antonio Moreno' and  b.order_date between  TO_DATE('1997-01-01', 'YYYY-MM-DD') and TO_DATE('1997-12-31', 'YYYY-MM-DD')




-- Berlin에 살고 있는 고객이 주문한 주문 정보를 구할것
-- 고객명, 주문id, 주문일자, 주문접수 직원명, 배송업체명을 구할것. 
 
select a.customer_id , a.contact_name , b.order_id , b.order_date ,
c.first_name ||' '||c.last_name as employee_name, d.company_name as shipper_name
from nw.customers a
join nw.orders b on a.customer_id = b.customer_id 
join nw.employees c on c.employee_id  = b.employee_id 
join nw.shippers d on d.shipper_id =  b.ship_via 
where a.city = 'Berlin'


select * 
from nw.orders o
 -- 고객명 Antonio Moreno이 1997년에 주문한 주문 상품정보를 고객 주소, 주문 아이디, 주문일자, 배송일자, 배송 주소 및
-- 주문 상품아이디, 주문 상품명, 주문 상품별 금액, 주문 상품이 속한 카테고리명, supplier명을 구할 것. 

select a.address , b.order_id , b.order_date , b.shipped_date , a.address , c.product_id, d.product_name, d.unit_price  
, e.category_id, s.contact_name as supplier_name
from nw.customers a
join nw.orders b on a.customer_id = b.customer_id 
join nw.order_items c on c.order_id  = b.order_id 
join nw.products d on d.product_id = c.product_id 
join nw.categories e on e.category_id = d.category_id 
join nw.suppliers s on s.supplier_id = d.supplier_id 
where a.contact_name = 'Antonio Moreno' and b.order_date between to_date('19970101', 'yyyymmdd') and to_date('19971231', 'yyyymmdd')




/************************************
   조인 실습 - Outer 조인. 
*************************************/	

-- 주문이 단 한번도 없는 고객 정보 구하기. 
select * 
from nw.customers a
	left join nw.orders b on a.customer_id  = b.customer_id 
where b.order_date is null
	

-- 부서정보와 부서에 소속된 직원명 정보 구하기. 부서가 직원을 가지고 있지 않더라도 부서정보는 표시되어야 함. 
select a.dname, b.ename
from hr.dept a
	left join hr.emp b on a.deptno = b.deptno 


-- Madrid에 살고 있는 고객이 주문한 주문 정보를 구할것.
-- 고객명, 주문id, 주문일자, 주문접수 직원명, 배송업체명을 구하되, 
-- 만일 고객이 주문을 한번도 하지 않은 경우라도 고객정보는 빠지면 안됨. 이경우 주문 정보가 없으면 주문id를 0으로 나머지는 Null로 구할것. 
select a.contact_name , coalesce(b.order_id,0)  , b.order_date , c.first_name||''||c.last_name, b.ship_name
from nw.customers a
	left join nw.orders b on a.customer_id = b.customer_id 
	left join nw.employees c on c.employee_id = b.employee_id 
	left join nw.shippers d on d.shipper_id = b.ship_via 
where a.city = 'Madrid';



-- 만일 아래와 같이 중간에 연결되는 집합을 명확히 left outer join 표시하지 않으면 원하는 집합을 가져 올 수 없음. 




-- orders_items에 주문번호(order_id)가 없는 order_id를 가진 orders 데이터 찾기 
select *
from nw.orders a
left join nw.order_items b on a.order_id = b.order_id 
where b.order_id is null



-- orders 테이블에 없는 order_id가 있는 order_items 데이터 찾기. 
select * 
from nw.order_items a 
	left join nw.orders b on a.order_id = b.order_id
where b.order_id is null;


/************************************
   조인 실습 - Full Outer 조인. 
*************************************/	

-- dept는 소속 직원이 없는 경우 존재. 하지만 직원은 소속 부서가 없는 경우가 없음. 
select *
from hr.dept a
left join hr.emp b on a.deptno  = b.deptno 

drop table if exists hr.emp_test;
create table hr.emp_test
as
select * from hr.emp;
select * from hr.emp_test;


-- 소속 부서를 Null로 update
drop table if exists hr.emp_test;

create table hr.emp_test
as
select * from hr.emp;

select * from hr.emp_test;



update hr.emp_test set deptno = null where empno=7934;

select * from hr.emp_test;
--
select *
from hr.emp_dept_hist 


-- dept를 기준으로 left outer 조인시에는 소속직원이 없는 부서는 추출 되지만. 소속 부서가 없는 직원은 추출할 수 없음.  
select *
from hr.dept a
left join hr.emp b on a.deptno  = b.deptno 

/************************************
   조인 실습 - Non Equi 조인과 Cross 조인. 
*************************************/
-- 직원정보와 급여등급 정보를 추출. 
select *
from hr.emp a
join hr.salgrade b on a.sal between b.losal and b.hisal 


select *
from hr.emp_salary_hist b


-- 직원 급여의 이력정보를 나타내며, 해당 급여를 가졌던 시점에서의 부서번호도 함께 가져올것. 
select *
from hr.emp_salary_hist  a
join hr.emp_dept_hist b on a.empno  = b.empno and a.fromdate between b.fromdate and b.todate 



-- cross 조인


/************************************
   Group by 실습 - 01 
*************************************/	

-- emp 테이블에서 부서별 최대 급여, 최소 급여, 평균 급여를 구할것. 
select e.deptno , max(sal), min(sal) , avg(sal) 
from hr.emp e 
group by e.deptno 

-- emp 테이블에서 부서별 최대 급여, 최소 급여, 평균 급여를 구하되 평균 급여가 2000 이상인 경우만 추출. 
SELECT a.deptno, MAX(sal), MIN(sal), ROUND(AVG(sal), 2) AS avg_sal
FROM hr.emp a
GROUP BY a.deptno
HAVING AVG(sal) >= 2000;




-- emp 테이블에서 부서별 최대 급여, 최소 급여, 평균 급여를 구하되 평균 급여가 2000 이상인 경우만 추출(with 절을 이용)


with
temp_01 as (
select deptno, max(sal) as max_sal, min(sal) as min_sal, round(avg(sal), 2) as avg_sal
from hr.emp
group by deptno
)
select * from temp_01 where avg_sal >= 2000;

-- 부서명 SALES와 RESEARCH 소속 직원별로 과거부터 현재까지 모든 급여를 취합한 평균 급여
select a.empno , max(a.ename) as ename, avg(c.sal) as avg_sal
from hr.emp a
join hr.dept b on a.deptno = b.deptno 
join hr.emp_salary_hist c on c.empno  = a.empno 
where b.dname  in ('SALES', 'RESEARCH')
group by a.empno 
order by 1;



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

WITH temp_01 AS (
    SELECT a.deptno, b.empno, b.ename, b.job, c.fromdate, c.todate, c.sal 
    FROM hr.dept a
    JOIN hr.emp b ON a.deptno = b.deptno
    JOIN hr.emp_salary_hist c ON b.empno = c.empno
    WHERE a.dname IN ('SALES', 'RESEARCH')
)
SELECT deptno, MAX(ename) AS ename, AVG(sal) AS avg_sal
FROM temp_01 
GROUP BY deptno;



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





-- max, min 함수는 숫자열 뿐만 아니라, 문자열,날짜/시간 타입에도 적용가능. 
select deptno, max(job), min(ename), max(hiredate), min(hiredate) --, sum(ename) --, avg(ename)
from hr.emp
group by deptno;



-- count(distinct 컬럼명)은 지정된 컬럼명으로 중복을 제거한 고유한 건수를 추출
select count(distinct job) from hr.emp_test;


/************************************
   Group by 실습 - 03(Group by절에 가공 컬럼 및 case when 적용)
*************************************/
-- emp 테이블에서 입사년도별 평균 급여 구하기.  
select to_char(a.hiredate, 'yyyy') as hire_year, avg(sal) as avg_sal
from hr.emp a
group by to_char(a.hiredate, 'yyyy')



-- 1000미만, 1000-1999, 2000-2999와 같이 1000단위 범위내에 sal이 있는 레벨로 group by 하고 해당 건수를 구함. 
select floor(sal/1000)*1000, count(*) from hr.emp 
group by floor(sal/1000)* 1000





-- job이 SALESMAN인 경우와 그렇지 않은 경우만 나누어서 평균/최소/최대 급여를 구하기. 
select case when job = 'SALESMAN'  then 'SALESMAN'
					else 'OTHERS' end as job_gubun
					, avg(sal), min(sal), max(sal)
from hr.emp a
group by case when job = 'SALESMAN'  then 'SALESMAN'
					else 'OTHERS' end 



/************************************
   Group by 실습 - 04(Group by와 Aggregate 함수의 case when 을 이용한 pivoting)
*************************************/


-- deptno로 group by하고 job으로 pivoting 
select sum(case when job = 'SALESMAN' then sal end) as sales_sum
	, sum(case when job = 'MANAGER' then sal end) as manager_sum
	, sum(case when job = 'ANALYST' then sal end) as analyst_sum
	, sum(case when job = 'CLERK' then sal end) as clerk_sum
	, sum(case when job = 'PRESIDENT' then sal end) as president_sum
from emp;



-- deptno + job 별로 group by 		
select a.deptno , a.job, sum(sal) as sal_sum 
from hr.emp a
group by a.deptno , a.job 

-- deptno로 group by하고 job으로 pivoting 
select deptno , sum(sal) as sum_sal
	, sum(case when job = 'SALESMAN' then sal end) as sales_sum
	, sum(case when job = 'MANAGER' then sal end) as manager_sum
	, sum(case when job = 'ANALYST' then sal end) as analyst_sum
	, sum(case when job = 'CLERK' then sal end ) as clerk_sum
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
from emp
group by deptno;







-- group by Pivoting시 조건에 따른 건수 계산 시 잘못된 사례(count case when then 1 else null end)
select deptno, count(*) as cnt
	, count(case when job = 'SALESMAN' then 1 else null end) as sales_cnt
	, count(case when job = 'MANAGER' then 1 else null end) as manager_cnt
	, count(case when job = 'ANALYST' then 1 else null end) as analyst_cnt
	, count(case when job = 'CLERK' then 1 else null end) as clerk_cnt
	, count(case when job = 'PRESIDENT' then 1 else null end) as president_cnt
from emp
group by deptno;



-- group by Pivoting시 조건에 따른 건수 계산 시 sum()을 이용
select deptno, count(*) as cnt
	, sum(case when job = 'SALESMAN' then 1 else 0 end) as sales_cnt
	, sum(case when job = 'MANAGER' then 1 else 0 end) as manager_cnt
	, sum(case when job = 'ANALYST' then 1 else 0 end) as analyst_cnt
	, sum(case when job = 'CLERK' then 1 else 0 end) as clerk_cnt
	, sum(case when job = 'PRESIDENT' then 1 else 0 end) as president_cnt
from emp
group by deptno;


/************************************
   Group by rollup 
*************************************/

--deptno + job레벨 외에 dept내의 전체 job 레벨(결국 dept레벨), 전체 Aggregation 수행. 
select a.deptno , a.job , sum(sal)
from hr.emp a
group by rollup(a.deptno , a.job )
order by 1,2; 



-- 상품 카테고리 + 상품별 매출합 구하기
select c.category_name , b.product_name , avg(amount)
from nw.order_items a
	join nw.products b on a.product_id = b.product_id 
	join nw.categories c on c.category_id  = b.category_id 
group by c.category_name, b.product_name 





-- 상품 카테고리 + 상품별 매출합 구하되, 상품 카테고리 별 소계 매출합 및 전체 상품의 매출합을 함께 구하기 
select c.category_name , b.product_name , avg(amount)
from nw.order_items a
	join nw.products b on a.product_id = b.product_id 
	join nw.categories c on c.category_id  = b.category_id 
group by rollup (c.category_name, b.product_name )
order by 1,2;



select * 
from nw.order_items oi 

-- 년+월+일별 매출합 구하기
-- 월 또는 일을 01, 02와 같은 형태로 표시하려면 to_char()함수, 1, 2와 같은 숫자값으로 표시하려면 date_part()함수 사용. 
select to_char(b.order_date, 'yyyy') as year
	, to_char(b.order_date, 'mm') as month
	, to_char(b.order_date, 'dd') as day
	, sum(a.amount)
from nw.order_items a
join nw.orders b on a.order_id  = b.order_id 
group by to_char(b.order_date, 'yyyy') 
	, to_char(b.order_date, 'mm') 
	, to_char(b.order_date, 'dd')










-- 년+월+일별 매출합 구하되, 월별 소계 매출합, 년별 매출합, 전체 매출합을 함께 구하기
select to_char(b.order_date, 'yyyy') as year
	, to_char(b.order_date, 'mm') as month
	, to_char(b.order_date, 'dd') as day
	, sum(a.amount)
from nw.order_items a
join nw.orders b on a.order_id  = b.order_id 
group by rollup (to_char(b.order_date, 'yyyy') 
	, to_char(b.order_date, 'mm') 
	, to_char(b.order_date, 'dd'))
	order by 1,2,3
	
	
	
/************************************
   Group by cube
*************************************/

-- deptno, job의 가능한 결합으로 Group by 수행. 
select deptno, job, sum(sal)
from hr.emp
group by cube(deptno, job)
order by 1, 2;

-- 상품 카테고리 + 상품별 + 주문처리직원별 매출


--상품 카테고리, 상품별, 주문처리직원별 가능한 결합으로 Group by 수행

/* 0. 강의 SQL */

-- rank, dense_rank, row_number 사용하기 - 1
select *,
rank() over(order by sal) as rank_sal
, dense_rank() over(order by sal) as dense_rank 
, row_number() over(order by sal) as row_number
from hr.emp a


-- rank, dense_rank, row_number 사용하기 - 2
select a.empno, ename, job, deptno, sal 
	, rank() over(partition by deptno order by sal desc) as rank 
	, dense_rank() over(partition by deptno order by sal desc) as dense_rank
	, row_number() over (partition by deptno order by sal desc) as row_number 
from hr.emp a

/* 1. 순위 함수 실습 */

-- 회사내 근무 기간 순위(hiredate) : 공동 순위가 있을 경우 차순위는 밀려서 순위 정함
select a.*,
 rank() over (order by hiredate) as hire_rank
from hr.emp a




-- 부서별로 가장 급여가 높은/낮은 순으로 순위: 공동 순위 시 차순위는 밀리지 않음.
select a.*,
 dense_rank() over (partition  by deptno order by sal desc) as hire_rank
from hr.emp abb 

-- 부서별 가장 급여가 높은 직원 정보:  공동 순위는 없으며 반드시 고유 순위를 정함.  
with
temp_01 as (
select a.*
, row_number() over (partition by deptno order by sal desc) as sal_dept
from hr.emp a)
select *
from temp_01
where sal_dept = 1;

-- 부서별 급여 top 2 직원 정보: 공동 순위는 없으며 반드시 고유 순위를 정함. 
select *
from (select a.*, row_number() over (partition by deptno order by sal desc) as sal_rn
from hr.emp a) a where sal_rn <= 2;







-- 부서별 가장 급여가 높은 직원과 가장 급여가 낮은 직원 정보. 공동 순위는 없으며 반드시 고유 순위를 정함
with
temp_01 as (
select a.*,
row_number() over(partition by deptno order by sal desc) as rn_sal_desc
,row_number() over(partition by deptno order by sal asc) as rn_sal_asc
from hr.emp a) 
select *, case when rn_sal_desc =1 then 'top'
when rn_sal_asc = 1 then 'bottom' else 'middle' end as gubun
from temp_01
where rn_sal_desc =1 or rn_sal_asc = 1






-- 부서별 가장 급여가 높은 직원과 가장 급여가 낮은 직원 정보 그리고 두 직원값의 급여차이도 함께 추출. 공동 순위는 없으며 반드시 고유 순위를 정함
with
temp_01 as (
select a.*
, case when rn_sal_desc = 1 then 'top'
		when rn_sal_asc = 1 then 'bottom'
		else 'middle' end as gubun
from (
select a.*
,row_number() over(partition by deptno order by sal desc) as rn_sal_desc
,row_number() over(partition by deptno order by sal asc) as rn_sal_asc
from hr.emp a) a where rn_sal_desc = 1 or rn_sal_asc = 1
),
temp_02 as (
 	select deptno,
 	max(sal) as max_sal, min(sal) as min_sal
 	from temp_01 group by deptno
 )
 select a.*, b.max_sal - b.min_sal as diff_sal
 from temp_01 a
 	join temp_02 b on a.deptno = b.deptno
 order by a.deptno, a.sal desc;




-- 회사내 커미션 높은 순위. rank와 row_number 모두 추출. 
select a.*
, rank() over(order by comm) as rank_comm
, row_number() over(order by comm) as rn_comm
from hr.emp a;


/* 2. 순위 함수에서 null 처리 실습 */

-- null을 가장 선두 순위로 처리
select a.*
, rank() over(order by comm desc nulls first) as comm_rank
from hr.emp a


-- null을 가장 마지막 순위로 처리
select a.*
	, rank() over (order by comm desc nulls last ) as comm_rank
	, row_number() over (order by comm desc nulls last) as comm_rnum
from hr.emp a;



-- null을 전처리하여 순위 정함. 
select a.*
	, rank() over (order by COALESCE(comm, 0) desc ) as comm_rank
	, row_number() over (order by COALESCE(comm, 0) desc) as comm_rnum
from hr.emp a;






