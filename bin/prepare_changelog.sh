changelog=$(sed -E -n '2,/^\* [0-9]+\.[0-9]+\.[0-9]+/ p' CHANGELOG.txt | sed '$d')
changelog="${changelog//'::'/'@'}"
changelog="${changelog//'%'/'%25'}"
changelog="${changelog//$'\n'/'%0A'}"
echo "${changelog//$'\r'/'%0D'}"
