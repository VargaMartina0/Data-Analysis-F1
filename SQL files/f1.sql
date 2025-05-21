-- Data loading
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1; 
-- drop table results;
create table results (
	resultId int,raceId int,driverId int,constructorId int,number int,grid int,position int,positionText text,positionOrder int,
	points int,laps int,time text,milliseconds int,fastestLap int,ranks int,fastestLapTime text,fastestLapSpeed text,statusId int);
-- I had to open the command line for the below because I received access denied error from here, I also had to change '"' characters in the csv file to '-' to be able to 
-- import the data successfully.
LOAD DATA LOCAL INFILE 'C:/Users/Martina/Downloads/results.csv' INTO TABLE results FIELDS TERMINATED BY ','  Optionally ENCLOSED BY '-' lines TERMINATED BY '\r\n' IGNORE 1 LINES;
select max(resultid) from results; -- where raceid = 1144;

-- drop table drivers;
create table drivers (driverId int,driverRef text,number int,code text,forename text,surname text,dob text,nationality text,url text);
LOAD DATA LOCAL INFILE 'C:/Users/Martina/Downloads/drivers.csv' INTO TABLE drivers FIELDS TERMINATED BY ','  Optionally ENCLOSED BY '-' lines TERMINATED BY '\r\n' IGNORE 1 LINES;

-- Data Analysis
select min(year), max(year), count(year) from seasons; -- F1 data 1950-2024. The first official F1 season was held in 1950.
select count(raceid) from races; -- 1125 races were held during 75 seasons
select year, count(year) as race_counts from races group by year order by year; -- The number of races per year increased over time.
with number_of_races_per_year as (select year, count(year) as race_counts from races group by year order by year)
select avg(race_counts) from number_of_races_per_year; -- The average count of races per season is 15.
select count(driverId) from drivers; -- In total 861 drivers competed across the years.
select count(circuitid) from circuits; -- In total the races took place at 77 circuits;
select count(constructorid) from constructors; -- In total 212 constructors competed;
select * from driver_standings as ds join drivers as d on ds.driverId=d.driverId;
select d.driverid, count(d.driverID), d.forename, d.surname as race_count from driver_standings as ds join drivers as d on ds.driverId=d.driverId group by d.driverId, d.forename, d.surname
having count(d.driverID) = (select max(dc.driver_count) from (select count(driverid) as driver_count from driver_standings group by driverID) as dc); 
-- Fernando Alonso has taken part of the most races, 406 in total.
select d.driverid, count(d.driverID) as one_race, d.forename, d.surname as race_count from driver_standings as ds join drivers as d on ds.driverId=d.driverId group by d.driverId, d.forename, d.surname
having count(d.driverID) = (select min(dc.driver_count) from (select count(driverid) as driver_count from driver_standings group by driverID) as dc); 
-- These drivers have only taken part of one race.
with one_race_drivers as (select d.driverid, count(d.driverID) as one_race, d.forename, d.surname as race_count from driver_standings as ds join drivers as d on ds.driverId=d.driverId group by d.driverId, d.forename, d.surname
having count(d.driverID) = (select min(dc.driver_count) from (select count(driverid) as driver_count from driver_standings group by driverID) as dc))
select count(one_race) from one_race_drivers; 
-- 27 drivers entered only one race

-- The driver who won most races.
select * from results order by raceid; 
select d.driverid, sum(wins), d.forename, d.surname from driver_standings as ds join drivers as d on ds.driverId=d.driverId group by d.driverid, d.forename, d.surname;
select raceid, max(wins) from driver_standings where driverid = 1 group by raceid order by raceid;
select raceid,driverid, position, points, ranks from results order by raceid, position; -- here position gives the final order for the race, rank is about the fastest lap
select * from driver_standings where driverid = 1 order by raceid; -- points refer to points in the season (cummulative), position refers to position on the leaderboard for the season, wins is also cumulatitive
select r.driverid, count(position) as won_races, sum(points) as total_points, d.forename, d.surname from results as r join drivers as d on r.driverId=d.driverId where r.position = 1 
group by r.driverid, d.forename, d.surname order by won_races desc; 
-- Hamilton won the most races, 105 in total.

