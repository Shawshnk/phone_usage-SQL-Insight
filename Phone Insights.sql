SELECT TOP (1000) [User_ID]
      ,[Age]
      ,[Gender]
      ,[Location]
      ,[Phone_Brand]
      ,[OS]
      ,[Screen_Time_hrs_day]
      ,[Data_Usage_GB_month]
      ,[Calls_Duration_mins_day]
      ,[Number_of_Apps_Installed]
      ,[Social_Media_Time_hrs_day]
      ,[E_commerce_Spend_INR_month]
      ,[Streaming_Time_hrs_day]
      ,[Gaming_Time_hrs_day]
      ,[Monthly_Recharge_Cost_INR]
      ,[Primary_Use]
  FROM [SQL-Project].[dbo].[phone_usage_india]
 --What is the average screen time per day, broken down by age group?

SELECT
    CASE
        WHEN Age BETWEEN 15 AND 24 THEN 'Young People(15-24)'  
        WHEN Age BETWEEN 25 AND 34 THEN 'Young Adults(25-34)'
        WHEN Age BETWEEN 35 AND 44 THEN 'Adults(35-44)'
        ELSE 'Senior Citizen'
    END AS AgeGroup,
    round(AVG(Screen_Time_hrs_day),2) AS AverageScreenTime
FROM
    [SQL-Project].[dbo].[phone_usage_india]
GROUP BY
    CASE
        WHEN Age BETWEEN 15 AND 24 THEN 'Young People(15-24)' 
        WHEN Age BETWEEN 25 AND 34 THEN 'Young Adults(25-34)'
        WHEN Age BETWEEN 35 AND 44 THEN 'Adults(35-44)'
        ELSE 'Senior Citizen'
    END
ORDER BY
    AgeGroup;

--What is the distribution of primary use among users?

select count(*) as Users, Primary_Use
from  [SQL-Project].[dbo].[phone_usage_india]
group by Primary_Use
order by Users desc

--  Is there a correlation between data usage and streaming time?

select corr(Screen_Time_hrs_day,Data_Usage_GB_month) as CorrelationCoff
from  [SQL-Project].[dbo].[phone_usage_india]

--What is the average e-commerce spend by phone brand?

select sum(E_commerce_Spend_INR_month) as Spend_INR,
Phone_Brand
from [SQL-Project].[dbo].[phone_usage_india]
group by Phone_Brand
order by Spend_INR desc

-- What is the average monthly recharge cost by location?

select avg(Monthly_Recharge_Cost_INR) as Avg_Monthly_Recharge, Location
from [SQL-Project].[dbo].[phone_usage_india]
group by Location
order by Avg_Monthly_Recharge desc

-- Find the users whose monthly e-commerce spend is 
--above the average e-commerce spend and show their primary use for the device

with Avg_monthly_spend as(

select avg(E_commerce_Spend_INR_month) as Avg_Spend_INR
from [SQL-Project].[dbo].[phone_usage_india]

)
select distinct(ps.User_ID), ps.E_commerce_Spend_INR_month, ps.Primary_Use 
from [SQL-Project].[dbo].[phone_usage_india] ps , Avg_monthly_spend av
where ps.E_commerce_Spend_INR_month > av.Avg_Spend_INR

-- Find the top 3 phone brands with the highest total call duration.

with Highest_call_duration
as
(
select round(max([Calls_Duration_mins_day]),2) as Call_Duration_in_mins, [Phone_Brand]
from [SQL-Project].[dbo].[phone_usage_india]
group by [Phone_Brand]
)
select top 3 Call_Duration_in_mins, [Phone_Brand] from Highest_call_duration
order by Call_Duration_in_mins desc 

--For each user, show their data usage, the average data usage for their age group, 
--and the difference between their usage and the average


with AgeGroup
as
(
select Age , avg([Data_Usage_GB_month]) over(partition by Age) as DataUsage_by_age
from [SQL-Project].[dbo].[phone_usage_india]
)

select ps.[User_ID], ps.Age, ps.[Data_Usage_GB_month] , ps.[Data_Usage_GB_month]- ag.DataUsage_by_age as Diff_data_usage
from  [SQL-Project].[dbo].[phone_usage_india] ps
join 
AgeGroup ag 
on ag.Age = ps.Age

-- Rank users within each location based on their screen time, showing their rank, location, and screen time

