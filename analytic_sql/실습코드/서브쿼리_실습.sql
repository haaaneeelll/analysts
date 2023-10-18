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
select * from nw.orders where (customer_id, order_date) in (select customer_id, max(order_date) 
from nw.orders group by customer_id);

-- 메인쿼리-서브쿼리의 연결 연산자가 단순 비교 연산자일 경우 서브쿼리는 단 한개의 값을 반환해야 함. 
select * from hr.emp where sal <= (select avg(sal) from hr.emp);

-- 메인쿼리-서브쿼리의 연결 연산자가 = 인데 서브쿼리의 반환값이 여러개이므로 수행 안됨
select * from hr.dept where deptno = (select deptno from hr.emp where sal < 1300);

-- 단순 비교 연산자로 서브쿼리를 연결하여도 여러 컬럼 조건을 가질 수 있음.
select * from nw.orders where (customer_id, order_date) = (select customer_id, max(order_date)
from nw.orders where customer_id='VINET' group by customer_id);



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
select * from nw.customers a 
where exists (select 1 from nw.orders x where x.customer_id = a.customer_id
                                        and x.order_date >= to_date('19970101', 'yyyymmdd'));

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
select * from hr.emp_salary_hist a where todate = (select todate from hr.emp_salary_hist x
						   where x.empno = a.empno);



/************************************************
         서브쿼리 실습 - 가장 높은 sal을 받는 직원 정보
 *************************************************/

-- 가장 높은 sal을 받는 직원정보
select * from hr.emp where sal = (select max(sal) from hr.emp);

-- 조인
select a.* 
from hr.emp a
	join (select max(sal) sal from hr.emp) b
on a.sal = b.sal;

-- Analytic SQL
select * from
(
select *,
	row_number() over (order by sal desc) as rnum
from hr.emp
) a where rnum = 1;


/************************************************
     서브쿼리 실습 - 부서별로 가장 높은 sal을 받는 직원 정보
 *************************************************/
-- 부서별로 가장 높은 sal을 받는 직원 상세 정보. 비상관 서브쿼리
select * from hr.emp where (deptno, sal) in (select deptno, max(sal) as sal from hr.emp group by deptno) order by empno;

-- 상관서브쿼리 
select * from hr.emp a
where sal = (select max(sal) as sal from hr.emp x 
             where x.deptno = a.deptno);

-- Analytic SQL
select * from
(
select *,
	row_number() over (partition by deptno order by sal desc) as rnum
from hr.emp
) a where rnum = 1 
order by empno;


/************************************************
     서브쿼리 실습 - 직원의 가장 최근 부서 근무이력 조회
 *************************************************/

drop table if exists hr.emp_dept_hist_01;

-- todate가 99991231가 아닌 경우를 한개 레코드로 생성하기 위해 임시 테이블 생성
create table hr.emp_dept_hist_01
as
select * from hr.emp_dept_hist;


update hr.emp_dept_hist_01
set todate=to_date('1983-12-24', 'yyyy-mm-dd') 
where empno = 7934 and todate=to_date('99991231', 'yyyymmdd');

select * from hr.emp_dept_hist_01;

-- 직원의 가장 최근 부서 근무이력 조회. 비상관 서브쿼리
select * from hr.emp_dept_hist_01 a where (empno, todate) in (select empno, max(todate) from hr.emp_dept_hist_01 x
group by empno);

-- 상관 서브쿼리
select * from hr.emp_dept_hist_01 a where todate = (select max(todate) from hr.emp_dept_hist_01 x where x.empno=a.empno);

-- Analytic SQL
select *
from (
select * 
	, row_number() over (partition by empno order by todate desc) as rnum
from hr.emp_dept_hist_01
)a where rnum = 1;


/************************************************
 서브쿼리 실습 - 고객의 첫번째 주문일의 주문정보와 고객 정보를 함께 추출
 *************************************************/

-- 고객의 첫번째 주문일의 order_id, order_date, shipped_date와 함께 고객명(contact_name), 고객거주도시(city) 정보를 함께 추출
select a.order_id, a.order_date, a.shipped_date, b.contact_name, b.city 
from nw.orders a
	join nw.customers b on a.customer_id = b.customer_id
where a.order_date = (select min(order_date) from nw.orders x where x.customer_id = a.customer_id);

-- Analytic SQL
select order_id, order_date, shipped_date, contact_name, city
from
(
select a.order_id, a.order_date, a.shipped_date, b.contact_name, b.city,
	row_number() over (partition by a.customer_id order by a.order_date) as rnum
from nw.orders a
	join nw.customers b on a.customer_id = b.customer_id
)a where rnum = 1;



/************************************************
 서브쿼리 실습 - 고객별 주문 상품 평균 금액보다 더 큰 금액의 주문 상품명, 주문번호, 주문 상품금액을 구하되 고객명과 고객도시명을 함께 추출
 *************************************************/

