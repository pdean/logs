
create or replace view tmr1.pts as
    select p.id, r.section, r.code, r.description,
        p.tdist, p.geog
    from tmr1.points as p
    join tmr1.roads as r on (r.id = p.road_id);


create or replace view tmr1.segs as
    select s.id, s.geog, p1.tdist as tstart, p2.tdist as tend,
           r.section, r.code, r.description
    from tmr1.segments as s
    join tmr1.points as p1 on (s.p1_id = p1.id)
    join tmr1.points as p2 on (s.p2_id = p2.id)
    join tmr1.roads  as r  on (p2.road_id = r.id);
