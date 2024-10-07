-- Q1 : Your first priority is to get 2-3 players with high S.R who have faced at least 500 balls.And
	-- to do that you have to make a list of 10 players you want to bid in the auction so that
	-- when you try to grab them in auction you should not pay the amount greater than you
	-- have in the purse for a particular player.
	-- (strike rate is total runs scored by batsman divided by number of balls faced but remember
	-- when extras_type is 'wides' it is not counted as a ball faced neither counted as batsmen runs)
select * from ball_data;
select * from match_data;

select batsman,
round(sum(batsman_runs)*1.0/count(ball)*100,2) as strike_rate
from ball_data
where extras_type not in ('wides','n')
group by batsman 
having count(ball ) > 500
order by strike_rate desc
	limit 10;
	
-- Q2 : Now you need to get 2-3 players with good Average who have played more than 2 ipl
	-- seasons. And to do that you have to make a list of 10 players you want to bid in the
	-- auction so that when you try to grab them in auction you should not pay the amount
	-- greater than you have in the purse for a particular player.
	-- (Average is calculated as total runs scored divided by number of times batsman has been
	-- dismissed which can be calculated using wicket_ball field as 1 indicates out and 0 indicates not
	-- out, a batsman should’ve been dismissed at least once to calculate the sr i.e., you can exclude
	-- those players who have not been dismissed once )
select * from ball_data;
select * from match_data;

select batsman,
	round(sum(batsman_runs):: decimal /sum(case when is_wicket then 1 else 0 end),2) as average
from ball_data as a 
	full join match_data as b 
	on a.id = b.id 
	group by  batsman
having  sum(case when is_wicket then 1 else 0 end) >= 1 and  count(distinct extract(year from b.date)) > 2
order by average desc limit 10;
-- Q3 : Now you need to get 2-3 Hard-hitting players who have scored most runs in boundaries
	-- and have played more the 2 ipl season. To do that you have to make a list of 10 players
	-- you want to bid in the auction so that when you try to grab them in auction you should
	-- not pay the amount greater than you have in the purse for a particular player.
	-- (only 4 and 6 will be counted as boundaries so calculate how many 4 and 6 has been hit by
	-- each batsman and also calculate total runs scored to get the output as boundary percentage
	-- which will be runs in boundary divided by total runs scored)

select batsman,
	round(sum(case when batsman_runs in (4,6) then batsman_runs else 0 end)::decimal/sum(batsman_runs)*100,2) as boundary_percentage
from ball_data group by batsman having count(distinct id ) > 28 order by boundary_percentage desc limit 10;

-- Q4 : Your first priority is to get 2-3 bowlers with good economy who have bowled at least 500
	-- balls in IPL so far.To do that you have to make a list of 10 players you want to bid in the
	-- auction so that when you try to grab them in auction you should not pay the amount
	-- greater than you have in the purse for a particular player.(economy can be calculated by
	-- dividing total runs conceded with total overs bowled)
select * from ball_data;
select bowler, round(sum(total_runs)::decimal / (count(ball) / 6.0), 2) as economy from ball_data
group by bowler having count(ball) > 500 order by economy asc limit 10;

-- Q5 :Now you need to get 2-3 bowlers with the best strike rate and who have bowled at least
	-- 500 balls in IPL so far.To do that you have to make a list of 10 players you want to bid in
	-- the auction so that when you try to grab them in auction you should not pay the amount
	-- greater than you have in the purse for a particular player.
	-- (strike rate of a bowler can be calculated by number of balls bowled divided by total wickets
	-- taken )

select bowler,
round(count(is_wicket)::decimal/sum(case when is_wicket  then 1 else 0 end),2) as strike_rate
from ball_data group by bowler having count(is_wicket) > 500  order by strike_rate asc limit 10;

-- Q6 : Now you need to get 2-3 All_rounders with the best batting as well as bowling strike rate
	-- and who have faced at least 500 balls in IPL so far and have bowled minimum 300
	-- balls.To do that you have to make a list of 10 players you want to bid in the auction so
	-- that when you try to grab them in auction you should not pay the amount greater than
	-- you have in the purse for a particular player.
	-- ( strike rate of an all rounder can be calculated using the same criteria of batsman similarly the
	-- bowling strike rate can be calculated using the criteria of a bowler
select * from ball_data;

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
































