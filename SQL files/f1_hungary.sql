select * from drivers where nationality = "Hungarian"; -- Baumgartner 47
select count(raceId) from driver_standings where driverId = 47; -- Baumgartner took part of 20 races
select r.raceid, points, position, year, name from driver_standings as ds join races as r on r.raceId = ds.raceId where driverId = 47;
-- Baumgartner competed in 2003 and 2004
select max(points) from driver_standings where driverId = 47; -- He earned 10 points in total
select raceid, driverid, c.constructorid, name from results as r join constructors as c on r.constructorId = c.constructorId where driverid = 47;
select count(positionText) from results where driverId = 47 and positionText = 'R';

select * from races where name = 'Hungarian Grand Prix' order by year asc; -- circuitid = 11
-- Since 1986

select count(year) from races where name = 'Hungarian Grand Prix';
-- 39 races

select count(re.driverid) as wins, concat(forename, ' ', surname) as name from results as re join races as ra on re.raceId = ra.raceId join drivers as d on re.driverId = d.driverId 
where circuitid = 11 and position = 1 group by re.driverid, forename, surname order by wins desc limit 3;
-- Winners

select count(re.driverid) as poles, concat(forename, ' ', surname) as name from results as re join races as ra on re.raceId = ra.raceId join drivers as d on re.driverId = d.driverId 
where circuitid = 11 and grid = 1 group by re.driverid, forename, surname order by poles desc limit 3;
-- Grid positions

select driverid, re.time from results as re join races as ra on re.raceId = ra.raceId where circuitid = 11 and position = 1 and
re.time = (select min(re1.time) from results as re1 join races as ra1 on re1.raceId = ra1.raceId where circuitid = 11 and position = 1);
-- Hamilton has the fastest lap time

select drivers.driverId, drivers.forename, drivers.surname, re.raceid, position, grid, grid-position as jump 
from results as re join drivers on re.driverId = drivers.driverId join races as ra on re.raceId = ra.raceId where circuitid = 11 order by jump desc;
-- Most positions gained on Hungaroring
-- 19 positions gained by Lewis Hamilton

select re.driverid, sum(points) as total_points, d.forename, d.surname from results as re join drivers as d on re.driverId=d.driverId join races as ra on ra.raceId = re.raceId
where circuitId = 11 group by re.driverid, d.forename, d.surname order by total_points desc; 
-- Most points gained on Hungaroring
-- 286 by Hamilton

select re.raceid, re.driverid, points, d.forename, d.surname from results as re join drivers as d on re.driverId=d.driverId join races as ra on ra.raceId = re.raceId
where circuitId = 11; 
select concat(d.forename, ' ', d.surname) as driver from results as re join drivers as d on re.driverId=d.driverId join races as ra on ra.raceId = re.raceId
where circuitId = 11 group by driver; -- Who raced in Hungaroring 
select  concat(d.forename, ' ', d.surname) as driver from results as re join drivers as d on re.driverId=d.driverId join races as ra on ra.raceId = re.raceId
where circuitId = 11 and points = 0 group by driver; -- Who got 0 points at at least 1 race
with hungaroring_drivers as (select concat(d.forename, ' ', d.surname) as driver from results as re join drivers as d on re.driverId=d.driverId join races as ra on ra.raceId = re.raceId
where circuitId = 11 group by driver),
earned_zero_points as (select  concat(d.forename, ' ', d.surname) as driver from results as re join drivers as d on re.driverId=d.driverId join races as ra on ra.raceId = re.raceId
where circuitId = 11 and points = 0 group by driver)
select h.driver as drove, z.driver from hungaroring_drivers as h left join earned_zero_points as z on h.driver = z.driver;

with hungaroring_drivers as (select concat(d.forename, ' ', d.surname) as driver from results as re join drivers as d on re.driverId=d.driverId join races as ra on ra.raceId = re.raceId
where circuitId = 11 group by driver)
select driver from hungaroring_drivers where driver not in (select  concat(d.forename, ' ', d.surname) as driver from results as re join drivers as d on re.driverId=d.driverId join races as ra on ra.raceId = re.raceId
where circuitId = 11 and points = 0 group by driver);
-- Always gained points on Hungaroring