-- 고객별 주문상품 평균 금액 
select a.customer_id, avg(b.amount) avg_amount from nw.orders a
join nw.order_items b
on a.order_id = b.order_id
group by customer_id;

-- 상관 서브쿼리로 구하기
select a.customer_id, a.contact_name, a.city, b.order_id, c.product_id, c.amount, d.product_name
from nw.customers a
	join nw.orders b on a.customer_id = b.customer_id
	join nw.order_items c on b.order_id = c.order_id
	join nw.products d on c.product_id = d.product_id
where c.amount >= (select avg(y.amount) avg_amount 
					from nw.orders x
						join nw.order_items y on x.order_id = y.order_id
					where x.customer_id =a.customer_id
					group by x.customer_id
					)
order by a.customer_id, amount;
				
-- Analytic SQL로 구하기 				
select customer_id, contact_name, city, order_id, product_id, amount, product_name
from (
	select a.customer_id, a.contact_name, a.city, b.order_id, c.product_id, c.amount, d.product_name
	, avg(amount) over (partition by a.customer_id rows between unbounded preceding and unbounded following) as avg_amount
	from nw.customers a
		join nw.orders b on a.customer_id = b.customer_id
		join nw.order_items c on b.order_id = c.order_id
		join nw.products d on c.product_id = d.product_id
) a 
where a.amount >= a.avg_amount
order by customer_id, amount;

/************************************************
 Null값이 있는 컬럼의 not in과 not exists 차이 실습
 *************************************************/

select * from hr.emp where deptno in (20, 30, null);

select * from hr.emp where deptno = 20 or deptno=30 or deptno = null;


-- 테스트를 위한 임의의 테이블 생성. 
drop table if exists nw.region;

create table nw.region
as
select ship_region as region_name from nw.orders 
group by ship_region 
;

-- 새로운 XX값을 region테이블에 입력. 
insert into nw.region values('XX');

commit;

select * from nw.region;

-- null값이 포함된 컬럼을 서브쿼리로 연결할 시 in과 exists는 모두 동일. 
select a.*
from nw.region a 
where a.region_name in (select ship_region from nw.orders x);

select a.*
from nw.region a 
where exists (select ship_region from nw.orders x where x.ship_region = a.region_name
             );

-- null값이 포함된 컬럼을 서브쿼리로 연결 시 not in과 not exists의 결과는 서로 다름. 
select a.*
from nw.region a 
where a.region_name not in (select ship_region from nw.orders x);

select a.*
from nw.region a 
where not exists (select ship_region from nw.orders x where x.ship_region = a.region_name
                 );
;

-- true
select 1=1;

-- false
select 1=2;

-- null
select null = null;

-- null
select 1=1 and null;

-- null
select 1=1 and (null = null);

-- true
select 1=1 or null;

-- false
select not 1=1;

-- null
select not null;

-- not in을 사용할 경우 null인 값은 서브쿼리내에서 is not null로 미리 제거해야 함. 
select a.*
from nw.region a 
where a.region_name not in (select ship_region from nw.orders x where x.ship_region is not null);

-- not exists의 경우 null 값을 제외하려면 서브쿼리가 아닌 메인쿼리 영역에서 제외
select a.*
from nw.region a 
where not exists (select ship_region from nw.orders x where x.ship_region = a.region_name --and a.region_name is not null
                 );
--and a.region_name is not null


/************************************************
               스칼라 서브쿼리 이해 
 *************************************************/

-- 직원의 부서명을 스칼라 서브쿼리로 추출
select a.*,
	(select dname from hr.dept x where x.deptno=a.deptno) as dname
from hr.emp a;

-- 아래는 수행 오류 발생. 스칼라 서브쿼리는 단 한개의 결과 값만 반환해야 함. 
select a.*
	, (select ename from hr.emp x where x.deptno=a.deptno) as ename
from hr.dept a;

-- 아래는 수행 오류 발생. 스칼라 서브쿼리는 단 한개의 열값만 반환해야 함. 
select a.*,
	(select dname, deptno from hr.dept x where x.deptno=a.deptno) as dname
from hr.emp a;


-- case when 절에서 스칼라 서브쿼리 사용
select a.*,
	(case when a.deptno = 10 then (select dname from hr.dept x where x.deptno=20)
		  else (select dname from hr.dept x where x.deptno=a.deptno)
		  end
	) as dname
from hr.emp a;

-- 스칼라 서브쿼리는 일반 select와 동일하게 사용. group by 적용 무방. 
select a.*,
	(select avg(sal) from hr.emp x where x.deptno = a.deptno) dept_avg_sal
from hr.emp a;

