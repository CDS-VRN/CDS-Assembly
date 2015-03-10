create schema risicokaart;

create table risicokaart.importlog (
	id serial primary key,
	
	log_time timestamp not null,
	
	exception_type character varying (20) not null,
	uri text not null,
	context text,
	cause text,
	
	resolved boolean not null
);

create table risicokaart.transportroutedelen (
	export_id serial primary key,
	bronhouder_id integer references manager.bronhouder(id),
	transportroute_id text not null,
	transportroutedeel_id text not null,
	create_time timestamp,
	export_time timestamp not null,
	update_time timestamp not null,
	retire_time timestamp
);

create table risicokaart.transportroutes (
	export_id serial primary key,
	bronhouder_id integer references manager.bronhouder(id),
	transportroute_id text not null,
	create_time timestamp,
	export_time timestamp not null,
	update_time timestamp not null,
	retire_time timestamp,
	
	contour_create_time timestamp,
	contour_export_time timestamp,
	contour_update_time timestamp,
	contour_retire_time timestamp
);

create or replace view bron.buisleidingen_transportroute as 
	select
		d.transportroute_id,
		greatest (
			coalesce(
				(select r.laatste_mutatiedatumtijd from bron.buisleidingen_transportrouterisico r where r.transportroute_id = d.transportroute_id),
				max(d.laatste_mutatiedatumtijd)
			),
			max(d.laatste_mutatiedatumtijd)
		) as laatste_mutatiedatumtijd,
		(
			select r.risicocontour10_6 from bron.buisleidingen_transportrouterisico r where r.transportroute_id = d.transportroute_id
		) as risicocontour10_6,
		max(d.job_id) as job_id
	from
		bron.buisleidingen_transportroutedeel d
	group by
		d.transportroute_id;
		
create table risicokaart.kwetsbaar_object (
	export_id serial primary key,
	bronhouder_id integer references manager.bronhouder(id),
	extern_id text not null,
	create_time timestamp,
	export_time timestamp not null,
	update_time timestamp not null,
	retire_time timestamp
);

create index on risicokaart.transportroutedelen using btree(bronhouder_id);
create index on risicokaart.transportroutedelen using btree(transportroute_id);
create index on risicokaart.transportroutedelen using btree(transportroutedeel_id);
create index on risicokaart.transportroutedelen using btree(create_time);
create index on risicokaart.transportroutedelen using btree(retire_time);

create index on risicokaart.transportroutes using btree(bronhouder_id);
create index on risicokaart.transportroutes using btree(transportroute_id);
create index on risicokaart.transportroutes using btree(create_time);
create index on risicokaart.transportroutes using btree(retire_time);

create index on risicokaart.kwetsbaar_object using btree(bronhouder_id);
create index on risicokaart.kwetsbaar_object using btree(extern_id);
create index on risicokaart.kwetsbaar_object using btree(create_time);
create index on risicokaart.kwetsbaar_object using btree(retire_time);

grant select, insert, update, delete on risicokaart.importlog to inspire;
grant select, insert, update, delete on risicokaart.transportroutedelen to inspire;
grant select, insert, update, delete on risicokaart.transportroutes to inspire;
grant select, insert, update, delete on risicokaart.kwetsbaar_object to inspire;

grant usage on sequence risicokaart.importlog_id_seq to inspire;
grant usage on sequence risicokaart.kwetsbaar_object_export_id_seq to inspire;
grant usage on sequence risicokaart.transportroutedelen_export_id_seq to inspire;
grant usage on sequence risicokaart.transportroutes_export_id_seq to inspire;


grant select on bron.buisleidingen_transportroute to inspire;

grant usage on schema risicokaart to inspire;