-- Total career points
select r.driverid, sum(points) as total_points, d.forename, d.surname from results as r join drivers as d on r.driverId=d.driverId 
group by r.driverid, d.forename, d.surname order by total_points desc; 
-- Lewis Hamilton earned most point in his career - 4821

-- The drivers who won the championships per season
select d.raceid, year, round, d.driverId, points, position, wins from races as r join driver_standings as d on r.raceId=d.raceId where d.raceid = 35 order by position;
-- Now I understand that I need to find the last round per year and find the maximum points in the season
select rp.year, max(dp.points) from races as rp join driver_standings as dp on rp.raceId=dp.raceId group by rp.year; -- Max points per season
select year, max(round) as last_round from races group by year; -- Last rounds per season

with last_race_per_year as (select year, max(round) as last_round from races group by year),
final_standings as (select r.year, ds.driverid, ds.points, ds.position, ds.wins from races as r join driver_standings as ds on r.raceId=ds.raceId
join last_race_per_year as lrp on r.year = lrp.year and r.round = lrp.last_round),
max_points_per_year as (select year, max(points) as max_points from final_standings group by year)
select fs.year, fs.points, fs.driverid, fs.position, fs.wins
from final_standings as fs join max_points_per_year as mpy on fs.year = mpy.year and fs.points = mpy.max_points order by year;
-- We don't have to look at the last race in the season, because max(points throughout the season)=max(the points of the last race in the season),
-- so ecvivalent with the above:
with final_standings as (select r.year, ds.driverid, ds.points, ds.position, ds.wins from races as r join driver_standings as ds on r.raceId=ds.raceId),
max_points_per_year as (select year, max(points) as max_points from final_standings group by year)
select fs.year, fs.points, fs.driverid, fs.position, fs.wins
from final_standings as fs join max_points_per_year as mpy on fs.year = mpy.year and fs.points = mpy.max_points order by year;
-- With the name of the champions:
with final_standings as (select r.year, ds.driverid, ds.points, ds.position, ds.wins, d.forename, d.surname from races as r join driver_standings as ds on r.raceId=ds.raceId 
join drivers as d on ds.driverId=d.driverId),
max_points_per_year as (select year, max(points) as max_points from final_standings group by year)
select fs.year, fs.points, fs.driverid, fs.position, fs.wins, fs.forename, fs.surname
from final_standings as fs join max_points_per_year as mpy on fs.year = mpy.year and fs.points = mpy.max_points order by year;

-- Who won how many seasons?
with final_standings as (select r.year, ds.driverid, ds.points, ds.position, ds.wins, d.forename, d.surname from races as r join driver_standings as ds on r.raceId=ds.raceId 
join drivers as d on ds.driverId=d.driverId),
max_points_per_year as (select year, max(points) as max_points from final_standings group by year), 
champions_per_season as (select fs.year, fs.points, fs.driverid, fs.position, fs.wins, fs.forename, fs.surname
from final_standings as fs join max_points_per_year as mpy on fs.year = mpy.year and fs.points = mpy.max_points order by year)
select driverid, forename, surname, count(driverid) as number_of_championships from champions_per_season group by driverid, forename, surname order by number_of_championships desc;
-- This doesn't give the accurate answer
-- I added back the last_race_per_year and the below answers the question accurately, Schumacher and Hamilton were champions 7 times
with last_race_per_year as (select year, max(round) as last_round from races group by year),
final_standings as (select r.year, ds.driverid, ds.points, ds.position, ds.wins, d.forename, d.surname from races as r join driver_standings as ds on r.raceId=ds.raceId
join last_race_per_year as lrp on r.year = lrp.year and r.round = lrp.last_round join drivers as d on ds.driverId=d.driverId),
max_points_per_year as (select year, max(points) as max_points from final_standings group by year),
champions_per_season as (select fs.year, fs.points, fs.driverid, fs.position, fs.wins, fs.forename, fs.surname
from final_standings as fs join max_points_per_year as mpy on fs.year = mpy.year and fs.points = mpy.max_points order by year)
select driverid, forename, surname, count(driverid) as number_of_championships from champions_per_season group by driverid, forename, surname order by number_of_championships desc;
--
select * from drivers;
select nationality, count(nationality) as number_of_drivers from drivers group by nationality order by number_of_drivers desc; 
-- Most drivers are British - 166, but only leading by 8 ahead of American drivers
--
select * from constructors;
select nationality, count(nationality) as number_of_constructors from constructors group by nationality order by number_of_constructors desc; 
-- Most constructors are British - 86 constructors, more than double of the second nationality!
select * from constructor_standings;
select * from constructor_results;
select * from races;
select * from constructor_results as cr join constructor_standings as cs on cr.raceId = cs.raceId and cr.constructorId = cs.constructorId 
where cr.raceid = 2 or cr.raceid = 1 order by cr.raceid, cr.points desc;
-- points in results show the points earned in the race, in standings it refers to points collected throughout the season
select year, max(round) as last_round from races group by year;

