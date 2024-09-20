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
