# Scope
식자재 배송 업체 데이터 분석
목적은 비즈니스 현황과 재구매에 대한 인사이트

## 1. 데이터의 각 테이블이 무엇을 의미하고 어떤 칼럼이 있는지 확인한다.
## 2. 지표추출을 해야하는데 **재구매**의 관한 것이어야 한다.
대략 이렇게 추출가능하다.
1) 전체 주문 건수
2) 구매자 수
3) 상품별 주문 건수
4) 카트에 가장 먼저 넣는 상품 10개
5) 시간별 주문 건수
6)첫 구매 후 다음 구매까지 걸린 평균일수
7) 주문 건당 평균 구매 상품 수(UPT)
8) 인당 평균 주문 건수
9) 재구매율이 가장 높은 상품 10개
10) 부서별 재구매율이 가장 높은 상품 10개

### 1) 전체 주문 건수
distinct를 써서 order_id중복을 없앤다. 3220
### 2) 구매자 수
ditinct를 써서 중복 user_id를 없앤다. 3159
### 3) 상품별 주문 건수
상품명으로 데이터를 그룹핑하고 order_id를 카운트해 집계한다.
문제는 주문번호가 두개의 테이블에 존재한다는 것이다.
조인함수를 사용하여 결합하자.
### 4) 장바구니에 가장 먼저 넣는 상품 10개
```sql
SELECT product_id,
  CASE WHEN add_to_cart_order = 1 THEN 1 ELSE 0 END AS F_1st
FROM INSTACART.ORDER_PRODUCTS__PRIOR
ORDER BY F_1st DESC
LIMIT 10;

```
가장 먼저 담긴 상품은 1로 아닌 상품은 0으로 추출한다.
```sql
SELECT product_id,
sum(CASE WHEN add_to_cart_order = 1 THEN 1 ELSE 0 END) AS F_1st
FROM INSTACART.ORDER_PRODUCTS__PRIOR
group BY 1 DESC
order by 1 desc
```
상품번호로 그룹핑하고 칼럼을 합하면 상품별로 장바구니에 가장 먼저 담긴 건수를 계산할 수 있다.

```sql
SELECT *,
  ROW_NUMBER() OVER (ORDER BY F_1st DESC) AS rnk
FROM (
  SELECT product_id,
    SUM(CASE WHEN add_to_cart_order = 1 THEN 1 ELSE 0 END) AS F_1st
  FROM instacart.order_products__prior
  GROUP BY product_id
) A;

```
데이터에 순서를 매긴다. 1에서 10등까지 뽑아야한다. 
그러나 문제가 있다. rnk는 select문에서 새롭게 생성한 칼럼이기에 where절에서 바로 사용할 수 없다. 위의 쿼리를 서브쿼리로 사용해 조건을 생성해야 한다.
```sql
select *
from
(SELECT *,
  ROW_NUMBER() OVER (ORDER BY F_1st DESC) AS rnk
FROM (
  SELECT product_id,
    SUM(CASE WHEN add_to_cart_order = 1 THEN 1 ELSE 0 END) AS F_1st
  FROM instacart.order_products__prior
  GROUP BY product_id
) A) BASE
where RNK between 1 and 10;
```
쉽죠?

### 5) 시간별 주문 건수
```sql
SELECT order_hour_of_day, COUNT(DISTINCT order_id) AS f
FROM instacart.orders
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;

```

### 6) 첫 구매 후 다음 구매까지 걸린 평균 일수
```sql
SELECT AVG(DAYS_since_prior_order) AS AVG_recency
FROM instacart.orders
WHERE order_number = 2;
```
DAYS_since_prior_order는 이전 주문이 이러진지 며칠 뒤에 구매가 이루어졌는지를 나타내는 값이다. 즉 주문 번호의 order_number가 DAYS_since_prior_order는 첫 구매후 다음 구매까지 걸린 시간이 된다. 이 기간을 평균하면 첫 구매 후 다음 구매까지 걸린 평균 일수를 계산할 수 있다.

