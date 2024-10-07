# IPL-Auction-Strategy

## Overview

This repository contains SQL queries to address various requirements for selecting players for an IPL team. The queries are designed to identify players with specific performance metrics, such as high strike rate, low economy rate, and all-round capabilities.

## Objectives

The queries aim to:

1. Identify players with high strike rate (batters) who have faced at least 500 balls.
2. Identify players with good average (batters) who have played more than two IPL seasons.
3. Identify hard-hitting players (batters) who have scored the most runs in boundaries and have played more than two IPL seasons.
4. Identify bowlers with good economy rate who have bowled at least 500 balls.
5. Identify bowlers with the best strike rate who have bowled at least 500 balls.
6. Identify all-rounders with the best batting and bowling strike rates who have faced at least 500 balls and bowled at least 300 balls.

## Queries

### Query 1: Batters with High Strike Rate

```sql
select batsman,
round(sum(batsman_runs)*1.0/count(ball)*100,2) as strike_rate
from ball_data
where extras_type not in ('wides','n')
group by batsman 
having count(ball ) > 500
order by strike_rate desc
	limit 10;
```

### Query 2: Batters with Good Average

```sql
select batsman,
	round(sum(batsman_runs):: decimal /sum(case when is_wicket then 1 else 0 end),2) as average
from ball_data as a 
	full join match_data as b 
	on a.id = b.id 
	group by  batsman
having  sum(case when is_wicket then 1 else 0 end) >= 1 and  count(distinct extract(year from b.date)) > 2
order by average desc limit 10;
```

### Query 3: Hard-Hitting Batters

```sql
select batsman,
	round(sum(case when batsman_runs in (4,6) then batsman_runs else 0 end)::decimal/sum(batsman_runs)*100,2) as boundary_percentage
from ball_data group by batsman having count(distinct id ) > 28 order by boundary_percentage desc limit 10;
```

### Query 4: Bowlers with Good Economy Rate

```sql
select bowler, round(sum(total_runs)::decimal / (count(ball) / 6.0), 2) as economy from ball_data
group by bowler having count(ball) > 500 order by economy asc limit 10;
```

### Query 5: Bowlers with Best Strike Rate

```sql
select bowler,
round(count(is_wicket)::decimal/sum(case when is_wicket  then 1 else 0 end),2) as strike_rate
from ball_data group by bowler having count(is_wicket) > 500  order by strike_rate asc limit 10;
```

### Query 6: All-Rounders with Best Batting and Bowling Strike Rates

```sql
create table batting_sr as
select batsman,
round(sum(batsman_runs)*1.0/count(ball)*100,2) as strike_rate
from ball_data
where extras_type not in ('wides')
group by batsman 
having count(ball ) > 500
order by strike_rate desc;

select * from batting_sr;
	
create table bowling_sr as
select bowler, round(count(is_wicket)::decimal/sum(case when is_wicket  then 1 else 0 end),2) as strike_rate
from ball_data group by bowler having count(is_wicket) > 300 order by strike_rate asc;
select * from bowling_sr;

select a.batsman,	a.strike_rate as batting_strike_rate, 	b.strike_rate as bowling_strike_rate
from batting_sr as a	inner join bowling_sr as b	on a.batsman = b.bowler
order by batting_strike_rate desc, bowling_strike_rate asc	limit 10;
```
