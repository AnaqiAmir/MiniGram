# MiniGram User Analysis

## 1. Find the 5 oldest users in the database
```sql
SELECT * FROM users
ORDER BY created_at
LIMIT 5;
```
**Output**:

## 2. Find the day of the week that most users register on
```sql
SELECT 
    DATE_FORMAT(created_at, '%W') AS day_of_week,
    COUNT(*) AS day_of_week_count
FROM users
GROUP BY day_of_week
ORDER BY day_of_week_count DESC;
```

**Output**:

## 3. List all inactive users (users who have never posted a photo)
```sql
SELECT username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;
```

**Output**:

## 4. Find the user who has the most liked photo
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

## 5. What is the average number of photo per user?
```sql
SELECT
	(SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users)
AS avg_photos_per_user;
```

**Output**:

## 6. List the top 5 tags that are used
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
ON tags.id = top_5_tags.tag_id;
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

## 7. List all suspected bots in the database (users who have liked every photo)
```sql
SELECT users.username, likes.user_id
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY likes.user_id
HAVING COUNT(*) = (SELECT COUNT(*) FROM photos);
```

**Output**

## 8. Find out which days inactive users are typically on MiniGram

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
SELECT * FROM inactive_users_activity;
```

```sql
-- STEP 2) Finding sum of top 2 days
SELECT SUM(count) 
FROM inactive_users_activity
WHERE day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1) OR
	day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1,1);
```

```sql
-- STEP 3) Finding the amount of likes that were done by inactive users
SELECT SUM(count) FROM inactive_users_activity;
```

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

## 9. What types of photos are influencers posting?

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

## 10. What is the ratio between followers and following for influencers? What about for non-influencers? Compare the two ratios.

```sql
-- Num of followings (influencers)
SELECT influencers.id, COUNT(*) AS num_of_following
FROM influencers
JOIN follows ON influencers.id = follows.follower_id
GROUP BY follows.follower_id;
```

**Output**:

```sql
-- Num of followings (non-influencers)
SELECT users.id, COUNT(*) AS num_of_following
FROM users
JOIN follows ON users.id = follows.follower_id
GROUP BY follows.follower_id
HAVING users.id NOT IN (SELECT id FROM influencers);
```

**Output**:

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
		);
```

**Output**:
