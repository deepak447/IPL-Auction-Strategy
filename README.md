# IPL-Auction-Strategy
![IPL_logo](https://github.com/user-attachments/assets/d09643f5-5cf4-4c1f-8e15-7f6b9d5d016c)

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
7. Count the number of unique cities that have hosted IPL matches.
8. Create a new table `deliveries_v02` with an additional column `ball_result` indicating whether a delivery was a boundary, dot, or other.
9. Fetch the total number of boundaries and dot balls from the `deliveries_v02` table.
10. Fetch the total number of boundaries scored by each team from the `deliveries_v02` table, ordered by descending boundary count.
11. Fetch the total number of dot balls bowled by each team from the `deliveries_v02` table, ordered by descending dot ball count.
12. Fetch the total number of dismissals by dismissal kind from the `ball_data` table, excluding 'NA' dismissals, ordered by descending dismissal count.
13. Identify the top 5 bowlers who conceded the maximum extra runs from the `ball_data` table.
14. Create a new table `deliveries_v03` with additional columns `venue` and `match_date` from the `match_data` table, then drop the `deliveries_v03` table.
15. Fetch the total runs scored at each venue from the `deliveries_v03` table, ordered by descending run count.
16. Fetch the year-wise total runs scored at Eden Gardens from the `deliveries_v03` table, ordered by descending run count.

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

### Query 7: Count of Cities Hosting Matches

```sql
select count(distinct city) as count_of_cities
from match_data;
```

### Query 8: Create deliveries_v02 Table

```sql
create table deliveries_v02 as 
select * , 
	case 
	when total_runs >=4 then 'boundary' 
	when total_runs= 0 then 'dots' 
	else 'other' 
	end as ball_result
from ball_data;
```

### Query 9: Total Boundaries and Dot Balls

```sql
select ball_result as boundary_dot_ball , count(*) as total_boundary_dots
from deliveries_v02
where ball_result in ('boundary','dot') 
	group by ball_result;
```

### Query 10: Total Boundaries by Team

```sql
select distinct batting_team as team,
count(ball_result) as count_of_boundary_each_team
from deliveries_v02
where ball_result = 'boundary'
group by batting_team
	order by count_of_boundary_each_team desc;
```

### Query 11: Total Dot Balls by Team

```sql
select distinct batting_team as team,
count(ball_result) as count_of_dotBall_each_team
from deliveries_v02
where ball_result = 'dot'
group by batting_team
	order by count_of_dotBall_each_team desc;
```

### Query 12: Total Dismissals by Kind

```sql
select dismissal_kind as dismissal_type,
count (dismissal_kind) as dismissals
from ball_data
where dismissal_kind != 'NA'
group by dismissal_kind
order by dismissals desc;
```

### Query 13: Top 5 Bowlers with Maximum Extra Runs

```sql
select bowler,
sum(extra_runs) as extra_runs
from ball_data
group by bowler
order by extra_runs desc
limit 5;
```

### Query 14: Create and Drop deliveries_v03 Table

```sql
create table deliveries_v03 as
select a.*,
		b.venue,
		b.date
from deliveries_v02 as a
full join match_data as b
on a.id = b.id;
```

```sql
drop table deliveries_v03;
```

### Query 15: Total Runs by Venue

```sql
select venue,
sum(total_runs) as total_runs
from deliveries_v03
group by venue
order by total_runs desc;
```

### Query 16: Year-Wise Total Runs at Eden Gardens

```sql
select extract('year'from date) as season,
	sum(total_runs) as total_runs
from deliveries_v03
where venue = 'Eden Gardens'
	group by season
order by total_runs desc;
```
