import psycopg2

conn = psycopg2.connect("host=localhost dbname=gis  user=gis")
cur = conn.cursor()

cur.execute("DROP SCHEMA IF EXISTS tmr CASCADE")
cur.execute("CREATE SCHEMA tmr")
cur.execute("CREATE table tmr.roads (id serial primary key, section text, code text, description text)")
cur.execute("CREATE table tmr.points (id serial primary key, road_id integer, tdist float, geog geography(point, 4283))")
cur.execute("CREATE table tmr.segments ( id serial primary key, p1_id integer, p2_id integer, geog geography(linestring, 4283))")
cur.execute("CREATE INDEX idx_points_geog on tmr.points USING gist(geog)")
cur.execute("CREATE INDEX idx_segments_geog on tmr.segments USING gist(geog)")

cur.close()
conn.commit()

infile = "sort.txt"

n = 0
osection = ""
ocode = ""
odesc = ""
opt_id = 0
olat = 0.0
olon = 0.0
odist = -1000.0
road_id = 0
pt_id = 0
cur = conn.cursor()

with open(infile, 'r') as f:
    for line in f:
        rec = line.strip().split(',')
        section,code,dist,lat,lon,desc,aadt,cat = rec
        dist = float(dist)
        lon = float(lon)
        lat = float(lat)
        new = 0

        if section != osection or code != ocode or desc != odesc:
            sql = """
                insert into tmr.roads (section,code,description) values (%s,%s,%s) 
                returning id;
                """
            cur.execute(sql, (section,code,desc))
            road_id = cur.fetchone()[0]
            print('Section %s %s %s %s' % (road_id,section,code,desc))
            osection = section
            ocode = code
            odesc = desc
            new = 1

        sql = """
            insert into tmr.points (road_id, tdist, geog) 
            values (%s,%s,ST_SetSRID(ST_Point(%s, %s), 4283)::geography ) 
            returning id;
            """
        cur.execute(sql, (road_id,dist,lon,lat))
        pt_id = cur.fetchone()[0]

        if not new and (dist-odist) > (15.0/1000.0):
            new = 1
            print("    skip %s - %s" % (odist,dist))

        if not new:
            sql = """
                insert into tmr.segments (p1_id, p2_id, geog)
                    values(%s,%s,ST_SetSRID(ST_Makeline(ST_Point(%s,%s),ST_Point(%s,%s)), 4283)::geography )
                """ 
            cur.execute(sql,(opt_id,pt_id,olon,olat,lon,lat))

        opt_id = pt_id
        olat = lat
        olon = lon
        odist = dist
        n += 1


    cur.close()
    conn.commit()
    conn.close()
    print(n)

