/************************************
   조인 실습 - Outer 조인. 
*************************************/	

-- 주문이 단 한번도 없는 고객 정보 구하기. 
select a.*, b.*
from NW.customers a left outer join nw.orders b
on a.customer_id = 	b.customer_id 
where b.order_id is null 


-- 부서정보와 부서에 소속된 직원명 정보 구하기. 부서가 직원을 가지고 있지 않더라도 부서정보는 표시되어야 함. 
select a.dname,b.ename,b.empno 
from hr.dept a 
left outer join hr.emp b 
on a.deptno = b.deptno 

-- Madrid에 살고 있는 고객이 주문한 주문 정보를 구할것.
-- 고객명, 주문id, 주문일자, 주문접수 직원명, 배송업체명을 구하되, 
1-- 만일 고객이 주문을 한번도 하지 않은 경우라도 고객정보는 빠지면 안됨. 이경우 주문 정보가 없으면 주문id를 0으로 나머지는 Null로 구할것. 

select a.customer_id, a.contact_name,coalesce(b.order_id, 0) as order_id,
c.first_name ||' '||c.last_name as employee_name, d.company_name as shipper_name 
from nw.customers a
	left join nw.orders b on a.customer_id = b.customer_id 
	left join nw.employees c on b.employee_id = c.employee_id 
	left join nw.shippers d on b.ship_via  = d.shipper_id 
where a.city = 'Madrid';


-- 만일 아래와 같이 중간에 연결되는 집합을 명확히 left outer join 표시하지 않으면 원하는 집합을 가져 올 수 없음.  


-- orders_items에 주문번호(order_id)가 없는 order_id를 가진 orders 데이터 찾기 
select *
from nw.orders a
	left join nw.order_items b on a.order_id =b.order_id 
where b.order_id is null;

-- orders 테이블에 없는 order_id가 있는 order_items 데이터 찾기. 



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
	
with
temp_01 as ( 
select * from hr.emp where deptno =30
),
temp_02 as (
select * from hr.dept where deptno = 30
)
select a.* , b.dname, b.loc 
from temp_01 a 
join temp_02 b on a.deptno = b.deptno


