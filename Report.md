# MiniGram User Analysis
This document details the queries that were used to answer the business questions that were presented. It also provide the outputs.

## Table of Contents
1. [Section 1: Basic Questions](##section-1-basic-questions)
	* [Question 1: Find the oldest users in the database](##1-find-the-5-oldest-users-in-the-database)
2. Section 2: Bots and Inactive Users
3. [Section 3: Influencers](#section-3)

## SECTION 1: Basic Questions

### 1. Find the 5 oldest users in the database
```sql
SELECT * FROM users
ORDER BY created_at
LIMIT 5;
```
**Output**:

<img width="255" alt="Q1 Output" src="https://github.com/user-attachments/assets/b3608c2b-cc63-4cd4-8e70-b3b264763e9e">


### 2. Find the day of the week that most users register on
```sql
SELECT 
    DATE_FORMAT(created_at, '%W') AS day_of_week,
    COUNT(*) AS day_of_week_count
FROM users
GROUP BY day_of_week
ORDER BY day_of_week_count DESC;
```

**Output**:

<img width="253" alt="Q2 Output" src="https://github.com/user-attachments/assets/7354909a-9a50-4c2d-808b-087474f3d67d">

### 3. List all inactive users (users who have never posted a photo)
```sql
SELECT username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;
```

**Output**:

<img width="121" alt="Q3 Output" src="https://github.com/user-attachments/assets/619b5be8-4cd6-42ae-85cf-3fd18fb136e7">

### 4. Find the user who has the most liked photo
```sql
SELECT username, image_url, COUNT(*) AS likes
FROM likes
JOIN photos ON likes.photo_id = photos.id
JOIN users ON photos.user_id = users.id
GROUP BY likes.photo_id
ORDER BY COUNT(*) DESC
LIMIT 1;
```
**Output**:

<img width="241" alt="Q4 Output" src="https://github.com/user-attachments/assets/c060ce78-a503-441b-9140-bfa239570369">

### 5. What is the average number of photo per user?
```sql
SELECT
	(SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users)
AS avg_photos_per_user;
```

**Output**:

<img width="130" alt="Q5 Output" src="https://github.com/user-attachments/assets/bebf66d5-8f81-4d3a-b64b-26f691dfe654">

### 6. List the top 5 tags that are used
```sql
SELECT tag_name, count
FROM tags
JOIN (
	SELECT tag_id, COUNT(*) AS count
	FROM photo_tags
	GROUP BY tag_id
	ORDER BY count DESC
	LIMIT 6
) AS top_5_tags
ON tags.id = top_5_tags.tag_id
ORDER BY count DESC;
```
OR
```sql
SELECT tags.tag_name, COUNT(*) AS count
FROM photo_tags
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tags.id
ORDER BY count DESC
LIMIT 6;
```

**Output**:

<img width="235" alt="Q6 1 Output" src="https://github.com/user-attachments/assets/a2690904-dd96-4897-8f5f-54394444420e">

***

## SECTION 2: Bots and Inactive Users

### 7. List all suspected bots in the database (users who have liked every photo)
```sql
SELECT users.username, likes.user_id
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY likes.user_id
HAVING COUNT(*) = (SELECT COUNT(*) FROM photos);
```
**Output**

<img width="157" alt="Q7 Output" src="https://github.com/user-attachments/assets/e702e617-97a7-485a-9d9f-48eea3544328">

### 8. Find out which days inactive users are typically on MiniGram

```sql
-- STEP 1) Create table of inactive users who have liked photos
CREATE TABLE inactive_users_activity AS (
	SELECT
		COUNT(*) AS count,
		DATE_FORMAT(likes.created_at, '%W') AS day_of_week
	FROM users
	LEFT JOIN photos ON users.id = photos.user_id
	LEFT JOIN likes ON users.id = likes.user_id
	WHERE photos.id IS NULL AND likes.created_at IS NOT NULL
	GROUP BY day_of_week
);

-- View table
SELECT day_of_week, count FROM inactive_users_activity
ORDER BY count DESC;
```

**Output**:

<img width="123" alt="Q8 View Table" src="https://github.com/user-attachments/assets/4dd7da4b-27ba-4677-8920-97dfc8fe56b2">

```sql
-- STEP 2) Finding sum of top 2 days
SELECT SUM(count) 
FROM inactive_users_activity
WHERE day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1) OR
	day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1,1);
```

**Output**:

<img width="110" alt="Q8 Step 2 Output" src="https://github.com/user-attachments/assets/7fafda9d-fa7b-4749-896e-f72935f6d946">

```sql
-- STEP 3) Finding the amount of likes that were done by inactive users
SELECT SUM(count) FROM inactive_users_activity;
```

**Output**:

<img width="111" alt="Q8 Step 3 Output" src="https://github.com/user-attachments/assets/b6c0fa36-e0e4-469b-9e05-aaf89a4990ea">

```sql
-- STEP 4) Percentage of inactive users that liked photos in top 2 days
SELECT
	(SELECT SUM(count) 
    FROM inactive_users_activity 
    WHERE day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1) OR
		day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1,1)) /
	(SELECT SUM(count) 
    FROM inactive_users_activity)
AS percentage_inactive_top_2;
```
**Output**:

<img width="167" alt="Q8 Step 4 Output" src="https://github.com/user-attachments/assets/3d7290fd-1b63-41d3-82b3-d86161c32152">

***

## SECTION 3

### 9. What types of photos are influencers posting?

```sql
-- Step 1) Find influencers
CREATE TABLE influencers AS (
	SELECT users.id, users.username, COUNT(*) AS num_of_followers
	FROM users
	JOIN follows ON users.id = follows.followee_id
	GROUP BY follows.followee_id 
	ORDER BY num_of_followers DESC
	LIMIT 5
);

SELECT * FROM influencers;
```
**Output**:

<img width="244" alt="Q9 Influencers Table" src="https://github.com/user-attachments/assets/6690a19b-eb36-4dbf-9381-2a2d64e4b4f0">

```sql
-- Step 2) Find tags of the photos by influencers
SELECT tags.tag_name, COUNT(*) AS amount
FROM influencers
JOIN photos ON influencers.id = photos.user_id
JOIN photo_tags ON photos.id = photo_tags.photo_id
JOIN tags ON tags.id = photo_tags.tag_id
GROUP BY tags.tag_name
ORDER BY amount DESC
LIMIT 5;
```
**Output**:

<img width="180" alt="Q9 Output" src="https://github.com/user-attachments/assets/7aca1111-abd3-48b9-85b5-82f53e66d1ef">

### 10. What is the ratio between followers and following for influencers? What about for non-influencers? Compare the two ratios.

```sql
-- Num of followings (influencers)
SELECT influencers.id, COUNT(*) AS num_of_following
FROM influencers
JOIN follows ON influencers.id = follows.follower_id
GROUP BY follows.follower_id;
```

**Output**:

<img width="156" alt="Q10 Influencers Followings" src="https://github.com/user-attachments/assets/37d8bea7-c005-4268-941c-416ab1b43ab0">

```sql
-- Num of followings (non-influencers)
SELECT users.id, COUNT(*) AS num_of_following
FROM users
JOIN follows ON users.id = follows.follower_id
GROUP BY follows.follower_id
HAVING users.id NOT IN (SELECT id FROM influencers);
```
**Output**:

<img width="145" alt="Q10 Non-Influencers Followings" src="https://github.com/user-attachments/assets/721049cd-a1a6-4c68-83a4-c11e0d62f98f">

```sql
-- Ratio between followers to following (influencers)
SELECT 
	(SELECT AVG(num_of_followers)
		FROM influencers) /
	(SELECT AVG(a.num_of_following)
		FROM (SELECT COUNT(*) AS num_of_following
				FROM influencers
				JOIN follows ON influencers.id = follows.follower_id
				GROUP BY follows.follower_id
			) AS a
	) AS followers_to_following_ratio;
```
**Output**:

<img width="166" alt="Q10 Influencers Ratio" src="https://github.com/user-attachments/assets/d2f6a460-5117-4453-86e1-7206c647c708">

```sql
-- Ratio between followers to following (non-influencers)
SELECT
	(SELECT AVG(a.num_of_followers)
		FROM (SELECT users.id, COUNT(*) AS num_of_followers
				FROM users
                JOIN follows ON users.id = follows.followee_id
                GROUP BY follows.followee_id
                HAVING users.id NOT IN (SELECT id FROM influencers)
                ) AS a
		) /
	(SELECT AVG(b.num_of_followings)
		FROM (SELECT users.id, COUNT(*) AS num_of_followings
				FROM users
				JOIN follows ON users.id = follows.follower_id
				GROUP BY follows.follower_id
				HAVING users.id NOT IN (SELECT id FROM influencers)
				) AS b
		)
AS ratio_for_non_influencers;
```
**Output**:

<img width="178" alt="Q10 Non-Influencers Ratio" src="https://github.com/user-attachments/assets/9de358b1-97a9-4523-bc12-19ea2cc452b1">

### Question 11. How often do influencers post compared to non-influencers? Is there a significant difference?

```sql
-- Num of posts (influencers)
SELECT influencers.id, username, COUNT(*) AS num_of_posts 
FROM influencers
JOIN photos ON influencers.id = photos.user_id
GROUP BY influencers.id, username;
```

**Output**:

```sql
-- Avg of num of posts by influencers
SELECT AVG(num_of_posts)
FROM (SELECT influencers.id, username, COUNT(*) AS num_of_posts 
		FROM influencers
		JOIN photos ON influencers.id = photos.user_id
		GROUP BY influencers.id, username
	) as a;
```

**Output**:

```sql
-- Num of Posts (non-influencers)
SELECT users.id, COUNT(*) AS num_of_posts
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
HAVING users.id NOT IN (SELECT id FROM influencers);
```

**Output**:

```sql
-- Avg of num of posts by non-influencers
SELECT AVG(num_of_posts)
FROM (SELECT users.id, COUNT(*) AS num_of_posts
		FROM users
		JOIN photos ON users.id = photos.user_id
		GROUP BY users.id
		HAVING users.id NOT IN (SELECT id FROM influencers)
	) as b;
```

**Output**:

***

## SECTION 4: Posts and Content

### Question 12. What type of posts receive the most likes?

```sql
SELECT tags.tag_name, COUNT(*) likes_by_tags
FROM photos
JOIN likes ON photos.id = likes.photo_id
JOIN photo_tags ON photos.id = photo_tags.photo_id
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tags.tag_name
ORDER BY likes_by_tags DESC
LIMIT 10;
```
**Output**:

<img width="209" alt="Q12 Output" src="https://github.com/user-attachments/assets/67ae267c-c470-4ab0-b0e1-c7fec91b75b9">

### Question 13. What is the correlation between follower count and likes per post?

```sql
-- STEP 1) Sort by follower count
CREATE TABLE follower_count AS (
	SELECT users.id, users.username, COUNT(*) as num_of_followers
	FROM users
	JOIN follows ON users.id = follows.followee_id
	GROUP BY users.id, users.username
	ORDER BY num_of_followers ASC
);

SELECT * FROM follower_count;
```
**Output**:

<img width="246" alt="Q13 follower_count output 1" src="https://github.com/user-attachments/assets/156e8576-a7b9-4b21-b392-047ae1b5a5d7">
<img width="243" alt="Q13 follower_count output 2" src="https://github.com/user-attachments/assets/d42aec4b-bded-453a-a837-47bbb8622a7e">

```sql
-- STEP 2) In the order of Step 1, display the likes per post of those users

-- Likes per photo
CREATE TABLE likes_per_photo AS (
	SELECT user_id, username, AVG(num_of_likes) AS avg_likes_per_photo
	FROM (SELECT users.id AS user_id, users.username, photos.id AS photo_id, COUNT(*) AS num_of_likes
			FROM users
			JOIN photos ON users.id = photos.user_id
			JOIN likes ON photos.id = likes.photo_id
			GROUP BY users.id, users.username, photos.id
		) AS a
	GROUP BY user_id, username
);

SELECT * FROM likes_per_photo;
```
**Output**:

<img width="297" alt="Q13 likes_per_photo output 1" src="https://github.com/user-attachments/assets/5648c13f-5d2c-481c-8bc0-e94a1e8fdc7b">
<img width="297" alt="Q13 likes_per_photo output 2" src="https://github.com/user-attachments/assets/da259084-3d90-4422-9ae9-cc99726c80f2">

```sql
-- Combining to see num_of_followers next to avg_likes_per_photo
SELECT likes_per_photo.user_id, likes_per_photo.username, num_of_followers, avg_likes_per_photo
FROM likes_per_photo
JOIN follower_count ON likes_per_photo.user_id = follower_count.id;
```
**Output**:

<img width="361" alt="Q13 combined output 1" src="https://github.com/user-attachments/assets/8f89fe01-6aaf-4f8f-85db-b5fccc235b53">
<img width="360" alt="Q13 combined output 2" src="https://github.com/user-attachments/assets/898816e9-8d83-4da3-8243-83eeff70d841">

Now that we have both columns, we can graph them to see if there is any correlation between the two:

<img width="602" alt="Q13 Correlation graph" src="https://github.com/user-attachments/assets/cb38460e-e070-403b-833a-ac979cc0b9a9">

As we can see, there is absolutely no correlation between the number of followers a user has to the average amount of likes per photo that they post.

