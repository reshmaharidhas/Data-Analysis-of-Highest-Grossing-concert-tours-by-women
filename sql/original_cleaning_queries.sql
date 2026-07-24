-- Fetch all columns to display from the table 'female_singer_concerts'.
SELECT * FROM female_singer_concerts;
-- Creating staging table 
CREATE TABLE female_singer_concerts_cleaned AS SELECT * FROM female_singer_concerts;
-- Display data types of each column in the staging table.
SHOW COLUMNS FROM female_singer_concerts_cleaned;
-- Display the staging table.
SELECT * FROM female_singer_concerts_cleaned;
-- Finding count of rows in the table.
SELECT COUNT(*) FROM female_singer_concerts_cleaned;  -- 18 rows
-- Checking for duplicates.
SELECT Artist, COUNT(*) OVER(PARTITION BY Artist,`Tour title`) FROM female_singer_concerts_cleaned;
-- Checking for duplicate data in the 'Tour title'
SELECT `Tour title`,COUNT(`Tour title`) FROM female_singer_concerts_cleaned GROUP BY `Tour title` HAVING COUNT(`Tour title`)>1;
-- Finding duplicate data in 'Rank' column.
WITH RankDuplicateCTE AS (SELECT `Rank`,
	ROW_NUMBER() OVER(PARTITION BY `Rank`) AS rank_duplicate,
	`Tour Title` FROM female_singer_concerts_cleaned)
SELECT * FROM RankDuplicateCTE WHERE rank_duplicate>1;

