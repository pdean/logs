file="Road location and traffic data.txt"

tail -n +2 "$file" |sort -o sort.txt -t ',' -k 1,1 -k 2,2 -k 3,3n
