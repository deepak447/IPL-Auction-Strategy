select * from ball_data;

-- Q1 : 1. Get the count of cities that have hosted an IPL match
select count(distinct city) as count_of_cities
from match_data;


-- Q2 :  Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional
	-- column ball_result containing values boundary, dot or other depending on the total_run
	-- (boundary for >= 4, dot for 0 and other for any other number)
	-- (Hint 1 : CASE WHEN statement is used to get condition based results)
	-- (Hint 2: To convert the output data of the select statement into a table, you can use a
	-- subquery. Create table table_name as [entire select statement]
create table deliveries_v02 as 
select * , 
	case 
	when total_runs >=4 then 'boundary' 
	when total_runs= 0 then 'dots' 
	else 'other' 
	end as ball_result
from ball_data;
select * from deliveries_v02;


-- Q3 : Write a query to fetch the total number of boundaries and dot balls from the
--	 deliveries_v02 table.

select ball_result as boundary_dot_ball , count(*) as total_boundary_dots
from deliveries_v02
where ball_result in ('boundary','dot') 
	group by ball_result;


-- Q4 : Write a query to fetch the total number of boundaries scored by each team from the
	-- deliveries_v02 table and order it in descending order of the number of boundaries
	-- scored.

select distinct batting_team as team,
count(ball_result) as count_of_boundary_each_team
from deliveries_v02
where ball_result = 'boundary'
group by batting_team
	order by count_of_boundary_each_team desc;

-- Q5 : Write a query to fetch the total number of dot balls bowled by each team and order it in
-- 	descending order of the total number of dot balls bowled.
	
select distinct batting_team as team,
count(ball_result) as count_of_dotBall_each_team
from deliveries_v02
where ball_result = 'dot'
group by batting_team
	order by count_of_dotBall_each_team desc;

-- Q6 : Write a query to fetch the total number of dismissals by dismissal kinds where dismissal
-- 		kind is not NA
select * from ball_data;
select dismissal_kind as dismissal_type,
count (dismissal_kind) as dismissals
from ball_data
where dismissal_kind != 'NA'
group by dismissal_kind
order by dismissals desc;


-- Q7 : Write a query to get the top 5 bowlers who conceded maximum extra runs from the
	-- deliveries table

select bowler,
sum(extra_runs) as extra_runs
from ball_data
group by bowler
order by extra_runs desc
limit 5;

-- Q8 : Write a query to create a table named deliveries_v03 with all the columns of
	-- deliveries_v02 table and two additional column (named venue and match_date) of venue
	-- and date from table matches

create table deliveries_v03 as
select a.*,
		b.venue,
		b.date
from deliveries_v02 as a
full join match_data as b
on a.id = b.id;
select * from deliveries_v03;
drop table deliveries_v03;

-- Q9 : Write a query to fetch the total runs scored for each venue and order it in the descending
-- 		order of total runs scored

select venue,
sum(total_runs) as total_runs
from deliveries_v03
group by venue
order by total_runs desc;

-- Q10 : Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the
--		 descending order of total runs scored

select extract('year'from date) as season,
	sum(total_runs) as total_runs
from deliveries_v03
where venue = 'Eden Gardens'
	group by season
order by total_runs desc;
























































