# Minnesota Location Converter 

This project accepts files containing road and distance measurements, then uses PostGIS in combination 
with Minnesota Shapefile data to calculate latitude and longitude points for each event, writing them 
out to a file.

Initially, the source data will be derived from DPS crash data, but ultimately, any Minnesota data 
that uses these Minnesota shapefiles as location references could be used.