-- Data cleaning begins
-- Dropping the column 'Ref.' from table.
ALTER TABLE female_singer_concerts_cleaned DROP COLUMN `Ref.`;
SELECT * FROM female_singer_concerts_cleaned LIMIT 5;
-- Changing name of columns.
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `Rank` TO `rank_of_artist`;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `All Time Peak` TO all_time_peak;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `Peak` TO `peak`;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `Shows` TO `number_of_shows`;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN Artist TO artist;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `ActualÂ gross` TO actual_gross;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `AdjustedÂ gross (in 2022 dollars)` TO `adjusted_gross_2022_usd`;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `Tour title` TO `tour_title`;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `Year(s)` to year;
ALTER TABLE female_singer_concerts_cleaned RENAME COLUMN `Average gross` to average_gross;
SELECT * FROM female_singer_concerts_cleaned LIMIT 5;
-- Removing irregularities
UPDATE female_singer_concerts_cleaned SET `rank_of_artist`=TRIM(`rank_of_artist`);
SELECT * FROM female_singer_concerts_cleaned;
-- Cleaning string data in column and comparing it with old and new data
SELECT peak,SUBSTRING_INDEX(peak,"[",1) FROM female_singer_concerts_cleaned;
-- Permanently change it and display the table.
UPDATE female_singer_concerts_cleaned SET peak=SUBSTRING_INDEX(peak,"[",1);
SELECT * FROM female_singer_concerts_cleaned;
-- Cleaning string data in 'All Time Peak' and comparing it with existing data in that column.
SELECT all_time_peak,SUBSTRING_INDEX(all_time_peak,"[",1) FROM female_singer_concerts_cleaned;
-- Permanently change it and display the table.
UPDATE female_singer_concerts_cleaned SET all_time_peak = SUBSTRING_INDEX(all_time_peak,"[",1);
SELECT * FROM female_singer_concerts_cleaned;
-- Remove irrelevant symbols from column 'actual_gross'
SELECT actual_gross,REPLACE(REPLACE(actual_gross,"$",""),",","") FROM female_singer_concerts_cleaned;
UPDATE female_singer_concerts_cleaned SET actual_gross=REPLACE(REPLACE(actual_gross,"$",""),",","");
SELECT * FROM female_singer_concerts_cleaned;
SELECT actual_gross,SUBSTRING_INDEX(actual_gross,"[",1) FROM female_singer_concerts_cleaned;
UPDATE female_singer_concerts_cleaned SET actual_gross=SUBSTRING_INDEX(actual_gross,"[",1);
SELECT * FROM female_singer_concerts_cleaned;
-- Removing irrelevant symbols in column 'adjusted_gross_2022_usd'
SELECT adjusted_gross_2022_usd,REPLACE(REPLACE(adjusted_gross_2022_usd,"$",""),",","") FROM female_singer_concerts_cleaned;
UPDATE female_singer_concerts_cleaned SET adjusted_gross_2022_usd=REPLACE(REPLACE(adjusted_gross_2022_usd,"$",""),",","");
SELECT * FROM female_singer_concerts_cleaned;
SELECT artist,REPLACE(artist,"Ã©","e") FROM female_singer_concerts_cleaned;
UPDATE female_singer_concerts_cleaned SET artist=REPLACE(artist,"Ã©","e");
SELECT * FROM female_singer_concerts_cleaned;
-- Remove irrelevant symbols from data in the column 'tour_title'.
SELECT tour_title,SUBSTRING_INDEX(REPLACE(tour_title,"*",""),"â€",1) FROM female_singer_concerts_cleaned;
UPDATE female_singer_concerts_cleaned SET tour_title=TRIM(SUBSTRING_INDEX(REPLACE(tour_title,"*",""),"â€",1));
SELECT * FROM female_singer_concerts_cleaned;
-- Removing irrelevant symbols from data in the column 'year'.
SELECT year,REPLACE(year,"â€“","-") FROM female_singer_concerts_cleaned;
UPDATE female_singer_concerts_cleaned SET year=REPLACE(year,"â€“","-");
-- Removing irrelevant symbols from the column 'average_gross'.
SELECT average_gross,REPLACE(REPLACE(average_gross,"$",""),",","") FROM female_singer_concerts_cleaned;
UPDATE female_singer_concerts_cleaned SET average_gross=REPLACE(REPLACE(average_gross,"$",""),",","");
SELECT * FROM female_singer_concerts_cleaned;
-- Trimming extra spaces around data in all columns.
UPDATE female_singer_concerts_cleaned SET peak=TRIM(peak);
UPDATE female_singer_concerts_cleaned SET all_time_peak=TRIM(all_time_peak);
UPDATE female_singer_concerts_cleaned SET actual_gross=TRIM(actual_gross);
UPDATE female_singer_concerts_cleaned SET adjusted_gross_2022_usd=TRIM(adjusted_gross_2022_usd);
UPDATE female_singer_concerts_cleaned SET artist=TRIM(artist);
UPDATE female_singer_concerts_cleaned SET tour_title=TRIM(tour_title);
UPDATE female_singer_concerts_cleaned SET year=TRIM(year);
UPDATE female_singer_concerts_cleaned SET number_of_shows=TRIM(number_of_shows);
UPDATE female_singer_concerts_cleaned SET average_gross=TRIM(average_gross);
-- Converting datatype of columns from text to integer.
SELECT rank_of_artist,tour_title,peak,REPLACE(peak,"",NULL) FROM female_singer_concerts_cleaned WHERE peak LIKE '';
UPDATE female_singer_concerts_cleaned SET peak=REPLACE(peak,"",NULL) WHERE peak LIKE '';
ALTER TABLE female_singer_concerts_cleaned MODIFY peak INT;
SHOW COLUMNS FROM female_singer_concerts_cleaned;
-- Converting datatype of column 'all_time_peak' to integer.
SELECT rank_of_artist,tour_title,all_time_peak,REPLACE(all_time_peak,"",NULL) FROM female_singer_concerts_cleaned WHERE all_time_peak LIKE '';
UPDATE female_singer_concerts_cleaned SET all_time_peak=REPLACE(all_time_peak,"",NULL) WHERE all_time_peak LIKE '';
ALTER TABLE female_singer_concerts_cleaned MODIFY all_time_peak INT;
SHOW COLUMNS FROM female_singer_concerts_cleaned;
-- Converting datatype of columns 'actual_gross', 'adjusted_gross_2022_usd', 'average_gross'
ALTER TABLE female_singer_concerts_cleaned MODIFY actual_gross INT;
ALTER TABLE female_singer_concerts_cleaned MODIFY adjusted_gross_2022_usd INT;
ALTER TABLE female_singer_concerts_cleaned MODIFY average_gross INT;
SHOW COLUMNS FROM female_singer_concerts_cleaned;
-- Creating new columns by splitting year
ALTER TABLE female_singer_concerts_cleaned ADD start_year INT;
ALTER TABLE female_singer_concerts_cleaned ADD end_year INT;
-- Update values in newly created columns.
UPDATE female_singer_concerts_cleaned SET start_year=LEFT(year,4);
UPDATE female_singer_concerts_cleaned SET end_year=RIGHT(year,4);
SELECT * FROM female_singer_concerts_cleaned;
-- Drop column 'year'
ALTER TABLE female_singer_concerts_cleaned DROP COLUMN year;
-- Change datatype of 'start_year' and 'end_year' columns.
ALTER TABLE female_singer_concerts_cleaned MODIFY start_year INT;
ALTER TABLE female_singer_concerts_cleaned MODIFY end_year INT;
-- Change incorrect rank_of_artist values.
UPDATE female_singer_concerts_cleaned SET rank_of_artist=8 WHERE tour_title LIKE 'Summer Carnival';
SELECT * FROM female_singer_concerts_cleaned;
-- Alter incorrect rank by continuing its continuity by filtering bunch of rows.
SELECT rank_of_artist,rank_of_artist-1 FROM female_singer_concerts_cleaned WHERE rank_of_artist>=12 AND rank_of_artist<=16;
UPDATE female_singer_concerts_cleaned SET rank_of_artist=rank_of_artist-1 WHERE rank_of_artist>=12 AND rank_of_artist<=16;
SELECT rank_of_artist,rank_of_artist-2 FROM female_singer_concerts_cleaned WHERE rank_of_artist>=18 AND rank_of_artist<=20;
UPDATE female_singer_concerts_cleaned SET rank_of_artist=rank_of_artist-2 WHERE rank_of_artist>=18 AND rank_of_artist<=20;
-- Create new column 'duration'
SELECT rank_of_artist,artist,tour_title,start_year,end_year,(end_year-start_year) AS concert_duration_in_years FROM female_singer_concerts_cleaned;
ALTER TABLE female_singer_concerts_cleaned ADD concert_duration_in_years INT;
UPDATE female_singer_concerts_cleaned SET concert_duration_in_years = (end_year-start_year);
SELECT * FROM female_singer_concerts_cleaned;
-- Cleaned dataset
SELECT * FROM female_singer_concerts_cleaned;
SHOW COLUMNS FROM female_singer_concerts_cleaned;
SELECT COUNT(*) FROM female_singer_concerts_cleaned;  -- 18 rows