-- The below shows the constructor championship winners per season
with last_round_per_season as (select year, max(round) as last_round from races group by year),
final_standings as (select r.year, cs.raceId, cs.constructorId, cs.points, c.name from constructor_standings as cs join constructors as c on c.constructorId = cs.constructorId
join races as r on cs.raceId = r.raceId join last_round_per_season as lrps on r.year = lrps.year where lrps.last_round = r.round),
max_constructor_points_per_year as (select fs.year, max(fs.points) as max_points from final_standings as fs group by fs.year)
select fs.year, fs.constructorid, mp.max_points, fs.name from final_standings as fs join max_constructor_points_per_year as mp
on fs.year = mp.year and fs.points = mp.max_points order by fs.year desc;

-- Which team has been the most successful in the past? Who has won most championships?
with last_round_per_season as (select year, max(round) as last_round from races group by year),
final_standings as (select r.year, cs.raceId, cs.constructorId, cs.points, c.name from constructor_standings as cs join constructors as c on c.constructorId = cs.constructorId
join races as r on cs.raceId = r.raceId join last_round_per_season as lrps on r.year = lrps.year where lrps.last_round = r.round),
max_constructor_points_per_year as (select fs.year, max(fs.points) as max_points from final_standings as fs group by fs.year), 
constructor_champions_per_season as ( select fs.year, fs.constructorid, mp.max_points, fs.name from final_standings as fs join max_constructor_points_per_year as mp
on fs.year = mp.year and fs.points = mp.max_points order by fs.year desc)
select name, count(name) as count_won_championship from constructor_champions_per_season group by name order by count_won_championship desc;
-- Ferrari has won the championship most times: 16, being the most successful constructor
--
-- Who was able to jump ahead the most positions throughout one race from the starting position?
select * from results where raceid = 778;
select drivers.driverId, drivers.forename, drivers.surname, raceid, position, grid, grid-position as jump 
from results join drivers on results.driverId = drivers.driverId order by jump desc;
-- Most positions gained in a race were 30 by Jim Rathmann
--
-- Which constructor completed most races?
select c.constructorid, count(raceid) as number_of_races, name from constructor_results as cr join constructors as c on c.constructorid = cr.constructorId 
group by constructorid, name order by number_of_races desc;
-- The above doesn't reflect the real numbers since the constructor championship only started in 1958
select c.constructorid, count(raceid) as number_of_races, name from results as r join constructors as c on c.constructorid = r.constructorId 
group by constructorid, name order by number_of_races desc;
-- The above doesn't reflect the real numbers since it counts per pilot, not per race
select distinct constructorid, raceid from results;
with constructors_entered_races as (select distinct constructorid, raceid from results), 
number_of_races_per_constructor as (select constructorid, count(raceid) as number_of_races from constructors_entered_races group by constructorId)
select name, c.constructorid, number_of_races from number_of_races_per_constructor as n join constructors as c on n.constructorid = c.constructorid order by number_of_races desc;
-- Ferrari has participated in most races, in 1100
--
-- Who had most pole positions?
select * from drivers;
select count(raceid) from races; -- 1125
with number_of_poles_per_driver as (select driverid, count(raceid) as number_of_poles from results where grid = 1 group by driverid order by number_of_poles desc)
select sum(number_of_poles) from number_of_poles_per_driver; -- 1136
-- The above two numbers are different since there were races where multiple drivers achieved the pole position since they qualified with the same time
with number_of_poles_per_driver as (select driverid, count(raceid) as number_of_poles from results where grid = 1 group by driverid)
select d.driverid, number_of_poles, forename, surname from number_of_poles_per_driver as n join drivers as d on n.driverid = d.driverid order by number_of_poles desc;
-- Lewis Hamilton had most pole positions in his career - 104

