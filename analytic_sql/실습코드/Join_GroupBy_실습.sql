/************************************
   조인 실습 - 1
*************************************/

-- 직원 정보와 직원이 속한 부서명을 가져오기
select a.*, b.dname 
from hr.emp a
	join hr.dept b on a.deptno = b.deptno;

-- job이 SALESMAN인 직원정보와 직원이 속한 부서명을 가져오기. 
select a.*, b.dname 
from hr.emp a
	join hr.dept b on a.deptno = b.deptno
where job = 'SALESMAN';
	
-- 부서명 SALES와 RESEARCH의 소속 직원들의 부서명, 직원번호, 직원명, JOB 그리고 과거 급여 정보 추출 
select a.dname, b.empno, b.ename, b.job, c.fromdate, c.todate, c.sal 
from hr.dept a
	join hr.emp b on a.deptno = b.deptno
	join hr.emp_salary_hist c on b.empno = c.empno
where a.dname in('SALES', 'RESEARCH')
order by a.dname, b.empno, c.fromdate;

-- 부서명 SALES와 RESEARCH의 소속 직원들의 부서명, 직원번호, 직원명, JOB 그리고 과거 급여 정보중 1983년 이전 데이터는 무시하고 데이터 추출 
select a.dname, b.empno, b.ename, b.job, c.fromdate, c.todate, c.sal 
from hr.dept a
	join hr.emp b on a.deptno = b.deptno
	join hr.emp_salary_hist c on b.empno = c.empno
where  a.dname in('SALES', 'RESEARCH')
and fromdate >= to_date('19830101', 'yyyymmdd')
order by a.dname, b.empno, c.fromdate;

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
select a.ename, a.empno, b.deptno, c.dname, b.fromdate, b.todate  
from hr.emp a
	join hr.emp_dept_hist b on a.empno = b.empno
	join hr.dept c on b.deptno = c.deptno
where a.ename = 'SMITH';

/************************************
   조인 실습 - 2
*************************************/

-- 고객명 Antonio Moreno이 1997년에 주문한 주문 정보를 주문 아이디, 주문일자, 배송일자, 배송 주소를 고객 주소와 함께 구할것.  
select a.contact_name, a.address, b.order_id, b.order_date, b.shipped_date, b.ship_address
from nw.customers a
	join nw.orders b on a.customer_id = b.customer_id
where a.contact_name = 'Antonio Moreno'
and b.order_date between to_date('19970101', 'yyyymmdd') and to_date('19971231', 'yyyymmdd')
;

-- Berlin에 살고 있는 고객이 주문한 주문 정보를 구할것
-- 고객명, 주문id, 주문일자, 주문접수 직원명, 배송업체명을 구할것. 
select a.customer_id, a.contact_name, b.order_id, b.order_date
	, c.first_name||' '||c.last_name as employee_name, d.company_name as shipper_name  
from nw.customers a
	join nw.orders b on a.customer_id = b.customer_id
	join nw.employees c on b.employee_id = c.employee_id
	join nw.shippers d on b.ship_via = d.shipper_id
where a.city = 'Berlin';

--Beverages 카테고리에 속하는 모든 상품아이디와 상품명, 그리고 이들 상품을 제공하는 supplier 회사명 정보 구할것 
select a.category_id, a.category_name, b.product_id, b.product_name, c.supplier_id, c.company_name 
from nw.categories a
	join nw.products b on a.category_id = b.category_id
	join nw.suppliers c on b.supplier_id = c.supplier_id
where category_name = 'Beverages';


-- 고객명 Antonio Moreno이 1997년에 주문한 주문 상품정보를 고객 주소, 주문 아이디, 주문일자, 배송일자, 배송 주소 및
-- 주문 상품아이디, 주문 상품명, 주문 상품별 금액, 주문 상품이 속한 카테고리명, supplier명을 구할 것. 
select a.contact_name, a.address, b.order_id, b.order_date, b.shipped_date, b.ship_address
	, c.product_id, d.product_name, c.amount, e.category_name, f.contact_name as supplier_name
