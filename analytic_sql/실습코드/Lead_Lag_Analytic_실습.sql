--lag() 현재 행보다 이전 행의 데이터를 가져옴. 동일 부서에서 hiredate순으로 이전 ename을 가져옴. 
select empno, deptno, hiredate, ename
	, lag(ename) over (partition by deptno order by hiredate) as prev_ename
from hr.emp;

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