데이터의 구조를 정확하게 파악하는게 중요하다.

### 7) 주문 건당 평균 구매 상품 수(upt)
```sql
SELECT COUNT(PRODUCT_ID) / COUNT(DISTINCT ORDER_ID) AS UPT
FROM INSTACART.ORDER_PRODUCTS__PRIOR;
```
> 13.6518

product_id를 카운트해 상품 개수를 계산하고, 이를 주문 건수로 나누어 주문 1건에 평균적으로 몇 개의 상품을 구매하는지 파악할 수 있다.

### 8)인당 평균 주문 건수 
```sql
SELECT COUNT(DISTINCT ORDER_ID)/COUNT(DISTINCT USER_ID) AVG_F
FROM INSTACART.ORDERS;
```
전체 주문 건수를 구매자 수로 나눈다. 

### 9) 재구매율이 가장 높은 구매 10개

재구매율이 가장 높은 상품을 구하려면 어떻게 해야 할까?
```sql
SELECT PRODUCT_ID,
	SUM(CASE WHEN REORDERED = 1 THEN 1 ELSE 0 END)/COUNT(*) RET_RATIO
FROM INSTACART.ORDER_PRODUCTS__PRIOR
GROUP BY 1;
```
Reordered 칼럼을 더해서 전체 주문 수로 나누어 재구매율을 계산한다. 

#### 9-1) 재구매율로 랭크(순위) 열 생성하기
위의 쿼리를 서브쿼리로 사용하여 랭크를 뽑자.
```sql

Select *,
ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) RNK
FROM
(SELECT PRODUCT_ID,
	SUM(CASE WHEN REORDERED = 1 THEN 1 ELSE 0 END)/COUNT(*) RET_RATIO
FROM INSTACART.ORDER_PRODUCTS__PRIOR
GROUP BY 1) A
;
```
### **중요**
위의 SQL 쿼리에서 ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) RNK 부분은 결과 집합에 순위를 부여하는 역할을 합니다. 이 부분을 설명해드리겠습니다.

ROW_NUMBER() 함수는 윈도우 함수 중 하나로, 결과 집합에 순번을 부여합니다. 이 함수는 ORDER BY 절과 함께 사용되며, 정렬된 순서대로 각 행에 번호를 할당합니다.

위의 쿼리에서는 OVER(ORDER BY RET_RATIO DESC)를 사용하여 RET_RATIO 열을 기준으로 내림차순으로 정렬합니다. 그리고 ROW_NUMBER() 함수를 사용하여 각 행에 순번을 부여합니다. 순번은 RNK라는 별칭으로 결과에 표시됩니다.

결과적으로 쿼리는 'INSTACART.ORDER_PRODUCTS__PRIOR' 테이블에서 'REORDERED'가 1인 경우의 제품별 재주문 비율을 계산한 뒤, 그 비율을 기준으로 내림차순으로 정렬하여 각 행에 순번을 할당합니다.

### 9-2) Top10(재구매율)상품 추출
```sql
select *
from
(Select *,
ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) RNK
FROM
(SELECT PRODUCT_ID,
	SUM(CASE WHEN REORDERED = 1 THEN 1 ELSE 0 END)/COUNT(*) RET_RATIO
FROM INSTACART.ORDER_PRODUCTS__PRIOR
GROUP BY 1) A) A
where RNK BETWEEN 1 AND 10; 

```
서브쿼리에 서브쿼리...복잡해보여도 위에서 잘 따라왔다면 어렵지 않다.

## 3. 구매자 분석
구매자와 관련된 분석 진행. 10분위 분석, 고객의 주요 구매 카테고리, 고객 세그먼트를 통해 해당 서비스의 구매자에 대해 더 깊에 이해하고자 한다.

- 10분위 분석을 이용한다.
**10분위 분석이란?**

전체를 10분위로 나누어 각 분위 수에 해당하는 집단의 성질을 나타내는 방법.

