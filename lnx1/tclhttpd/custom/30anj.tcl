
proc anj {sock lon1 lat1 lon2 lat2} {

    #scdbgen $sock $lon1 $lat1 $lon2 $lat2 staging anj17
    set schema qspatial
    set table survey_control_data_qld
    set where "mrkcnd_de='GOOD' and gda2020adj_nm ~ '^QLD ANJ'"
    scdbgen $sock $lon1 $lat1 $lon2 $lat2 \
        $schema $table shape $where
}
