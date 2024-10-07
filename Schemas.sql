-- SCHEMAS of IPL Data

CREATE TABLE ball_data (
    id int,
    inning INT,
    over INT,
    ball INT,
    batsman VARCHAR(255),
    non_striker VARCHAR(255),
    bowler VARCHAR(255),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    is_wicket BOOLEAN,
    dismissal_kind VARCHAR(255),
    player_dismissed VARCHAR(255),
    fielder VARCHAR(255),
    extras_type VARCHAR(255),
    batting_team VARCHAR(255),
    bowling_team VARCHAR(255)
);
copy ball_data from 'C:\Program Files\PostgreSQL\16\data\Data\IPL Dataset\IPL_Ball.csv' delimiter ','csv header; 

CREATE TABLE match_data (
	id integer,
	city varchar(255),
	date date,
	player_of_match varchar(255),
	venue varchar(255),
	neutral_venue int,
	team1 varchar(255),
	team2 varchar(255),
	toss_winner varchar(255),
	toss_decision varchar(255),
	winner varchar(255),
	result varchar(255),
	result_margin varchar(255),
	eliminator varchar(255),
	method varchar(255),
	umpire1 varchar(255),
	umpire2 varchar(255)
);

copy matches from 'C:\Program Files\PostgreSQL\16\data\Data\IPL Dataset\IPL_matches.csv' delimiter ','csv header;