1) 10분위 분석
10분위 분석을 진행하려면 먼저 각 구매자의 분위 수를 구해야 한다.
우리는 고객들의 주문 건수를 기준으로 분위 수를 나눈다.
```sql
select *,row_number() over(order by F desc) RNK
from
(select user_id, count(distinct order_id) f
from instacart.orders
group by 1) A
```
주문건수순으로 랭크를 매긴다.
그 다음으로 랭크까지 매겼으면 당연히 전체고객수를 구해 나눠준다.

```sql
SELECT COUNT(DISTINCT user_id)
FROM (
  SELECT user_id, COUNT(DISTINCT order_id) AS F
  FROM instacart.orders
  GROUP BY user_id
) AS A;
```
전체고객수는 3,159명이 나온다.
```sql
select *,
case when RNK <= 316 then 'Quantie_1'
when RNK <= 632 then 'Quantile_2'
when RNK <= 948 then 'Quantile_3'
when RNK <= 1264 then 'Quantile_4'
when RNK <= 1580 then 'Quantile_5'
when RNK <= 1895 then 'Quantile_6'
when RNK <= 2211 then 'Quantile_7'
when RNK <= 2527 then 'Quantile_8'
when RNK <= 2843 then 'Quantile_9'
when RNK <= 3159 then 'Quantile_10' END quantile
FROM
(select *,
row_number() over(order by F desc) RNK
from
(select user_id, count(distinct order_id) f
from instacart.orders
group by 1) A) A
```
이제 각 분위 수별 특성을 파악한다.
각 분위 수별로 평균 recency를 파악한다.
위의 조회 결과를 하나의 테이블로 생성해 user_i별 분위 수 정보를 생성한다.
```sql
CREATE TEMPORARY TABLE INSTACART.USER_QUANTILE AS
SELECT *,
  CASE
    WHEN RNK <= 316 THEN 'Quantie_1'
    WHEN RNK <= 632 THEN 'Quantile_2'
    WHEN RNK <= 948 THEN 'Quantile_3'
    WHEN RNK <= 1264 THEN 'Quantile_4'
    WHEN RNK <= 1580 THEN 'Quantile_5'
    WHEN RNK <= 1895 THEN 'Quantile_6'
    WHEN RNK <= 2211 THEN 'Quantile_7'
    WHEN RNK <= 2527 THEN 'Quantile_8'
    WHEN RNK <= 2843 THEN 'Quantile_9'
    WHEN RNK <= 3159 THEN 'Quantile_10'
  END AS quantile
FROM (
  SELECT *,
    ROW_NUMBER() OVER (ORDER BY F DESC) AS RNK
  FROM (
    SELECT user_id, COUNT(DISTINCT order_id) AS F
    FROM instacart.orders
    GROUP BY user_id
  ) AS A
) AS B;
```
```sql

SELECT quantile, SUM(F) AS F
FROM INSTACART.USER_QUANTILE
GROUP BY quantile;

```
전체 주문 건수의 합을 구한다.![](https://velog.velcdn.com/images/jhaneul/post/8834c573-457b-411a-9a40-ede5c92843bd/image.png)
```sql
select sum(F) From instacart.user_quantile;
```
![](https://velog.velcdn.com/images/jhaneul/post/0cb07a47-7799-4ffc-9d24-3c1247bcb8b8/image.png)
```sql

select quantile,
sum(f)/3220 F 
from instacart.user_quantile
group by 1
```

![](https://velog.velcdn.com/images/jhaneul/post/6704a635-3e1a-436b-aa96-851647ba786c/image.png)
결과를 보면 각 분위 수별로 주문 건수가 거의 균등하게 분포되어 있다.
즉 해당 서비스는 매출이 vip에게 집중되지 않고, 전체 고객에게 고르게 분포되어 있다.

## 4. 상품 분석
```sql
select product_id,
sum(reordered)/sum(1) reorder_rate,
count(distinct order_id) F
from instacart.order_products__prior
group by product_id
order by
reorder_rate desc
```
재구매 비중이 높은 상품을 찾아본다. 상품별 재구매 비중과 주문건수를 계산한다. 
![](https://velog.velcdn.com/images/jhaneul/post/20955248-6ec5-4c45-a081-0c383efcf628/image.png)
주문건수가 일정 건수 이하인 상품은 제외하고 보자.
having을 이용하면 일정 건수 이하인 상품들을 쉽게 제외할 수 있다.
```sql
select product_id,
sum(reordered)/sum(1) reorder_rate,
count(distinct order_id) F
from instacart.order_products__prior
group by product_id
having count(distinct order_id) >10;
```
```sql

select A.product_id,
B.product_name,
sum(reordered)/sum(1) reordered_rate,
count(distinct order_id) F
from instacart.order_products__prior A
left join instacart.products B
on A.product_id = B.product_id
group by product_id, B.product_name
having count(distinct order_id) >10
order by 4 desc ,3 desc;
```
![](https://velog.velcdn.com/images/jhaneul/post/39e1cd8b-c8ec-44e8-b25c-63985ff25d23/image.png)

5. 다음 구매까지 소요기간과 재구매 관계
'고객이 자주 재구매하는 상품은 그렇지 않은 상품보다 일정한 주기를 가질 것이다.'라는 명제를 세우자.
각 그룹에서의 구매 소요 기간의 분산을 구해 보자.

### 9-2) Top10(재구매율)상품 추출
```sql
select *
from
(Select *,
ROW_NUMBER() OVER(ORDER BY RET_RATIO DESC) RNK
FROM
(SELECT PRODUCT_ID,
	SUM(CASE WHEN REORDERED = 1 THEN 1 ELSE 0 END)/COUNT(*) RET_RATIO
FROM INSTACART.ORDER_PRODUCTS__PRIOR
GROUP BY 1) A) A
where RNK BETWEEN 1 AND 10; 

```
위에 있던 9-2 코드를 가지고 오자. 10분위 분석과 동일한 방법으로 각 상품을 10개의 그룹으로 나눈다.
```sql
SELECT A.product_id,
  CASE
    WHEN RNK <= 929 THEN 'Q_1'
    WHEN RNK <= 1858 THEN 'Q_2'
    WHEN RNK <= 2786 THEN 'Q_3'
    WHEN RNK <= 3715 THEN 'Q_4'
    WHEN RNK <= 4644 THEN 'Q_5'
    WHEN RNK <= 5573 THEN 'Q_6'
    WHEN RNK <= 6502 THEN 'Q_7'
    WHEN RNK <= 7430 THEN 'Q_8'
    WHEN RNK <= 8359 THEN 'Q_9'
    WHEN RNK <= 9288 THEN 'Q_10'
  END AS RNK_GRP
FROM (
  SELECT *,
    ROW_NUMBER() OVER (ORDER BY RET_RATIO  DESC) AS RNK
  FROM (
    SELECT product_id, SUM(CASE WHEN reordered = 1 THEN 1 ELSE 0 END) / COUNT(*) AS RET_RATIO
    FROM INSTACART.order_products__prior
    GROUP BY 1
  ) A
) A
GROUP BY 1 ,2 
order by 2,1 ;

```
![업로드중..](blob:https://velog.io/6ccafa92-4e5c-44fc-a77a-b73bffd2126e)
그룹은 나누어졌다. 각 분위 수별로 재구매 소요 시간의 분산을 구하자.

```sql
create temporary table instacart.order_products__prior2 AS
select product_id,
days_since_prior_order
from instacart.order_products__prior A
inner join instacart.orders b on A.order_id = B.order_id;
```
위에서 구했던 'INSTACART.product_repurchase_quantile'와
'instacart.order_products__prior2' 을 조인하여 분위수, 상품별 구매 소요 기간의 분산을 계산한다. 이후 각 분위 수의 상품 소요 기간 분산의 중위 수를 계산한다. 계산한 결과를 보고 분위 수별 구매 소요기간에 차이가 존재하는지 확인할 수 있다.
답은 당신이 구해보자.