from nw.customers a
	join nw.orders b on a.customer_id = b.customer_id
	join nw.order_items c on b.order_id = c.order_id
	join nw.products d on c.product_id = d.product_id
	join nw.categories e on d.category_id = e.category_id
	join nw.suppliers f on d.supplier_id = f.supplier_id
where a.contact_name = 'Antonio Moreno'
and b.order_date between to_date('19970101', 'yyyymmdd') and to_date('19971231', 'yyyymmdd')
;

/************************************
   조인 실습 - Outer 조인. 
*************************************/	

-- 주문이 단 한번도 없는 고객 정보 구하기. 
select *
from nw.customers a
	left join nw.orders b on a.customer_id = b.customer_id
where b.customer_id is null;

-- 부서정보와 부서에 소속된 직원명 정보 구하기. 부서가 직원을 가지고 있지 않더라도 부서정보는 표시되어야 함. 
select a.*, b.empno, b.ename
from hr.dept a
	left join hr.emp b on a.deptno = b.deptno; 

-- Madrid에 살고 있는 고객이 주문한 주문 정보를 구할것.
-- 고객명, 주문id, 주문일자, 주문접수 직원명, 배송업체명을 구하되, 
-- 만일 고객이 주문을 한번도 하지 않은 경우라도 고객정보는 빠지면 안됨. 이경우 주문 정보가 없으면 주문id를 0으로 나머지는 Null로 구할것. 
select a.customer_id, a.contact_name, coalesce(b.order_id, 0) as order_id, b.order_date
	, c.first_name||' '||c.last_name as employee_name, d.company_name as shipper_name  
from nw.customers a
	left join nw.orders b on a.customer_id = b.customer_id
	left join nw.employees c on b.employee_id = c.employee_id
	left join nw.shippers d on b.ship_via = d.shipper_id
where a.city = 'Madrid';

-- 만일 아래와 같이 중간에 연결되는 집합을 명확히 left outer join 표시하지 않으면 원하는 집합을 가져 올 수 없음.  
select a.customer_id, a.contact_name, coalesce(b.order_id, 0) as order_id, b.order_date
	, c.first_name||' '||c.last_name as employee_name, d.company_name as shipper_name  
from nw.customers a
	left join nw.orders b on a.customer_id = b.customer_id
	join nw.employees c on b.employee_id = c.employee_id
	join nw.shippers d on b.ship_via = d.shipper_id
where a.city = 'Madrid';

-- orders_items에 주문번호(order_id)가 없는 order_id를 가진 orders 데이터 찾기 
select *
from nw.orders a
	left join nw.order_items b on a.order_id = b.order_id
where b.order_id is null;

-- orders 테이블에 없는 order_id가 있는 order_items 데이터 찾기. 
select * 
from nw.order_items a 
	left join nw.orders b on a.order_id = b.order_id
where b.order_id is null;


/************************************
   조인 실습 - Full Outer 조인. 
*************************************/	

-- dept는 소속 직원이 없는 경우 존재. 하지만 직원은 소속 부서가 없는 경우가 없음. 
select a.*, b.empno, b.ename
from hr.dept a
	left join hr.emp b on a.deptno = b.deptno; 

-- full outer join 테스트를 위해 소속 부서가 없는 테스트용 데이터 생성. 
drop table if exists hr.emp_test;

create table hr.emp_test
as
select * from hr.emp;

select * from hr.emp_test;

-- 소속 부서를 Null로 update
update hr.emp_test set deptno = null where empno=7934;

select * from hr.emp_test;

-- dept를 기준으로 left outer 조인시에는 소속직원이 없는 부서는 추출 되지만. 소속 부서가 없는 직원은 추출할 수 없음.  
select a.*, b.empno, b.ename
from hr.dept a
	left join hr.emp_test b on a.deptno = b.deptno; 

