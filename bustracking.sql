--Bus Tracking system
create table if not exists driver(
driver_id varchar(70) primary key,
driver_name varchar(50),
phone_no varchar(10),
status varchar(20)
);

create table if not exists routes(
route_id int primary key,
start_point varchar(100),
end_point varchar(100),
distance real
);

create table if not exists currentlocation(
location_id int primary key,
latitude varchar(100),
longitude varchar(100),
speed real,
timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

create table if not exists bus(
bus_id varchar(50) primary key,
bus_status varchar(20) not null,
driver_id varchar(70),
route_id int,
location_id int,
foreign key (driver_id) references driver (driver_id),
foreign key (route_id) references routes (route_id),
foreign key (location_id) references currentlocation (location_id)
);


insert into driver (driver_id, driver_name, phone_no, status) values
('123', 'Ram Bahadur Thapa', '9812345670', 'Active'),
('234', 'Suresh Gurung', '9812345671', 'Active'),
('345', 'Kamal Tamang', '9812345672', 'Active'),
('456', 'Dipak Rai', '9812345673', 'Inactive'),
('567', 'Bikash Shrestha', '9812345674', 'Active'),
('678', 'Raju Magar', '9812345675', 'Active'),
('789', 'Prakash Lama', '9812345676', 'Active');

insert into routes (route_id, start_point, end_point, distance) values
(1, 'Kathmandu', 'Pokhara', 200),
(2, 'Kathmandu', 'Chitwan', 150),
(3, 'Pokhara', 'Butwal', 160),
(4, 'Kathmandu', 'Dharan', 380),
(5, 'Chitwan', 'Lumbini', 170),
(6, 'Pokhara', 'Baglung', 70),
(7, 'Kathmandu', 'Hetauda', 90);

insert into currentlocation (location_id, latitude, longitude, speed) values
(8, '27.7172', '85.3240', 45),
(9, '27.6710', '85.4298', 40),
(10, '28.2096', '83.9856', 50),
(11, '27.5291', '84.3542', 35),
(12, '27.7008', '85.3001', 30),
(13, '28.2380', '83.9956', 55),
(14, '27.6833', '84.4333', 42);

insert into bus (bus_id, bus_status, driver_id, route_id, location_id) values
('BA 2 KHA 3456', 'Running', '123', 1, 8),
('BA 3 KHA 1123', 'Running', '234', 2, 9),
('GA 1 KHA 7788', 'Running', '345', 3, 10),
('BA 4 KHA 5566', 'Maintenance', '456', 4, 11),
('NA 1 KHA 9988', 'Running', '567', 5, 12),
('GA 2 KHA 4433', 'Running', '678', 6, 13),
('BA 5 KHA 2211', 'Running', '789', 7, 14);

update bus set bus_status='Rest' where route_id='1';
select * from bus;
alter table bus rename column time to type_of; 
alter table bus add column time varchar(10);
ALTER TABLE currentlocation ALTER COLUMN speed TYPE real;
ALTER TABLE currentlocation ALTER COLUMN speed TYPE int;
alter table currentlocation add constraint chk_speed check(speed<100);

-- users: super(admin) and sub(sub) , data_viewer(view),data_editor(edit)
CREATE USER super WITH PASSWORD 'admin';
CREATE USER sub WITH PASSWORD 'sub';

GRANT INSERT, UPDATE, DELETE,SELECT
ON driver, routes, currentlocation, bus
TO super;

Grant select 
on driver, routes, currentlocation, bus 
to sub;
--C:\Program Files\PostgreSQL\17\pgAdmin 4\runtime>psql -U data_editor -d "Bus Tracking " -h localhost -W

GRANT SELECT ON view_driver, view_routes, view_currentlocation, view_bus TO sub;
REVOKE SELECT ON driver, routes, currentlocation, bus FROM data_viewer;

--trigger for bus table
create table if not exists bus_backup(
bus_id varchar(50),
bus_status varchar(20),
driver_id varchar(70),
route_id int,
location_id int,
operation varchar(10),
backup_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

create or replace function bus_changes()
returns trigger as $$
begin

if TG_OP = 'INSERT' then
    insert into bus_backup values
    (NEW.bus_id,NEW.bus_status,NEW.driver_id,NEW.route_id,NEW.location_id,'INSERT',CURRENT_TIMESTAMP);
    return NEW;

elsif TG_OP = 'UPDATE' then
    insert into bus_backup values
    (NEW.bus_id,NEW.bus_status,NEW.driver_id,NEW.route_id,NEW.location_id,'UPDATE',CURRENT_TIMESTAMP);
    return NEW;

elsif TG_OP = 'DELETE' then
    insert into bus_backup values
    (OLD.bus_id,OLD.bus_status,OLD.driver_id,OLD.route_id,OLD.location_id,'DELETE',CURRENT_TIMESTAMP);
    return OLD;

end if;

end;
$$ language plpgsql;

create trigger bus_trigger
after insert or update or delete
on bus
for each row
execute function bus_changes();


--verifying triggers
insert into bus values ('BA 6 KHA 7777','Running','123',1,8);
select * from bus_backup;
update bus set bus_status='Rest' where route_id='1';
delete from bus where driver_id='123';
select * from bus;

--trigger for routes table
create table if not exists routes_backup(
route_id int,
start_point varchar(100),
end_point varchar(100),
distance real,
operation varchar(10),
backup_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

create or replace function routes_changes()
returns trigger as $$
begin

if TG_OP = 'INSERT' then
    insert into routes_backup values
    (NEW.route_id,NEW.start_point,NEW.end_point,NEW.distance,'INSERT',CURRENT_TIMESTAMP);
    return NEW;

elsif TG_OP = 'UPDATE' then
    insert into routes_backup values
    (NEW.route_id,NEW.start_point,NEW.end_point,NEW.distance,'UPDATE',CURRENT_TIMESTAMP);
    return NEW;

elsif TG_OP = 'DELETE' then
    insert into routes_backup values
    (OLD.route_id,OLD.start_point,OLD.end_point,OLD.distance,'DELETE',CURRENT_TIMESTAMP);
    return OLD;

end if;

end;
$$ language plpgsql;

create trigger routes_trigger
after insert or update or delete
on routes
for each row
execute function routes_changes();

--trigger for currentlocation table
create table if not exists location_backup(
location_id int,
latitude varchar(100),
longitude varchar(100),
speed real,
operation varchar(10),
backup_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
create or replace function location_changes()
returns trigger as $$
begin

if TG_OP = 'INSERT' then
    insert into location_backup values
    (NEW.location_id,NEW.latitude,NEW.longitude,NEW.speed,'INSERT',CURRENT_TIMESTAMP);
    return NEW;

elsif TG_OP = 'UPDATE' then
    insert into location_backup values
    (NEW.location_id,NEW.latitude,NEW.longitude,NEW.speed,'UPDATE',CURRENT_TIMESTAMP);
    return NEW;

elsif TG_OP = 'DELETE' then
    insert into location_backup values
    (OLD.location_id,OLD.latitude,OLD.longitude,OLD.speed,'DELETE',CURRENT_TIMESTAMP);
    return OLD;

end if;

end;
$$ language plpgsql;

create trigger location_trigger
after insert or update or delete
on currentlocation
for each row
execute function location_changes();

--trigger for driver table
create table if not exists driver_backup(
driver_id varchar(70),
driver_name varchar(50),
phone_no varchar(10),
status varchar(20),
operation varchar(10),
backup_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

create or replace function driver_changes()
returns trigger as $$
begin

if TG_OP = 'INSERT' then
    insert into driver_backup values
    (NEW.driver_id,NEW.driver_name,NEW.phone_no,NEW.status,'INSERT',CURRENT_TIMESTAMP);
    return NEW;

elsif TG_OP = 'UPDATE' then
    insert into driver_backup values
    (NEW.driver_id,NEW.driver_name,NEW.phone_no,NEW.status,'UPDATE',CURRENT_TIMESTAMP);
    return NEW;

elsif TG_OP = 'DELETE' then
    insert into driver_backup values
    (OLD.driver_id,OLD.driver_name,OLD.phone_no,OLD.status,'DELETE',CURRENT_TIMESTAMP);
    return OLD;

end if;

end;
$$ language plpgsql;
create trigger driver_trigger
after insert or update or delete
on driver
for each row
execute function driver_changes();

--verify
select * from driver;
insert into driver (driver_id, driver_name, phone_no, status) values
('153', 'Ram Bahadur Karki', '9812342220', 'Leave');
select * from driver_backup;
delete from driver where driver_id='153';

--views
-- Create a view for drivers
CREATE VIEW view_driver AS
SELECT * FROM driver;

-- Create a view for routes
CREATE VIEW view_routes AS
SELECT * FROM routes;

-- Create a view for current location
CREATE VIEW view_currentlocation AS
SELECT * FROM currentlocation;

-- Create a view for bus
CREATE VIEW view_bus AS
SELECT * FROM bus;



--join query
select * from bus cross join driver;

select d.driver_name,l.speed,b.bus_id from driver as d join bus as b on b.driver_id=d.driver_id natural join currentlocation as l ;

