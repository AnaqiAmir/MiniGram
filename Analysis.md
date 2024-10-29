# MiniGram Analysis
This document details the queries that were used to answer the business questions that were presented. It also provide the outputs.

## Table of Contents
1. [Section 1: Basic Analytics](#section-1-basic-analytics)
    * [Question 1a: How many users are there?](#question-1a)
    * [Question 1b: How many posts are there?](#question-1b)
    * [Question 1c: How many photos do each user post on average?](#question-1c)
    * [Question 1d: How many likes do each photo gets on average?](#question-1d)
    * [Question 1e: How many comments do each photo gets on average?](#question-1e)
2. [Section 2: User Engagement](#section-2-user-engagement)
    * [Question 2a: Is there a pattern for user registration periods?](#question-2a)
    * [Question 2b: Which users are the most active? When are they the most active?](#question-2b)
    * [Question 2c: Which users are the most inactive? When are these inactive users mostly active?](#question-2c)
3. [Section 3: Posts and Content](#section-3-posts-and-content)
    * [Question 3a: What types of content typically gets the most engagement?](#question-3a)
    * [Question 3b: When is the ideal time for a user to post content for a better chance to get high amount of engagement?](#question-3b)
4. [Section 4: Influencers](#section-4-influencers)
    * [Question 4a: Find the difference between the types of posts that influencers post compared to non-influencers.](#question-4a)
    * [Question 4b: Find the difference in activity between influencers and non-influencers.](#question-4b)
    * [Question 4c: How do influencers impact other users' engagement on MiniGram?](#question-4c)
5. [Section 5: Bots](#section-5-bots)
    * [Question 5a: When are bots most active?](#question-5a)
    * [Question 5b: How much do bots impact the posts that they engage with?](#question-5b)
    * [Question 5c: Find which accounts (if any) implement the use of bots on their posts.](#question-5c)
6. [Section 6: Year by Year Analysis](#section-6-year-by-year-analysis)
    * [Question 6a: Compare the amount of photos/likes/comments from year to year](#question-6a)
    * [Question 6b: Is there an increase in the rate of user and content growth from year to year?](#question-6b)

## Section 1: Basic Analytics

### Question 1a
How many users are there?
```sql
-- a) How many users?
SELECT COUNT(*) FROM users;
```

![alt text](<Outputs/Q1a Output.png>)

There are 5000 users on MiniGram.

### Question 1b
How many posts are there?
```sql
-- b) How many posts?
SELECT COUNT(*) FROM photos;
```

![alt text](<Outputs/Q1b Output.png>)

There are 25,000 total photos on MiniGram.

### Question 1c
How many photos do each user post on average?
```sql
-- c) What is the average post per user?
SELECT (
	(SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users)
) AS avg_photo_per_user;

```

![alt text](<Outputs/Q1c Output.png>)

There are around 5 photos per user (ie the average user has posted 5 photos).

### Question 1d
How many likes do each photo gets on average?
```sql
-- d) What is the average amount of likes per post?
SELECT (
	(SELECT COUNT(*) FROM likes) / (SELECT COUNT(*) FROM photos)
) AS avg_likes_per_photo;
```

![alt text](<Outputs/Q1d Output.png>)

There are around 20 likes per photo.

### Question 1e
How many comments do each photo gets on average?
```sql
SELECT (
	(SELECT COUNT(*) FROM comments) / (SELECT COUNT(*) FROM photos)
) AS avg_comments_per_photo;
```

![alt text](<Outputs/Q1e Output.png>)

There are around 14 comments per photo.

## Section 2: User Engagement

### Question 2a
Is there a pattern for user registration periods?

To analyze this, we will take a look at the distribution of when users register for MiniGram based on different timings (year,month,day of week,hour).

```sql
-- User registrations by year
SELECT
	YEAR(created_at) AS year,
    COUNT(*) AS total
FROM users
GROUP BY year
ORDER BY year DESC;
```

![alt text](<Outputs/Question 2a-1 (Year) Output.png>)

```sql
-- User registrations by month
SELECT
	MONTHNAME(created_at) AS month,
    COUNT(*) AS total
FROM users
GROUP BY month
ORDER BY FIELD(MONTH,'January','February','March','April','May','June',
					 'July','August','September','October','November','December');
```

![alt text](<Outputs/Question 2a-2 (Month) Output.png>)

```sql
-- User registrations by day of week
SELECT
	DAYNAME(created_at) AS day_of_week,
    COUNT(*) AS total
FROM users
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
```

![alt text](<Outputs/Question 2a-3 (Day) Output.png>)

```sql
-- User registrations by hour
SELECT
	HOUR(created_at) AS hour,
    COUNT(*) AS total
FROM users
GROUP BY hour
ORDER BY hour;
```

![alt text](<Outputs/Question 2a-4 (Hour) Output.png>)

Key findings:
* Year:
    * 2020 had the most user registrations with 460 registrations.
    * 2015 had the lowest amount of user registration with only 416 registrations.
    * There is an average of 454.54 user registrations per year since the inception of MiniGram.
* Month:
    * The month of August had the most user registrations with 451 registrations.
    * The month of February had the lowest amount of user registration with only 359 registrations.
    * There is an average of 416.67 user registrations per "type" of month.
    * There is an average 37.88 user registrations per month since the inception of MiniGram.
* Day of week:
    * Saturdays had the most user registrations with 744 registrations.
    * Wednesdays had the lowest amount of user registration with only 637 registrations.
    * There is an average of 714.29 user registrations per day of week.
    * There is an average of 1.24 user registrations per day since the inception of MiniGram.
* Hour:
    * The hour of 11am had the most user registrations with 243 registrations.
    * The hour of 4pm had the lowest amount of user registration with only 179 registrations.
    * There is an average of 208.33 user registrations per hour of day.
    * There is an average of 0.05 user registrations per day since the inception of MiniGram.

### Question 2b
Which users are the most active? When are they the most active?

To calculate which users are the most active, we will be using these activity metrics:
* activity =  # of photos + # of likes + # of comments + # of followings
* activity_rate = (# of photos + # of likes + # of comments + # of followings) / # of days since the user registered

Then, active users will be defined as the top 5% of users with the highest metric scores.

To make the process easier, these views will be created with the dataset:
* `user_activities`: Table that stores the activity metrics of all users
* `active_users_by_activity`: Table that stores the top 5% of users with the highest activity score
* `active_users_by_activity_rate`: Table that stores the top 5% of users with the highest activity rate score
* `target_users`: Table that acts as a placeholder for easier querying process

These views will also be created to be used in Question 2c:
* `inactive_users_by_activity`: Table that stores the bottom 5% of users with the highest activity score
* `inactive_users_by_activity_rate`: Table that stores the bottom 5% of users with the highest activity rate score

```sql
-- User activities
CREATE VIEW user_activities AS (
	WITH user_photos AS (
		SELECT
			users.id,
            users.username,
			COUNT(photos.id) AS num_of_photos
		FROM users
		LEFT OUTER JOIN photos ON users.id = photos.user_id
		GROUP BY users.id, username
	),
    user_likes AS (
		SELECT
			id,
			username,
			COUNT(likes.photo_id) AS num_of_likes
		FROM users
		LEFT OUTER JOIN likes ON users.id = likes.user_id
		GROUP BY id, username
	),
    user_comments AS (
		SELECT
			users.id,
			username,
			COUNT(comments.id) AS num_of_comments
		FROM users
		LEFT OUTER JOIN comments ON users.id = comments.user_id
		GROUP BY users.id, username
	),
    user_followings AS (
		SELECT
			users.id,
			username,
			COUNT(follows.followee_id) AS num_of_followings
		FROM users
		LEFT OUTER JOIN follows ON users.id = follows.follower_id
		GROUP BY users.id, username
	)
    SELECT
		users.id,
		users.username,
        num_of_photos,
        num_of_likes,
        num_of_comments,
        num_of_followings,
        (num_of_photos + num_of_likes + num_of_comments + num_of_followings) AS activity,
        DATEDIFF("2025-01-01 00:00:00", users.created_at) AS days_on_minigram,
		(num_of_photos + num_of_likes + num_of_comments + num_of_followings) / DATEDIFF("2025-01-01 00:00:00", users.created_at) AS activity_rate
	FROM users
	JOIN user_photos ON users.id = user_photos.id
	JOIN user_likes ON users.id = user_likes.id
	JOIN user_comments ON users.id = user_comments.id
	JOIN user_followings ON users.id = user_followings.id
	GROUP BY users.id, username
	ORDER BY activity DESC
);
```

![alt text](<Outputs/Question 2b-1 (User Activities) Output.png>)

As seen above, the table displays each users number of photos, likes, comments, and followings as a way to measure activity on MiniGram. The total number of days that the user is on MiniGram is also displayed in the table which was used to calculate the user's activity rate.

Also, note that even though the table is ordered by the activity metric in descending order, the table does not accurately reflect user activity due to the presence of suspected bots; a cleaner version of the table can be seen in the next query.

```sql
-- Active users (by activity) (excludes bots)
CREATE VIEW active_users_by_activity AS (
	SELECT *
    FROM user_activities
    WHERE
		activity < 1000 AND  -- exclude bots
		activity >= 223  -- active users (~250 users)
	ORDER BY activity DESC
);
```

![alt text](<Outputs/Question 2b-2 (Activity) Output.png>)

The `active_users_by_activity` table seen above displays the top 5% of users who have the highest activity scores. These users are deemed "active users" by the activity metric.

An important thing to note is that this table is filtered such that only users with activity scores greater or equal to 223 are chosen. This is because 223 is the score such that it accounts for around 250 users (i.e. 5% of users). This method of choosing the activity (and activity rate) scores as a threshold to filter users can be seen in the upcoming queries as well.

The table also excluded users with an activity score that is greater than 1000 because after a deeper look into the data, those with that high of a score are most likely bots rather than real users. Therefore, this table purposely excludes them as to not skew the representation of active users.

Though this is a decent way to find out which users are "active users", the main flaw with this metric is that it does not account for the amount of time a user has been on MiniGram. Therefore, it's biased towards users who have been on MiniGram for a longer time as they have had more time to post, like, comment, or follow other users to increase their activity score.

To counter this flaw, the activity rate metric is calculated in the next query to get a better representation of "active users".

```sql
-- Active users (by activity rate) (excludes suspected bots and new users)
CREATE VIEW active_users_by_activity_rate AS (
	SELECT *
    FROM user_activities
    WHERE
		activity_rate >= 0.85 AND  -- active users
        activity < 1000 AND  -- exclude bots
        days_on_minigram > 10  -- exclude brand new users
	ORDER BY activity_rate DESC
);
```

![alt text](<Outputs/Question 2b-3 (Activity Rate) Output.png>)

The `active_users_by_activity_rate` table seen above gives the most "active users" by the activity rate metric. As we can see when compared to the `active_users_by_activity` table, this table gives a better representation of the data as it includes the temporal factor in user registrations.

Similar to the previous table however, this table also excludes the suspected bots on MiniGram and the threshold score is chosen as specified previously. An additional factor that this table has is that it also exclude new users on MiniGram (specificaly users who have only been on MiniGram for 10 days or less) as a low number of days on MiniGram might give an unrepresentative high score in the user's activity rate. The threshold for days_on_minigram can be played with and the chosen value of 10 days was decided through heuristics.

Now that we understand the structure of these tables, how "active users" are being defined, and which users are the most active based on the two metrics, we can find out when exactly these users are mostly active on MiniGram.

As mentioned earlier, we will be using the `target_users` table to do these analysis as it offers better readability and querying abilities:
```sql
-- Targetted users (a placeholder)
-- How to use:
-- SELECT * FROM [active_users_by_activity/active_users_by_activity_rate/inactive_users_by_activity/inactive_users_by_activity_rate]
DROP VIEW target_users;
CREATE VIEW target_users AS (
	SELECT * FROM active_users_by_activity  -- Please choose which view you would like to analyze and plug it here
);
```

Then, before we can conduct the analysis, please note that I am only looking at the distribution of these features by days rather than any other time periods/ranges to offer the marketing team a better focused effort to attract the target users.
```sql
-- Photos posted by target users by day
SELECT
	DAYNAME(photos.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN photos ON users.id = photos.user_id
WHERE users.id IN (SELECT id FROM target_users)
GROUP BY day
ORDER BY total DESC;

-- Likes posted by target users by day
SELECT
	DAYNAME(likes.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN likes ON users.id = likes.user_id
WHERE users.id IN (SELECT id FROM target_users)
GROUP BY day
ORDER BY total DESC;

-- Comments posted by target users by day
SELECT
	DAYNAME(comments.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN comments ON users.id = comments.user_id
WHERE users.id IN (SELECT id FROM target_users)
GROUP BY day
ORDER BY total DESC;

-- Follows by target users by day
SELECT
	DAYNAME(follows.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN follows ON users.id = follows.follower_id
WHERE users.id IN (SELECT id FROM target_users)
GROUP BY day
ORDER BY total DESC;
```

Here is the output of these queries in this order (top left: photos, top right: likes, bottoms left: comments, bottom right: follows]:

| photos | likes |
| ------ | ----- |
| comments | follows |

For activity:

![alt text](<Outputs/Question 2b-4 (A_Photos) Output.png>)  ![alt text](<Outputs/Question 2b-5 (A_Likes) Output.png>)

![alt text](<Outputs/Question 2b-6 (A_Comments) Output.png>)  ![alt text](<Outputs/Question 2b-7 (A_Follows) Output.png>)

For activity rate:

![alt text](<Outputs/Question 2b-8 (AR_Photos) Output.png>) ![alt text](<Outputs/Question 2b-9 (AR_Likes) Output.png>)

![alt text](<Outputs/Question 2b-10 (AR_Comments) Output.png>) ![alt text](<Outputs/Question 2b-11 (AR_Follows) Output.png>)

Key findings:
* The user with the highest activity is smithlaura.
* The user with the highest activity rate is laura73.
* By activity:
    * Active users post photos the most on Saturdays with a total of 231 photos and the least on Fridays with only 183 photos.
    * Active users like photos the most on Wednesdays with a total of 4370 likes and the least on Sundays with only 4129 likes.
    * Active users comment on photos the most on Wednesdays with a total of 3299 comments and the least on Saturdays with only 3157 comments.
    * Active users follow other users the most on Sundays with a total of 989 follows and the least on Thursdays with only 903 follows.
* By activity rate:
    * Active users post photos the most on Mondays with a total of 220 photos and the least on Thursdays with only 146 photos.
    * Active users like photos the most on Tuesdays with a total of 3194 likes and the least on Fridays with only 3033 likes.
    * Active users comment on photos the most on Fridays with a total of 2649 comments and the least on Wednesdays with only 2512 comments.
    * Active users follow other users the most on Thursdays with a total of 758 follows and the least on Sundays with only 686 follows.

### Question 2c
Which users are the most inactive? When are these inactive users mostly active?

While finding out which users are the most active and when they are active are important for optimal marketing, finding the converse types of users is just as important. By locating the inactive users and their activities, targetted marketing campaigns can be conducted in order to encourage these users to increase their activity on MiniGram and help boost the overall engagement with the product.

The process of finding these users are exactly the same as was seen in Question 2b, and therefore, I will only show the code to define the "inactive users".
```sql
-- Inactive users (by activity) (excludes bots)
CREATE VIEW inactive_users_by_activity AS (
	SELECT *
    FROM user_activities
    WHERE activity <= 144
    ORDER BY activity
);
```

![alt text](<Outputs/Question 2c-1  (Activity) Output.png>)

```sql
-- Inactive users (by activity rate)
CREATE VIEW inactive_users_by_activity_rate AS (
	SELECT *
    FROM user_activities
    WHERE activity_rate <= 0.045
    ORDER BY activity_rate
);
```

![alt text](<Outputs/Question 2c-2  (Activity Rate) Output.png>)

Note that there is no need to filter for bots in the case of inactive users because bots only affect the data with the high amount of likes that they produce. Therefore, when targetting users with a low number of likes, the bot factor is redundant.

Here is the output of these queries in this order (top left: photos, top right: likes, bottoms left: comments, bottom right: follows]:

| photos | likes |
| ------ | ----- |
| comments | follows |

For activity:

![alt text](<Outputs/Question 2c-3 (A_Photos) Output.png>) ![alt text](<Outputs/Question 2c-4 (A_Likes) Output.png>)

![alt text](<Outputs/Question 2c-5 (A_Comments) Output.png>) ![alt text](<Outputs/Question 2c-6 (A_Follows) Output.png>)

For activity rate:

![alt text](<Outputs/Question 2c-7 (AR_Photos) Output.png>) ![alt text](<Outputs/Question 2c-8 (AR_Likes) Output.png>)

![alt text](<Outputs/Question 2c-9 (AR_Comments) Output.png>) ![alt text](<Outputs/Question 2c-10 (AR_Follows) Output.png>)

Key findings:
* The user with the lowest activity is randy10.
* The user with the lowest activity rate is ihaney.
* By activity:
    * Inactive users post photos the most on Fridays with a total of 172 photos and the least on Saturdays with only 137 photos.
    * Inactive users like photos the most on Thursdays with a total of 2340 likes and the least on Wednesdays with only 2214 likes.
    * Inactive users comment on photos the most on Fridays with a total of 2040 comments and the least on Sundays with only 1949 comments.
    * Inactive users follow other users the most on Saturdays with a total of 553 follows and the least on Thursdays with only 501 follows.
* By activity rate:
    * Inactive users post photos the most on Thursdays with a total of 202 photos and the least on Fridays with only 161 photos.
    * Inactive users like photos the most on Saturdays with a total of 2792 likes and the least on Thursdays with only 2679 likes.
    * Inactive users comment on photos the most on Fridays with a total of 2421 comments and the least on Mondays with only 2302 comments.
    * Inactive users follow other users the most on Tuesdays with a total of 695 follows and the least on Fridays with only 608 follows.

## Section 3: Posts and Content

### Question 3a
What types of content typically gets the most engagement?

While we can find the count of how many times each tag is used on MiniGram, it is not relevant to the question at hand (or at least not very insightful). Instead, we will find the photos with the most engagement, and look at the tags that are associated with those specfic photos to better understand what types of content posted leads to a high engagement for the photo.

Define engagement as:

* engagement = # of likes + (# of comments)*1.5

where comments are worth more than likes.

Create a view that tallies up each photo's engagement.

```sql
-- Table that displays total engagement of photos
CREATE VIEW photo_engagements AS (
	WITH photo_likes AS (
		SELECT
			photos.id,
			COUNT(likes.photo_id) AS total_likes
		FROM photos
		LEFT JOIN likes ON photos.id = likes.photo_id
		GROUP BY photos.id
	),
	photo_comments AS (
		SELECT
			photos.id,
			COUNT(comments.photo_id) AS total_comments
		FROM photos
		LEFT JOIN comments ON photos.id = comments.photo_id
		GROUP BY photos.id
	)
	SELECT
		photo_likes.id AS photo_id,
		total_likes,
		total_comments,
		(total_likes + (1.5*total_comments)) AS engagement
	FROM photo_likes
	JOIN photo_comments ON photo_likes.id = photo_comments.id
	ORDER BY engagement DESC
);

SELECT * FROM photo_engagements;
```

![alt text](<Outputs/Question 3a-1 (Photo Engagements) Output.png>)

The view displays each photo's total likes, total comments, and the corresponding engagement associated with those metrics. Next, we will filter the photos in `photo_engagement` by finding the top 5% of photos and take a look at the tags that are associated with those highly engaged photos.

```sql
-- Query which tags are associated with the most engaged photos
WITH photos_with_most_engagements AS (  -- Filter to find photos with most engagements
	SELECT *
    FROM photo_engagements
    WHERE engagement >= 500 -- Around top 5% of photos
),
photo_to_tag_name AS (  -- Associating photos to their tags
	SELECT
		photo_tags.photo_id,
        tags.tag_name
	FROM photo_tags
    JOIN tags ON photo_tags.tag_id = tags.id
    HAVING photo_id IN (SELECT photo_id FROM photos_with_most_engagements)  -- Only look at photos with high engagement
)
SELECT
	tag_name,
    COUNT(*) AS total
FROM photo_to_tag_name
GROUP BY tag_name
ORDER BY total DESC;
```

![alt text](<Outputs/Question 3a-2 (Photo w Most Engagement) Output.png>)

Key findings:
* The top 3 tags associated with highly engaged photos are:
    * bestoftheday (14)
    * cute (10)
    * celebration (10)
    * This suggests that photos with positive tags are highly engaged with:
* 3 out of the top 8 tags are related to photography:
    * blackandwhite (9)
    * camera (8)
    * digitalmarketing (8)
* 3 out the top 12 are related to sports and movement with:
    * gym (8)
    * cardio (7)
    * biker (7)

### Question 3b
When is the ideal time for a user to post content for a better chance to get high amount of engagement?

Find at which hour of the day the top 5% of photos with the most engagement are posted.

```sql
WITH photo_with_most_engagements AS (  -- Filter to find photos with most engagements
	SELECT *
    FROM photo_engagements
    WHERE engagement >= 500
)
SELECT
	HOUR(photos.created_at) AS hour,
    COUNT(*) AS total
FROM photos
WHERE id IN (SELECT photo_id FROM photo_with_most_engagements)
GROUP BY hour
ORDER BY total DESC;
```

![alt text](<Outputs/Question 3b Output.png>)

As we can see, the best time to post a photo to get a high engagement is at 2am; while the worst time is at 12pm and 9pm.

Note: These hours intuitively does not make sense because the data is synthetic so it unfortunately does not reflect real world activities in this case.

## Section 4: Influencers

Before we begin to answer the questions, we will first find the influencers in MiniGram. Define influencers as users that have more than 10% of MiniGram's users as their followers.

Note: The definition of influencers can be changed if you wish to do so. A better definition of an influencer that can be used in the future is probably a combination of their follower-to-following ratios, the amount likes on their posts, and other factors as well.

```sql
-- Influencers are defined as users who have >10% of all users as their followers
CREATE VIEW influencers AS (
	SELECT
		users.id,
        users.username,
        users.created_at,
        COUNT(follows.followee_id) AS num_of_followers
	FROM users
	LEFT JOIN follows ON users.id = follows.followee_id
	GROUP BY users.id
	HAVING num_of_followers > (SELECT COUNT(*) FROM users)*0.1
	ORDER BY num_of_followers DESC
);
```

![alt text](<Outputs/Question 4-1 (Influencers) Output.png>)

```sql
SELECT COUNT(*) AS num_of_influencers
FROM (SELECT * FROM minigram_db.influencers) AS influencer_count;
```

![alt text](<Outputs/Question 4-2 (Count) Output.png>)

Based on our definition of influencers, we can see that there exists 135 influencers on MiniGram. We will use this view of influencers in the analysis throughout Question 4.

### Question 4a
Find the difference between the types of posts that influencers post compared to non-influencers.

To understand the difference between the types of posts between these two groups, lets take a look at the content (tags) of their respective photos.

```sql
-- Types of content for influencers
WITH influencer_photos AS (
	SELECT *
    FROM photos
    WHERE photos.user_id IN (SELECT id FROM influencers)
)
SELECT
	tags.tag_name,
    COUNT(*) AS total
FROM influencer_photos
JOIN photo_tags ON influencer_photos.id = photo_tags.photo_id
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tag_name
ORDER BY total DESC;
```

![alt text](<Outputs/Question 4a-1 (Influencers) Output.png>)

```sql
-- Types of content for non-influencers
WITH non_influencer_photos AS (
	SELECT *
    FROM photos
    WHERE photos.user_id NOT IN (SELECT id FROM influencers)
)
SELECT
	tags.tag_name,
    COUNT(*) AS total
FROM non_influencer_photos
JOIN photo_tags ON non_influencer_photos.id = photo_tags.photo_id
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tag_name
ORDER BY total DESC;
```

![alt text](<Outputs/Question 4a-2 (Non influencers) Output.png>)

Key findings:
* Influencers:
    * The tags bestoftheday, blackandwhite, comedy, quoteoftheday, cute are the top 5 tags that are used in content posted by influencers.
    * The most used tag by influencers is bestoftheday with 33 instances.
* Non-influencers:
    * The tags blackandwhite, photography, comedy, motivation, bestoftheday are the top 5 tags that are used in content posted by non-influencers.
    * The most used tag by non-influencers is blackandwhite with 751 instances.
* The tags bestoftheday, blackandwhite, and comedy are used substantially by both influencers and non-influencers alike.

### Question 4b
Find the difference in activity between influencers and non-influencers.

The difference in activity will be analyzed by looking at the groups' averages.

For activity:

```sql
-- Average activity of influencers
WITH influencer_activity AS (
	SELECT *
	FROM user_activities
	WHERE id IN (SELECT id FROM influencers)
)
SELECT AVG(activity) AS avg_influencer_activity
FROM influencer_activity;
```

![alt text](<Outputs/Question 4b-1 (Influencers A) Output.png>)

```sql
-- Average activity of non-influencers (with suspected bots)
WITH non_influencer_activity AS (
	SELECT *
    FROM user_activities
    WHERE id NOT IN (SELECT id FROM influencers)
)
SELECT AVG(activity) AS avg_non_influencer_activity
FROM non_influencer_activity;
```

![alt text](<Outputs/Question 4b-2 (Non-Influencers w Bots A) Output.png>)

```sql
-- Average activity of non-influencers (without suspected bots)
WITH non_influencer_activity AS (
	SELECT *
    FROM user_activities
    WHERE
		id NOT IN (SELECT id FROM influencers) AND
        activity<1000
)
SELECT AVG(activity) AS avg_non_influencer_activity
FROM non_influencer_activity;
```

![alt text](<Outputs/Question 4b-3 (Non Influencers w:o Bots A) Output.png>)

For activity rate:

```sql
-- Average activity rate of influencers
WITH influencer_activity_rate AS (
	SELECT *
	FROM user_activities
	WHERE id IN (SELECT id FROM influencers)
)
SELECT AVG(activity_rate) AS avg_influencer_activity_rate
FROM influencer_activity_rate;
```

![alt text](<Outputs/Question 4b-4 (Influencers AR) Output.png>)

```sql
-- Average activity rate of non-influencers (with suspected bots)
WITH non_influencer_activity_rate AS (
	SELECT *
	FROM user_activities
	WHERE id NOT IN (SELECT id FROM influencers)
)
SELECT AVG(activity_rate) AS avg_non_influencer_activity_rate
FROM non_influencer_activity_rate;
```

![alt text](<Outputs/Question 4b-5 (Non-Influencers w Bots AR) Output.png>)

```sql
-- Average activity rate of non-influencers (without suspected bots)
WITH non_influencer_activity_rate AS (
	SELECT *
	FROM user_activities
	WHERE
		id NOT IN (SELECT id FROM influencers) AND
        activity<1000
)
SELECT AVG(activity_rate) AS avg_non_influencer_activity_rate
FROM non_influencer_activity_rate;
```

![alt text](<Outputs/Question 4b-6 (Non-Influencers w:o Bots AR) Output.png>)

Key findings:

|  | Activity | Activity Rate |
|---|---|---|
|Influencers|179.62|0.46998||
|Non Influencers with Bots|196.15|0.47888|
|Non Influencers without Bots|180.92|0.45621|

Therefore, there is not a significant difference in both activity and activity rate between influencers and non-influencers (with and without suspected bots).

### Question 4c
How do influencers impact other users' engagement on MiniGram?

To investigate this, let's create two views that looks at how each user interacts and engages with another users activity. Specifically:
* engagement_by_user_influencer_pair: Shows how users engages with the activities of influencers.
* engagement_by_user_non_influencer_pair: Shows how users engages with the activities of other users whom are not influencers.

```sql
-- The engagement of each user-influencer pair
CREATE VIEW engagement_by_user_influencer_pair AS (
	WITH likes_by_user_influencer_pair AS (  -- find total likes from each user-to-influencer pair
		SELECT
			likes.user_id AS user_id,
			photos.user_id AS influencer_id,
			COUNT(*) AS total_likes
		FROM likes
		INNER JOIN photos ON likes.photo_id = photos.id
		GROUP BY user_id, influencer_id
		HAVING influencer_id IN (SELECT id FROM influencers)
	),
	comments_by_user_influencer_pair AS (  -- find total comments from each user-to-influencer pair
		SELECT
			comments.user_id AS user_id,
			photos.user_id AS influencer_id,
			COUNT(*) AS total_comments
		FROM comments
		INNER JOIN photos ON comments.photo_id = photos.id
		GROUP BY user_id, influencer_id
		HAVING influencer_id IN (SELECT id FROM influencers)
	),
	full_join AS (  -- union a left join and right join to emulate a full join
		SELECT
			l.user_id AS user_id,
			l.influencer_id AS influencer_id,
			l.total_likes AS total_likes,
			c.total_comments AS total_comments
		FROM likes_by_user_influencer_pair AS l
		LEFT JOIN comments_by_user_influencer_pair AS c ON -- left join from likes to comments
			l.user_id = c.user_id AND
			l.influencer_id = c.influencer_id
		UNION  -- union removes duplicates
		SELECT
			c.user_id AS user_id,
			c.influencer_id AS influencer_id,
			l.total_likes AS total_likes,
			c.total_comments AS total_comments
		FROM likes_by_user_influencer_pair AS l
		RIGHT JOIN comments_by_user_influencer_pair AS c ON  -- right join from likes to comments
			l.user_id = c.user_id AND
			l.influencer_id = c.influencer_id
	)
	SELECT
		user_id,
		influencer_id,
		COALESCE(total_likes, 0) AS total_likes,  -- coalesce turns NULLs into 0s
		COALESCE(total_comments, 0) AS total_comments,
		(COALESCE(total_likes, 0) + COALESCE(total_comments, 0)*1.5) AS engagement
	FROM full_join
	ORDER BY engagement DESC
);
```

![alt text](<Outputs/Question 4c-1 (Influencers) Output.png>)

```sql
-- The engagement of each user-noninfluencer pair
CREATE VIEW engagement_by_user_non_influencer_pair AS (
	WITH likes_by_user_non_influencer_pair AS (  -- find total likes from each user-to-noninfluencer pair
		SELECT
			likes.user_id AS user_id,
			photos.user_id AS non_influencer_id,
			COUNT(*) AS total_likes
		FROM likes
		INNER JOIN photos ON likes.photo_id = photos.id
		GROUP BY user_id, non_influencer_id
		HAVING non_influencer_id NOT IN (SELECT id FROM influencers)
	),
	comments_by_user_non_influencer_pair AS (  -- find total comments from each user-to-noninfluencer pair
		SELECT
			comments.user_id AS user_id,
			photos.user_id AS non_influencer_id,
			COUNT(*) AS total_comments
		FROM comments
		INNER JOIN photos ON comments.photo_id = photos.id
		GROUP BY user_id, non_influencer_id
		HAVING non_influencer_id NOT IN (SELECT id FROM influencers)
	),
	full_join AS (  -- union a left join and right join to emulate a full join
		SELECT
			l.user_id AS user_id,
			l.non_influencer_id AS non_influencer_id,
			l.total_likes AS total_likes,
			c.total_comments AS total_comments
		FROM likes_by_user_non_influencer_pair AS l
		LEFT JOIN comments_by_user_non_influencer_pair AS c ON -- left join from likes to comments
			l.user_id = c.user_id AND
			l.non_influencer_id = c.non_influencer_id
		UNION  -- union removes duplicates
		SELECT
			c.user_id AS user_id,
			c.non_influencer_id AS non_influencer_id,
			l.total_likes AS total_likes,
			c.total_comments AS total_comments
		FROM likes_by_user_non_influencer_pair AS l
		RIGHT JOIN comments_by_user_non_influencer_pair AS c ON  -- right join from likes to comments
			l.user_id = c.user_id AND
			l.non_influencer_id = c.non_influencer_id
	)
	SELECT
		user_id,
		non_influencer_id,
		COALESCE(total_likes, 0) AS total_likes,  -- coalesce turns NULLs into 0s
		COALESCE(total_comments, 0) AS total_comments,
		(COALESCE(total_likes, 0) + COALESCE(total_comments, 0)*1.5) AS engagement
	FROM full_join
	ORDER BY engagement DESC
);
```

![alt text](<Outputs/Question 4c-2 (Non-Influencers) Output.png>)

```sql
-- Average engagement of users towards influencers and non-influencers
SELECT AVG(engagement) AS avg_user_influencer_pair FROM engagement_by_user_influencer_pair;
SELECT AVG(engagement) AS avg_user_non_influencer_pair FROM engagement_by_user_non_influencer_pair;
```

![alt text](<Outputs/Question 4c-3 Output.png>) ![alt text](<Outputs/Question 4c-4 Output.png>)

Now that we have the average engagement from the two groups, we can conduct a t-test to see if there is a significant difference.

Let the null hypothesis be H0: The averages are the same. Let the notation indicate that Group 1 is the user_influencer pairs while Group 2 is the user_non_influencer pairs. We know that:

## Section 5: Bots

Bots are a natural part of social media and it is important to analyze how much engagement they do with real users. Define suspected bots on MiniGram to be users who have liked more than 5% of total photos.

```sql
-- Bots are defined as users who like >5% of all photos
CREATE VIEW suspected_bots AS (
	SELECT
		users.id,
        users.username
	FROM users
	JOIN likes ON users.id = likes.user_id
	GROUP BY likes.user_id
	HAVING COUNT(*) >= (SELECT COUNT(*) FROM photos) * 0.05
);
```

![alt text](<Outputs/Question 5-1 Output.png>)

![alt text](<Outputs/Question 5-2 Output.png>)

There are 49 suspected bots on MiniGram.

### Question 5a
When are bots most active?

Now that we have a list of bots, we can analyze when they are most active.

```sql
-- Bot likes by year
SELECT
	YEAR(likes.created_at) AS year,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY year
ORDER BY total DESC;
```

![alt text](<Outputs/Question 5a-1 (Year) Output.png>)

```sql
-- Bot likes by month
SELECT
	MONTHNAME(likes.created_at) AS month,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY month
ORDER BY total DESC;
```

![alt text](<Outputs/Question 5a-2 (Month) Output.png>)

```sql
-- Bot likes by day of week
SELECT
	DAYNAME(likes.created_at) AS day,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY day
ORDER BY total DESC;
```

![alt text](<Outputs/Question 5a-3 (Day) Output.png>)

```sql
-- Bot likes by hour
SELECT
	HOUR(likes.created_at) AS hour,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY hour
ORDER BY total DESC;
```

![alt text](<Outputs/Question 5a-4 (Hour) Output.png>)

Key findings:
* Year:
    * The year with the highest amount of bot activity is 2024 with 21563 bot likes.
    * The year with the lowest amount of bot activity is 2014 with only 682 bot likes.
    * The amount of bot activity increases as the year increases, most likely due to more bot accounts being created as the years go by.
* Month:
    * The month with the highest amount of bot activity is December with 7696 bot likes.
    * The month with the lowest amount of bot activity is February with only 5223 bot likes.
    * There seems to be a trend where bot activity increases in the second half of the year compared to the first half. The last 6 months of the year has the 6 highest total of bot likes.
* Day of week:
    * The day of week with the highest amount of bot activity is Thursdays with 11351 bot likes.
    * The day of week with the lowest amount of bot activity is Wednesdays with only 10964 bot likes.
    * No pattern can be located in the day of week time format.
* Hour:
    * The hour with the highest amount of bot activity is 8pm with 3363 bot likes.
    * The hour with the lowest amount of bot activity is 4am with only 3149 bot likes.
    * No pattern can be located in the hour time format.

### Question 5b
How much do bots impact the posts that they engage with?

To answer this question, I will create a view that shows the distribution between user likes and bot likes that are present in each photo.

```sql
-- Create view with photo.id, bot_likes, user_likes, total_likes
CREATE VIEW user_bot_likes AS (
	WITH likes_by_bots AS (
		SELECT
			photo_id,
			COUNT(*) AS bot_likes
		FROM likes
		WHERE user_id IN (SELECT id FROM suspected_bots)
		GROUP BY photo_id
	),
	likes_by_users AS (
		SELECT
			photo_id,
			COUNT(*) AS user_likes
		FROM likes
		WHERE user_id NOT IN (SELECT id FROM suspected_bots)
		GROUP BY photo_id
	),
	full_join AS (  -- union left join and right join to emulate full join
		SELECT
			b.photo_id AS photo_id,
			b.bot_likes AS bot_likes,
			u.user_likes AS user_likes
		FROM likes_by_bots AS b
		LEFT JOIN likes_by_users AS u ON
			b.photo_id = u.photo_id
		UNION
		SELECT
			u.photo_id AS photo_id,
			b.bot_likes AS bot_likes,
			u.user_likes AS user_likes
		FROM likes_by_bots AS b
		RIGHT JOIN likes_by_users AS u ON
			b.photo_id = u.photo_id
	)
	SELECT
		full_join.photo_id,
		COALESCE(full_join.bot_likes,0) AS bot_likes,  -- coalesce function turns NULLs into 0s
		COALESCE(full_join.user_likes,0) AS user_likes,
		COALESCE(full_join.bot_likes,0) + COALESCE(full_join.user_likes,0) AS total_likes,
		COALESCE(full_join.bot_likes,0) / (COALESCE(full_join.bot_likes,0) + COALESCE(full_join.user_likes,0)) AS pct_of_bot_likes,
		COALESCE(full_join.user_likes,0) / (COALESCE(full_join.bot_likes,0) + COALESCE(full_join.user_likes,0)) AS pct_of_user_likes
	FROM full_join
);
```

![alt text](<Outputs/Question 5b-1 Output.png>)

```sql
-- Average likes and percentage of likes by bots and likes by users on photos
SELECT
	AVG(bot_likes) AS avg_bot_likes,
    AVG(user_likes) AS avg_user_likes,
	AVG(pct_of_bot_likes) AS avg_pct_of_bot_likes,
    AVG(pct_of_user_likes) AS avg_pct_of_user_likes
FROM user_bot_likes;
```

![alt text](<Outputs/Question 5b-2 Output.png>)

As we can see, the average amount of likes on photos that are done by bots is around 23% which is quite a high number. In the next question, we will try to see there is any users on MiniGram that actually uses bots to boost the engagment on their posts.

### Question 5c
Find which accounts (if any) implement the use of bots on their posts.



## Section 6: Year by Year Analysis

### Question 6a
Compare the amount of photos/likes/comments from year to year

### Question 6b
Is there an increase in the rate of user and content growth from year to year?