-- full outer join 하여 양쪽 모두의 집합이 누락되지 않도록 함. 
select a.*, b.empno, b.ename
from hr.dept a
	full outer join hr.emp_test b on a.deptno = b.deptno; 


/************************************
   조인 실습 - Non Equi 조인과 Cross 조인. 
*************************************/
-- 직원정보와 급여등급 정보를 추출. 
select a.*, b.grade as salgrade
from hr.emp a 
	join hr.salgrade b on a.sal between b.losal and b.hisal;


-- 직원 급여의 이력정보를 나타내며, 해당 급여를 가졌던 시점에서의 부서번호도 함께 가져올것. 
select * 
from hr.emp_salary_hist a
	join hr.emp_dept_hist b on a.empno = b.empno and a.fromdate between b.fromdate and b.todate;

-- cross 조인
with
temp_01 as (
select 1 as rnum 
union all
select 2 as rnum
)
select a.*, b.*
from hr.dept a 
	cross join temp_01 b;

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
select b.empno, max(b.ename) as ename, avg(c.sal) as avg_sal --, count(*) as cnt
from hr.dept a
	join hr.emp b on a.deptno = b.deptno
	join hr.emp_salary_hist c on b.empno = c.empno
where  a.dname in('SALES', 'RESEARCH')
group by b.empno
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

select deptno, count(*) as cnt, count(distinct job) from hr.emp_test group by deptno;


/************************************
   Group by 실습 - 03(Group by절에 가공 컬럼 및 case when 적용)
*************************************/
-- emp 테이블에서 입사년도별 평균 급여 구하기.  
select to_char(hiredate, 'yyyy') as hire_year, avg(sal) as avg_sal --, count(*) as cnt
from hr.emp
group by to_char(hiredate, 'yyyy')
order by 1;


-- 1000미만, 1000-1999, 2000-2999와 같이 1000단위 범위내에 sal이 있는 레벨로 group by 하고 해당 건수를 구함. 
select floor(sal/1000)*1000, count(*) from hr.emp
group by floor(sal/1000)*1000;

select *, floor(sal/1000)*1000 as bin_range --, sal/1000, floor(sal/1000)
from hr.emp; 

-- job이 SALESMAN인 경우와 그렇지 않은 경우만 나누어서 평균/최소/최대 급여를 구하기. 
select case when job = 'SALESMAN' then 'SALESMAN'
		      else 'OTHERS' end as job_gubun
	   , avg(sal) as avg_sal, max(sal) as max_sal, min(sal) as min_sal --, count(*) as cnt
from hr.emp
group by case when job = 'SALESMAN' then 'SALESMAN'
		      else 'OTHERS' end ;

/************************************
   Group by 실습 - 04(Group by와 Aggregate 함수의 case when 을 이용한 pivoting)
*************************************/

select job, sum(sal) as sales_sum
from hr.emp a
group by job;


-- deptno로 group by하고 job으로 pivoting 
select sum(case when job = 'SALESMAN' then sal end) as sales_sum
	, sum(case when job = 'MANAGER' then sal end) as manager_sum
	, sum(case when job = 'ANALYST' then sal end) as analyst_sum
	, sum(case when job = 'CLERK' then sal end) as clerk_sum
	, sum(case when job = 'PRESIDENT' then sal end) as president_sum
from emp;


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
from emp
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
	, count(case when job = 'SALESMAN' then 1 else 0 end) as sales_cnt
	, count(case when job = 'MANAGER' then 1 else 0 end) as manager_cnt
	, count(case when job = 'ANALYST' then 1 else 0 end) as analyst_cnt
	, count(case when job = 'CLERK' then 1 else 0 end) as clerk_cnt
	, count(case when job = 'PRESIDENT' then 1 else 0 end) as president_cnt
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
select deptno, job, sum(sal)
from hr.emp
group by rollup(deptno, job)
order by 1, 2;


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