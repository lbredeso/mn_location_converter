== Minnesota Location Converter 

This project accepts files containing road and distance measurements, then uses PostGIS in combination 
with Minnesota Shapefile data to calculate latitude and longitude points for each event, writing them 
out to a file.

Initially, the source data will be derived from DPS crash data, but ultimately, any Minnesota data 
that uses these Minnesota shapefiles as location references could be used.

== Getting Started
1.  Create your databases

    sudo su postgres
    psql template1
    
    create role mn_location_converter with createdb login password 'mn_location_converter';
    create database mn_location_converter_development owner mn_location_converter;
    create database mn_location_converter_test owner mn_location_converter;
    create database mn_location_converter_production owner mn_location_converter;
    
2.  Run the migrations

    rake db:migrate
    
3.  