-- Least laps in a race
-- Most laps in a race
select * from results;
select * from races;
select name, max(laps) as laps from races as ra left join results as re on ra.raceId = re.raceId group by name order by laps desc;
-- Least laps in a race: 18
-- Most laps in a race: 200
--
-- Fastest times per grand prixes
select * from results;
with times_per_race as (select ra.raceid, driverid, grid, position, laps, re.time, ranks, fastestLapTime, fastestLapSpeed, ra.name, ra.year 
from races as ra left join results as re on ra.raceId = re.raceId where position = 1),
fastest_times_per_grand_prix as (select min(time) as fastest_time, name from times_per_race group by name)
select fastest_time, f.name, raceid, t.driverid, grid, laps, ranks, fastestLapTime, fastestLapSpeed, year, d.forename, d.surname  
from fastest_times_per_grand_prix as f join times_per_race as t on f.fastest_time = t.time join drivers as d on d.driverId = t.driverid;
-- Who has most fastest grand prixes?
with times_per_race as (select ra.raceid, driverid, grid, position, laps, re.time, ranks, fastestLapTime, fastestLapSpeed, ra.name, ra.year 
from races as ra left join results as re on ra.raceId = re.raceId where position = 1),
fastest_times_per_grand_prix as (select min(time) as fastest_time, name from times_per_race group by name),
fastest_times as (select fastest_time, f.name, raceid, t.driverid, grid, laps, ranks, fastestLapTime, fastestLapSpeed, year, d.forename, d.surname  
from fastest_times_per_grand_prix as f join times_per_race as t on f.fastest_time = t.time join drivers as d on d.driverId = t.driverid)
select forename, surname, count(year) as fastest_grand_prixes from fastest_times group by forename, surname order by fastest_grand_prixes desc;
-- Lewis Hamilton and Max Verstappen won most fastest grand prixes: 7
--
-- Biggest grid
select * from results;
select ra.raceid, count(grid) as grid_size, ra.name from results as re left join races as ra on re.raceId = ra.raceId group by ra.raceid, ra.name order by grid_size desc;
-- Biggest grid size was 55 but this was in an era when the Indianapolis 500 didn't count towards the championship, the drivers didn't earn points on this race
-- Smallest grid size is 20
--
-- Who was able to keep most pole positions?
select * from results;
select r.driverid, forename, surname, count(r.driverid) as kept_pole_count from results as r left join drivers as d on r.driverId = d.driverId 
where grid = 1 and position = 1 group by r.driverid, forename, surname order by kept_pole_count desc;
-- Lewis Hamilton was able to keep his pole positions the most times - 61
--
-- Driver who worked at most constructors
with driver_constructor_pairs as (select distinct driverid, constructorid from results)
select d.driverid, count(constructorid) as number_of_constructors, forename, surname from driver_constructor_pairs as p join drivers as d on d.driverId = p.driverid 
group by d.driverid, forename, surname order by number_of_constructors desc;
-- Chris Amon drove at most constructors: 14
--
select * from circuits;
select * from races;
select circuitid, name, count(raceid) as number_of_races from races group by circuitid, name order by number_of_races desc;
-- The Italian Grand Prix was held most times - 74, drivers raced in Monza every year since 1950, from the beginning
--
-- Most wins in a single season
-- select * from results as re join races as ra on re.raceid = ra.raceid where position = 1;
