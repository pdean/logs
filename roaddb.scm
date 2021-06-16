(import postgresql (chicken io) (chicken string) (chicken format) srfi-1 )

;(define gis (connect '((dbname . "gis") (host . alarmpi))))
(define gis (connect '((dbname . "gis") (user . "gis"))))

(query gis 
       "DROP SCHEMA IF EXISTS tmr1 CASCADE" )
(query gis 
       "CREATE SCHEMA tmr1")
(query gis 
       "CREATE table tmr1.roads (id serial primary key, section text, code text, description text)")
(query gis 
       "CREATE table tmr1.points (
        id serial primary key, road_id integer, 
        tdist float, geog geography(point, 4283))")
(query gis 
       "CREATE table tmr1.segments (
        id serial primary key,
        p1_id integer, p2_id integer,
        geog geography(linestring, 4283))")
(query gis 
       "CREATE INDEX idx_points_geog on tmr1.points USING gist(geog)")
(query gis 
       "CREATE INDEX idx_segments_geog on tmr1.segments USING gist(geog)")

(define infile "sort.txt" )

(with-input-from-file infile 
  (lambda () 
    (let ((n 0)
          (osection "")
          (ocode "")
          (odesc "")
          (opt_id 0)
          (olat 0.0)
          (olon 0.0)
          (odist -1000.0)
          (road_id 0)
          (pt_id 0))
      (query gis "BEGIN")
      (let loop ((line (read-line)))
        (if (not (eof-object? line))
          (begin
            (let* ((data    (string-split line ","))
                   (section (first data))
                   (code    (second data))
                   (dist    (string->number (third data)))
                   (lat     (string->number (fourth data)))
                   (lon     (string->number (fifth data)))
                   (desc    (sixth data))
                   (new #f))

              (if (or (not (string=? section osection))
                      (not (string=? code ocode))
                      (not (string=? desc odesc)))
                (begin
                  (set! road_id (value-at (query gis
                      "insert into tmr1.roads (section, code, description) 
                         values ($1, $2, $3) returning id" section code desc)))
                  (printf "Section ~A ~A ~A ~A~%" road_id section code desc)
                  (set! osection section)
                  (set! ocode code)
                  (set! odesc desc)
                  (set! new #t)))

              (set! pt_id (value-at (query gis
                    "insert into tmr1.points (road_id, tdist, geog)
                     values ($1, $2, ST_SetSRID(ST_Point($3, $4), 4283)::geography )
                     returning id" road_id dist lon lat)))
              
              (if (and (not new)
                       (> (- dist odist) (/ 15.0 1000.0)))
                (begin
                  (set! new #t)
                  (printf "    skip ~A - ~A~%" odist dist)))

              (if (not new)
                (query gis
                  "insert into tmr1.segments (p1_id, p2_id, geog)
                    values($1, $2, ST_SetSRID(ST_Makeline(ST_Point($3,$4),ST_Point($5,$6)), 4283)::geography )" 
                    opt_id pt_id olon olat lon lat))

              (set! opt_id pt_id)
              (set! olat lat)
              (set! olon lon)
              (set! odist dist)
              (set! n (add1 n))

              ;(if (= (remainder n 100000) 0)
               ; (exit))
            (loop (read-line))))))
      
      (query gis "COMMIT")
      (print n))))


