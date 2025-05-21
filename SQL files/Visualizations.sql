select year, count(year) as race_counts from races group by year order by year; -- The number of races per year increased over time.

select r.driverid, count(position) as won_races, sum(points) as total_points, d.forename, d.surname from results as r join drivers as d on r.driverId=d.driverId where r.position = 1 
group by r.driverid, d.forename, d.surname order by won_races desc; 
-- Hamilton won the most races, 105 in total.

-- Total career points
select r.driverid, sum(points) as total_points, d.forename, d.surname from results as r join drivers as d on r.driverId=d.driverId 
group by r.driverid, d.forename, d.surname order by total_points desc; 
-- Lewis Hamilton earned most point in his career - 4821

-- Schumacher and Hamilton were champions 7 times
with last_race_per_year as (select year, max(round) as last_round from races group by year),
final_standings as (select r.year, ds.driverid, ds.points, ds.position, ds.wins, d.forename, d.surname from races as r join driver_standings as ds on r.raceId=ds.raceId
join last_race_per_year as lrp on r.year = lrp.year and r.round = lrp.last_round join drivers as d on ds.driverId=d.driverId),
max_points_per_year as (select year, max(points) as max_points from final_standings group by year),
champions_per_season as (select fs.year, fs.points, fs.driverid, fs.position, fs.wins, fs.forename, fs.surname
from final_standings as fs join max_points_per_year as mpy on fs.year = mpy.year and fs.points = mpy.max_points order by year)
select driverid, forename, surname, count(driverid) as number_of_championships from champions_per_season group by driverid, forename, surname order by number_of_championships desc;

select nationality, count(nationality) as number_of_drivers from drivers group by nationality order by number_of_drivers desc; 
-- Most drivers are British - 166, but only leading by 8 ahead of American drivers

select r.name as grand_prix, c.name as constructor, position from constructor_standings as cs join races as r on r.raceId = cs.raceId 
join constructors as c on c.constructorId = cs.constructorId where year = 2024 order by r.name;
-- Constructor standings in 2024

with last_round_per_season as (select year, max(round) as last_round from races group by year)
select r.year, cs.position, cs.points, c.name from constructor_standings as cs join constructors as c on c.constructorId = cs.constructorId
join races as r on cs.raceId = r.raceId join last_round_per_season as lrps on r.year = lrps.year where lrps.last_round = r.round and r.year > 2019;
-- Constructor standings in the last 5 years

with races_won as (select r.driverid, count(position) as won_races, sum(points) as total_points, d.forename, d.surname from results as r join drivers as d on r.driverId=d.driverId where r.position = 1 
group by r.driverid, d.forename, d.surname order by won_races desc),
races_entried as (select d.driverid, count(d.driverID) as race_count, d.forename, d.surname  from driver_standings as ds join drivers as d on ds.driverId=d.driverId 
group by d.driverId, d.forename, d.surname)
select concat(w.forename, ' ', w.surname) as driver, won_races, race_count from races_won as w join races_entried as e on w.driverid = e.driverid;
-- Won races / total races


select r.driverid, count(position) as point_gain_races, d.forename, d.surname from results as r join drivers as d on r.driverId=d.driverId where points > 0 group by r.driverid, d.forename, d.surname;
with point_gain_races as (select r.driverid, count(position) as point_gain_races, d.forename, d.surname from results as r join drivers as d on r.driverId=d.driverId where points > 0 group by r.driverid, d.forename, d.surname),
races_entried as (select d.driverid, count(d.driverID) as race_count, d.forename, d.surname  from driver_standings as ds join drivers as d on ds.driverId=d.driverId 
group by d.driverId, d.forename, d.surname)
select concat(p.forename, ' ', p.surname) as driver, point_gain_races, race_count from point_gain_races as p join races_entried as e on p.driverid = e.driverid;
-- Point scoring races / total races

-- Which team has been the most successful in the past? Who has won most championships?
with last_round_per_season as (select year, max(round) as last_round from races group by year),
final_standings as (select r.year, cs.raceId, cs.constructorId, cs.points, c.name from constructor_standings as cs join constructors as c on c.constructorId = cs.constructorId
join races as r on cs.raceId = r.raceId join last_round_per_season as lrps on r.year = lrps.year where lrps.last_round = r.round),
max_constructor_points_per_year as (select fs.year, max(fs.points) as max_points from final_standings as fs group by fs.year), 
constructor_champions_per_season as ( select fs.year, fs.constructorid, mp.max_points, fs.name from final_standings as fs join max_constructor_points_per_year as mp
on fs.year = mp.year and fs.points = mp.max_points order by fs.year desc)
select name, count(name) as count_won_championship from constructor_champions_per_season group by name order by count_won_championship desc;
-- Ferrari has won the championship most times: 16, being the most successful constructor