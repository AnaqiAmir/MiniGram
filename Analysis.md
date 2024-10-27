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

To analyze, this we will take a look at the distribution of when users register for MiniGram based on different timings (year,month,day of week,hour).

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

### Question 2c
Which users are the most inactive? When are these inactive users mostly active?

## Section 3: Posts and Content

### Question 3a
What types of content typically gets the most engagement?

### Question 3b
When is the ideal time for a user to post content for a better chance to get high amount of engagement?

## Section 4: Influencers

### Question 4a
Find the difference between the types of posts that influencers post compared to non-influencers.

### Question 4b
Find the difference in activity between influencers and non-influencers.

### Question 4c
How do influencers impact other users' engagement on MiniGram?

## Section 5: Bots

### Question 5a
When are bots most active?

### Question 5b
How much do bots impact the posts that they engage with?

### Question 5c
Find which accounts (if any) implement the use of bots on their posts.

## Section 6: Year by Year Analysis

### Question 6a
Compare the amount of photos/likes/comments from year to year

### Question 6b
Is there an increase in the rate of user and content growth from year to year?