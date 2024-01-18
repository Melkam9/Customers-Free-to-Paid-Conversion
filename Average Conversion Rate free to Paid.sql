use db_course_conversions;

Select 
round(count(first_date_purchased) / count(first_date_watched) * 100, 2) as Conversion_Rate, 
-- The following code retrieves the average number of days customers take to access the material
  round(sum(days_diff_reg_watch) / count(days_diff_reg_watch), 2)as Average_Duration_Engagement,
  -- The following code is used to determine the average day it takes for customers to transition from free to paid version
    round(sum(days_diff_watch_purch)/ count(days_diff_watch_purch), 2) as Ave_Duration_Purchase
    from 
	(SELECT 
    e.student_id,
    i.date_registered,
    -- Using Min function is used to retrieve the earliest date
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS days_diff_reg_watch,
    DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS days_diff_watch_purch
            FROM
    student_engagement e
        JOIN
    student_info i ON e.student_id = i.student_id
        LEFT JOIN
    student_purchases p ON e.student_id = p.student_id
    group by e.student_id
    -- Placing the followng condition is neccessary inorder to filter out customers that have purchased prior to watching the free
    HAVING first_date_purchased IS NULL
    OR first_date_watched <= first_date_purchased 
    order by days_diff_watch_purch Desc, days_diff_reg_watch desc) as b ;
    