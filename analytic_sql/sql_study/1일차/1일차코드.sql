/************************************
   조인 실습 - 1
*************************************/

-- 직원 정보와 직원이 속한 부서명을 가져오기
SELECT a.dname, b.*
FROM hr.dept a
JOIN hr.emp b ON a.deptno = b.deptno;


-- job이 SALESMAN인 직원정보와 직원이 속한 부서명을 가져오기. 
select  a.*, b.dname
from hr.emp a
	join hr.dept b on a.deptno = b.deptno 
	where a.job = 'SALESMAN' 
	
-- 부서명 SALES와 RESEARCH의 소속 직원들의 부서명, 직원번호, 직원명, JOB 그리고 과거 급여 정보 추출 
select a.dname, b.empno, b.ename , b.job , c.sal 
from hr.dept a
	join hr.emp b on a.deptno = b.deptno 
	join hr.emp_salary_hist c on b.empno = c.empno	
where a.dname in ('SALES', 'RESEARCH')


select * from hr.emp_salary_hist esh 

-- 부서명 SALES와 RESEARCH의 소속 직원들의 부서명, 직원번호, 직원명, JOB 그리고 과거 급여 정보중 1983년 이전 데이터는 무시하고 데이터 추출 
select a.dname, b.empno, b.ename , b.job , c.sal 
from hr.dept a
	join hr.emp b on a.deptno = b.deptno 
	join hr.emp_salary_hist c on b.empno = c.empno	
where a.dname in ('SALES', 'RESEARCH')
and c.fromdate >= to_date('19830101', 'yyyymmdd')
order by 1,2,3, c.fromdate;

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
select a.ename , a.empno, b.deptno, c.dname, b.fromdate, b.todate 
from hr.emp a
	join hr.emp_dept_hist b on a.empno = b.empno 
	join hr.dept c on b.deptno = c.deptno 
where a.ename = 'SMITH'










/************************************
   조인 실습 - 2
*************************************/
select  * from nw.customers c 

select  * from 	nw.orders o 
-- 고객명 Antonio Moreno이 1997년에 주문한 주문 정보를 주문 아이디, 주문일자, 배송일자, 배송 주소를 고객 주소와 함께 구할것.  

SELECT a.contact_name, b.order_id, b.order_date, b.shipped_date, a.address, b.ship_address 
FROM nw.customers a
JOIN nw.orders b ON a.customer_id = b.customer_id
WHERE a.contact_name = 'Antonio Moreno'
  AND b.order_date >= TO_DATE('1997-01-01', 'YYYY-MM-DD')
  AND b.order_date <= TO_DATE('1997-12-31', 'YYYY-MM-DD');


-- Berlin에 살고 있는 고객이 주문한 주문 정보를 구할것
 select * from nw.customers c 
-- 고객명, 주문id, 주문일자, 주문접수 직원명, 배송업체명을 구할것. 
 
 select a.contact_name, b.order_id, b.order_date, c.last_name,c.first_name, d.company_name
 from nw.customers a 
 	join nw.orders b on a.customer_id  = b.customer_id 
    join nw.employees c on b.employee_id = c.employee_id 
    join nw.shippers d on b.ship_via = d.shipper_id 
    where a.city = 'Berlin'


--Beverages 카테고리에 속하는 모든 상품아이디와 상품명, 그리고 이들 상품을 제공하는 supplier 회사명 정보 구할것 
select  b.product_id, b.product_name, c.company_name 
from nw.categories a
	join nw.products b on a.category_id  = b.category_id 
	join nw.suppliers c  on b.supplier_id = c.supplier_id 
	where a.category_name = 'Beverages'
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