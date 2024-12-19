use ola;
show tables;
select * from duration;
select * from loc;
select * from trips;
select * from payment;
select * from trips_details;

-- total trips
select count(distinct tripid) from trips_details;

-- total drivers
select count(distinct driverid) as Total_drivers from trips;

-- total earnings
select sum(fare) as Total_earnings from trips;

-- total Completed trips
select sum(end_ride) as Total_rides_completed from trips_details;

-- total searches	
select sum(searches),sum(searches_got_estimate),sum(searches_for_quotes),sum(searches_got_quotes) from trips_details;

-- total searches which got estimate
select sum(searches),sum(searches_got_estimate) from trips_details;

-- total searches which got quotes
select sum(searches),sum(searches_got_quotes) from trips_details;

-- total driver not cancelled
select count(driver_not_cancelled) as driver_not_cancelled from trips_details where driver_not_cancelled = 1;

-- Top 5 most active drivers
select driverid, count(driverid) as Max_rides from trips group by driverid order by Max_rides desc limit 5;

-- cancelled bookings by driver
select count(driver_not_cancelled) as drivers_cancelled from trips_details where driver_not_cancelled = 0;

-- cancelled bookings by driver
select count(customer_not_cancelled) from trips_details where customer_not_cancelled = 1;

-- average distance per trip
select sum(distance)/count(distance)as average_distance_per_trip from trips;

-- average fare per trip 
select sum(fare)/count(fare)as Average_fare_per_trip from trips;

-- which is the most used payment method 
select p.method, count(t.faremethod) as times_used from trips t join payment p on p.id = t.faremethod group by p.method order by times_used desc; 

-- top 5 earning drivers
select driverid, count(driverid) as trips from trips group by driverid order by trips desc limit 5;

-- which area got highest trips in which duration
select d.duration , count(t.duration) as max from trips t 
join duration d 
on d.duration = t.duration 
group by duration order by max desc limit 1; 

-- which two locations had the most trips
select l.assembly1, count(t.loc_from) as highest_trip from trips t  join loc l on t.loc_from = l.id group by l.assembly1 order by highest_trip desc limit 2;

-- which duration had more trips
select d.duration, count(t.tripid)as total_trips from trips t join  duration d on t.duration  = d.id  group by d.duration order by total_trips desc limit 5;

-- which driver , customer pair had more orders
SELECT driverid, custid, COUNT(tripid) AS OrderCount FROM trips GROUP BY driverid, custid ORDER BY OrderCount DESC;

select t.custid, l.assembly1 from trips t join loc l on t.loc_from = l.id; 

-- procedure --
-- Show customer by Pick up location --
DELIMITER //

CREATE PROCEDURE show_customer_by_pickup_location (IN location VARCHAR(35))
BEGIN
    SELECT t.custid
    FROM trips t
    JOIN loc l ON t.loc_from = l.id
    WHERE l.assembly1 = location;
END //
DELIMITER ;

-- Show customer by drop off location --
DELIMITER //
CREATE PROCEDURE show_customer_by_dropoff_location (IN location VARCHAR(35))
BEGIN
    SELECT t.custid
    FROM trips t
    JOIN loc l ON t.loc_to = l.id
    WHERE l.assembly1 = location;
END //
DELIMITER ;


-- trigger for adding if any new customer entry is recorded

DELIMITER $$
CREATE TRIGGER after_customer_insert
AFTER INSERT ON trips
FOR EACH ROW
BEGIN
    INSERT INTO new_trips (tripid ,faremethod ,fare ,loc_from ,loc_to ,driverid ,custid ,distance ,duration )
    VALUES (new.tripid ,new.faremethod ,new.fare ,new.loc_from ,new.loc_to ,new.driverid ,new.custid ,new.distance ,new.duration);
END;
$$
