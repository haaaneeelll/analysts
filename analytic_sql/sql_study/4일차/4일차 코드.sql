/* 0. 강의 SQL */

-- rank, dense_rank, row_number 사용하기 - 1
select a.empno, ename, job, sal 
	, rank() over(order by sal desc) as rank 
	, dense_rank() over(order by sal desc) as dense_rank
	, row_number() over (order by sal desc) as row_number 
from hr.emp a;

-- rank, dense_rank, row_number 사용하기 - 2
select a.empno, ename, job, deptno, sal 
	, rank() over(partition by deptno order by sal desc) as rank 
	, dense_rank() over(partition by deptno order by sal desc) as dense_rank
	, row_number() over (partition by deptno order by sal desc) as row_number 
from hr.emp a

/* 1. 순위 함수 실습 */

-- 회사내 근무 기간 순위(hiredate) : 공동 순위가 있을 경우 차순위는 밀려서 순위 정함
select 
*, rank() over(order by a.hiredate ) as hire_rank
from hr.emp a ;





-- 부서별로 가장 급여가 높은/낮은 순으로 순위: 공동 순위 시 차순위는 밀리지 않음.
select 
*,dense_rank () over (partition by deptno order by sal desc)  as sal_rank_desc
 ,dense_rank  () over (partition by deptno order by sal ) as sal_rank_asc
from hr.emp e 



-- 부서별 가장 급여가 높은 직원 정보:  공동 순위는 없으며 반드시 고유 순위를 정함.  
select *
from (
select * ,
row_number () over (partition by deptno order by sal desc ) as sal_rn
from hr.emp e 
) a where sal_rn =1;





-- 부서별 급여 top 2 직원 정보: 공동 순위는 없으며 반드시 고유 순위를 정함. 
select *
from (
select * ,
row_number () over (partition by deptno order by sal desc ) as sal_rn
from hr.emp e 
) a where sal_rn <=2;

-- 부서별 가장 급여가 높은 직원과 가장 급여가 낮은 직원 정보. 공동 순위는 없으며 반드시 고유 순위를 정함
select *
	, case when sal_rn_desc =1 then 'top'
		   when sal_rn_asc = 1then 'bottom'
		   else 'middle' end as gubun
from(
select *
, row_number () over (partition by deptno order by sal desc) as sal_rn_desc
, row_number  () over (partition by deptno order by sal ) as sal_rn_asc
from hr.emp e ) a 
where sal_rn_desc = 1 or sal_rn_asc = 1;

-- 부서별 가장 급여가 높은 직원과 가장 급여가 낮은 직원 정보 그리고 두 직원값의 급여차이도 함께 추출. 공동 순위는 없으며 반드시 고유 순위를 정함
with 
temp_01 as 
(select *
	, case when sal_rn_desc =1 then 'top'
		   when sal_rn_asc = 1then 'bottom'
		   else 'middle' end as gubun
from(
select *
, row_number () over (partition by deptno order by sal desc) as sal_rn_desc
, row_number  () over (partition by deptno order by sal ) as sal_rn_asc
from hr.emp e ) a 
where sal_rn_desc = 1 or sal_rn_asc = 1),
temp_02 as (
select deptno, max(sal) as max_sal, min(sal) as min_sal from temp_01 group by deptno
)
select *, max_sal - min_sal as diff_sal
from temp_01 a 
join temp_02 b on a.deptno = b.deptno



-- 회사내 커미션 높은 순위. rank와 row_number 모두 추출. 
select *
	, rank() over (order by comm desc ) as comm_rank
	, row_number () over (order by comm desc) as comm_rn
from hr.emp e 
/* 2. 순위 함수에서 null 처리 실습 */

-- null을 가장 선두 순위로 처리
select a.*
	, rank() over (order by comm desc nulls first ) as comm_rank
	, row_number() over (order by comm desc nulls first) as comm_rnum
from hr.emp a;

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