-- 조인으로 변경. 
select a.*, b.avg_sal 
from hr.emp a
	join (select deptno, avg(sal) as avg_sal from hr.emp x group by deptno) b 
	on a.deptno = b.deptno;

/************************************************
               스칼라 서브쿼리 실습 
 *************************************************/

-- 직원 정보와 해당 직원을 관리하는 매니저의 이름 추출
select a.*,
	(select ename from hr.emp x where x.empno=a.mgr) as mgr_name
from hr.emp a;

select a.*, b.ename as mgr_name
from hr.emp a
	left join hr.emp b on a.mgr=b.empno;

-- 주문정보와 ship_country가 France이면 주문 고객명을, 아니면 직원명을 new_name으로 출력 
select a.order_id, a.customer_id, a.employee_id, a.order_date, a.ship_country
	, (select contact_name from nw.customers x where x.customer_id = a.customer_id) as customer_name
	, (select first_name||' '||last_name from nw.employees x where x.employee_id = a.employee_id) as employee_name
	, case when a.ship_country = 'France' then 
	            (select contact_name from nw.customers x where x.customer_id = a.customer_id)
	       else (select first_name||' '||last_name from nw.employees x where x.employee_id = a.employee_id)
	  end as new_name
from nw.orders a;

-- 조인으로 변경. 
select a.order_id, a.customer_id, a.employee_id, a.order_date, a.ship_country
	, b.contact_name, c.first_name||' '||c.last_name
	, case when a.ship_country = 'France' then b.contact_name
		   else c.first_name||' '||c.last_name end as new_name
from nw.orders a
	left join nw.customers b on a.customer_id = b.customer_id
	left join nw.employees c on a.employee_id = c.employee_id
;

-- 고객정보와 고객이 처음 주문한 일자의 주문 일자 추출.
select a.customer_id, a.contact_name
	, (select min(order_date) from nw.orders x where x.customer_id = a.customer_id) as first_order_date
from nw.customers a;

-- 조인으로 변경 
select a.customer_id, a.contact_name, b.last_order_date
from nw.customers a
	left join (select customer_id, min(order_date) as first_order_date from nw.orders x group by customer_id) b
	on a.customer_id = b.customer_id;

-- 고객정보와 고객이 처음 주문한 일자의 주문 일자와 그때의 배송 주소, 배송 일자 추출
select a.customer_id, a.contact_name
	, (select min(order_date) from nw.orders x where x.customer_id = a.customer_id) as first_order_date
	, (select x.ship_address from nw.orders x where x.customer_id=a.customer_id and x.order_date = 
	          (select min(order_date) from nw.orders y where y.customer_id = x.customer_id)
	  ) as first_ship_address
	, (select x.shipped_date from nw.orders x where x.customer_id=a.customer_id and x.order_date = 
	          (select min(order_date) from nw.orders y where y.customer_id = x.customer_id)
      ) as first_shipped_date
from nw.customers a
order by a.customer_id;

-- 조인으로 변경.
select a.customer_id, a.contact_name
	, b.order_date, b.ship_address, b.shipped_date
from nw.customers a
	left join nw.orders b on a.customer_id = b.customer_id
	and b.order_date = (select min(order_date) from nw.orders x 
						  where a.customer_id = x.customer_id
						  )
order by a.customer_id;


-- 고객정보와 고객이 마지막 주문한 일자의 주문 일자와 그때의 배송 주소, 배송 일자 추출
-- 현재 데이터가 고객이 하루에 주문을 두번한 경우가 있음. max(order_date) 시 고객이 하루에 주문을 두번한 일자가 나오고 있음
-- 때문에 반드시 1개의 값만 스칼라 서브쿼리에서 반환하도록 limit 1 추가
select a.customer_id, a.contact_name
	, (select max(order_date) from nw.orders x where x.customer_id = a.customer_id) as last_order_date
	, (select x.ship_address from nw.orders x where x.customer_id=a.customer_id and x.order_date = 
	          (select max(order_date) from nw.orders y where y.customer_id = x.customer_id)
	          limit 1
	  ) as last_ship_address
	, (select x.shipped_date from nw.orders x where x.customer_id=a.customer_id and x.order_date = 
	          (select max(order_date) from nw.orders y where y.customer_id = x.customer_id)
	          limit 1) as last_shipped_date
from nw.customers a
order by a.customer_id;

-- 조인으로 변경
select a.customer_id, a.contact_name
	, b.order_date, b.ship_address, b.shipped_date
	--, row_number() over (partition by a.customer_id order by b.order_date desc) as rnum
from nw.customers a
	left join nw.orders b on a.customer_id = b.customer_id
	and b.order_date = (select max(order_date) from nw.orders x 
						  where a.customer_id = x.customer_id
					   )
	--where a.customer_id = 'ALFKI'
	--limit 1
;

