/************************************************
                  서브쿼리 유형 기본
 *************************************************/

-- 평균 급여 이상의 급여를 받는 직원
select * from hr.emp where sal >= (select avg(sal) from hr.emp);

-- 가장 최근 급여 정보
select * from hr.emp_salary_hist a where todate = (select max(todate) from hr.emp_salary_hist x where a.empno = x.empno);


-- 스칼라 서브쿼리
select ename, deptno, 
	(select dname from hr.dept x where x.deptno=a.deptno) as dname
from hr.emp a;

-- 인라인뷰 서브쿼리
select a.deptno, b.dname, a.sum_sal
from
(
	select deptno, sum(sal) as sum_sal 
	from hr.emp 
	group by deptno
) a 
join hr.dept b 
on a.deptno = b.deptno;

/************************************************
                 where 절 서브쿼리 이해
 *************************************************/
-- ok
select a.* from hr.dept a where a.deptno in (select deptno from hr.emp x where x.sal > 1000);

-- 수행 안됨. 
select a.*, x.ename from hr.dept a where a.deptno in (select deptno from hr.emp x where x.sal > 1000 );

--ok
select a.* from hr.dept a where exists (select deptno from hr.emp x where x.deptno=a.deptno and x.sal > 1000)

-- 서브쿼리의 반환값은 무조건 중복이 제거된 unique한 값 - 비상관 서브쿼리
select * from nw.orders a where order_id in (select order_id from nw.order_items where amount > 100);

-- 서브쿼리의 반환값은 메이쿼리의 개별 레코드로 연결된 결과값에서 무조건 중복이 제거된 unique한 값 - 상관 서브쿼리
select * from nw.orders a where exists (select order_id from nw.order_items x where a.order_id = x.order_id and x.amount > 100);


/************************************************
              비상관(non-correlated) 서브쿼리
 *************************************************/

-- in 연산자는 괄호내에 한개 이상의 값을 상수값 또는 서브쿼리 결과 값으로 가질 수 있으며 개별값의 = 조건들의 or 연산을 수행
select * from hr.emp where deptno in (20, 30);

select * from hr.emp where deptno = 20 or deptno=30;

-- 여러개의 중복된 값을 괄호 내에 가질 경우 중복을 제거하고 unique한 값을 가짐. 
select * from hr.dept where deptno in (select deptno from hr.emp where sal < 1300);

-- 단일 컬럼 뿐 아니라 여러컬럼을 가질 수 있음. 
select * from hr.dept where (deptno, loc) in (select deptno, 'DALLAS' from hr.emp where sal < 1300);

-- 고객이 가장 최근에 주문한 주문 정보 추출
select a.order_id , a.customer_id , a.employee_id , a.order_date 
from nw.orders a
where (a.customer_id, a.order_date) in (select customer_id, max(order_date) from nw.orders group by customer_id)

-- 메인쿼리-서브쿼리의 연결 연산자가 단순 비교 연산자일 경우 서브쿼리는 단 한개의 값을 반환해야 함. 
select * from hr.emp where sal <= (select avg(sal) from hr.emp);

-- 메인쿼리-서브쿼리의 연결 연산자가 = 인데 서브쿼리의 반환값이 여러개이므로 수행 안됨
select * from hr.dept where deptno = (select deptno from hr.emp where sal < 1300);

-- 단순 비교 연산자로 서브쿼리를 연결하여도 여러 컬럼 조건을 가질 수 있음.
select *
from nw.orders where (customer_id, order_date) = (select customer_id, max(order_date)
from nw.orders where customer_id = 'VINET' group by customer_id);

select customer_id, max(order_date)
from nw.orders where customer_id = 'VINET' group by customer_id;

 

/************************************************
              상관(correlated) 서브쿼리
 *************************************************/

-- 상관 서브쿼리, 주문에서 상품 금액이 100보다 큰 주문을 한 주문 정보 
select * from nw.orders a 
where exists (select order_id from nw.order_items x where a.order_id = x.order_id and x.amount > 100);

-- 비상관 서브쿼리, 상품 금액이 100보다 큰 주문을 한 주문 정보
select * from nw.orders a where order_id in (select order_id from nw.order_items where amount > 100);


-- 2건 이상 주문을 한 고객 정보
select * from nw.customers a 
where exists (select 1 from nw.orders x where x.customer_id = a.customer_id 
              group by customer_id having count(*) >=2);


-- 1997년 이후에 한건이라도 주문을 한 고객 정보

select * 
from nw.customers a
where exists (select 1 from nw.orders b where a.customer_id = b.customer_id and b.order_date >= to_date('19970101', 'yyyymmdd'));

--1997년 이후에 단 한건도 주문하지 않은 고객 정보
select * from nw.customers a 
where not exists (select 1 from nw.orders x where x.customer_id = a.customer_id
                                        and x.order_date >= to_date('19970101', 'yyyymmdd'));
-- 조인으로 변환
select * 
from nw.customers a
	left join (select customer_id from nw.orders 
	      where order_date >= to_date('19970101', 'yyyymmdd') 
	      group by customer_id
	      ) b on a.customer_id = b.customer_id 
where b.customer_id is null;


-- 직원의 급여이력에서 가장 최근의 급여이력
select * from hr.emp_salary_hist a where todate = (select max(todate) from hr.emp_salary_hist x 
						   where x.empno = a.empno);

-- 아래는 메인쿼리의 개별 레코드 별로 empno 연결조건으로 단 한건이 아닌 여러건을 반환하므로 수행 오류
select * from hr.emp_salary_hist a where todate in (select todate  from hr.emp_salary_hist x
						   where x.empno = a.empno);						  
						  
select * from hr.emp_salary_hist a where exists (select 1 from hr.emp_salary_hist x
						   where x.empno = a.empno);


