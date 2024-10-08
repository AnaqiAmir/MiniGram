--------------------------------------------------- SECTION 1: Basic Questions ---------------------------------------------------

-- QUESTION 1
-- Find the oldest 5 users
SELECT * FROM users
ORDER BY created_at
LIMIT 5;

-- QUESTION 2
-- Day of the week that most users register on
SELECT 
    DATE_FORMAT(created_at, '%W') AS day_of_week,
    COUNT(*) AS day_of_week_count
FROM users
GROUP BY day_of_week
ORDER BY day_of_week_count DESC;

-- QUESTION 3
-- Find users who have never posted a photo
SELECT username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;

-- QUESTION 4
-- Find who has the most liked photo
SELECT username, image_url, COUNT(*) AS likes
FROM likes
JOIN photos ON likes.photo_id = photos.id
JOIN users ON photos.user_id = users.id
GROUP BY likes.photo_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- QUESTION 5
-- Average number of photos per user
SELECT
	(SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users)
AS avg_photos_per_user;

-- QUESTION 6
-- Top 5 hashtags
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

-- OR
SELECT tags.tag_name, COUNT(*) AS count
FROM photo_tags
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tags.id
ORDER BY count DESC
LIMIT 6;

--------------------------------------------------- SECTION 2: Bots and Inactive Users ---------------------------------------------------

-- QUESTION 7
-- Finding bots (Users who have liked every photo)
SELECT users.username, likes.user_id
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY likes.user_id
HAVING COUNT(*) = (SELECT COUNT(*) FROM photos);

-- QUESTION 8
-- Finding what days inactive users (no posts) like photos

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

-- STEP 2) Finding sum of top 2 days
SELECT SUM(count) 
FROM inactive_users_activity
WHERE day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1) OR
	day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1,1);
    
-- STEP 3) Finding the amount of likes that were done by inactive users
SELECT SUM(count) FROM inactive_users_activity;

-- STEP 4) Percentage of inactive users that liked photos in top 2 days
SELECT
	(SELECT SUM(count) 
	    FROM inactive_users_activity 
	    WHERE day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1) OR
					day_of_week = (SELECT day_of_week FROM inactive_users_activity ORDER BY count DESC LIMIT 1,1)) /
	(SELECT SUM(count) 
    		FROM inactive_users_activity)
AS percentage_inactive_top_2;

--------------------------------------------------- SECTION 3: Influencers ---------------------------------------------------

-- QUESTION 9
-- What types of photos are influencers posting?

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

-- Step 2) Find tags of the photos by influencers
SELECT tags.tag_name, COUNT(*) AS amount
FROM influencers
JOIN photos ON influencers.id = photos.user_id
JOIN photo_tags ON photos.id = photo_tags.photo_id
JOIN tags ON tags.id = photo_tags.tag_id
GROUP BY tags.tag_name
ORDER BY amount DESC
LIMIT 5;

-- QUESTION 10
-- What is the ratio of followers to following for both influencers and non-influencers?

-- Num of followings (influencers)
SELECT influencers.id, COUNT(*) AS num_of_following
FROM influencers
JOIN follows ON influencers.id = follows.follower_id
GROUP BY follows.follower_id;

-- Num of followings (non-influencers)
SELECT users.id, COUNT(*) AS num_of_following
FROM users
JOIN follows ON users.id = follows.follower_id
GROUP BY follows.follower_id
HAVING users.id NOT IN (SELECT id FROM influencers);

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

-- QUESTION 11 ( -- NEED FIXING!!! FIGURE OUT HOW TO INCLUDE THOSE WITHOUT POSTS -- )
-- How often do influencers post compared to non-influencers? Is there a significant difference?

-- Num of posts (influencers)
SELECT influencers.id, username, COUNT(*) AS num_of_posts 
FROM influencers
JOIN photos ON influencers.id = photos.user_id
GROUP BY influencers.id, username;

-- Avg of num of posts by influencers (real number should be 3.8)
SELECT AVG(num_of_posts)
FROM (SELECT influencers.id, username, COUNT(*) AS num_of_posts 
		FROM influencers
		JOIN photos ON influencers.id = photos.user_id
		GROUP BY influencers.id, username
	) as a;

-- Num of Posts (non-influencers)
SELECT users.id, COUNT(*) AS num_of_posts
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
HAVING users.id NOT IN (SELECT id FROM influencers);

-- Avg of num of posts by non-influencers (real number should be 2.505263158)
SELECT AVG(num_of_posts)
FROM (SELECT users.id, COUNT(*) AS num_of_posts
		FROM users
		JOIN photos ON users.id = photos.user_id
		GROUP BY users.id
		HAVING users.id NOT IN (SELECT id FROM influencers)
	) as b;
    
-- T-test
-- H_0: They're the same, alpha = 0.05
-- For influencers: avg_posts = 3.8, n = 5, std = 3.9698866482558 (correct values calculated manually)
-- Avg for non-influencers = 2.505263158, n = 95, std= 2.4532413969686 (correct values calculated manually)
-- df = 5 + 95 - 1 = 99 ~ 100 
-- critical_value = 1.984

-- STD for influencers <<<<<<<<< NEEDS FIXING!!! IT DOESNT ACCOUNT FOR USER SOMETHING THAT HAS 0 POSTS
SELECT STD(num_of_posts)
FROM (SELECT COUNT(*) AS num_of_posts
		FROM influencers
        JOIN photos ON influencers.id = photos.user_id
        GROUP BY photos.user_id
	) AS a;

-- STD for non-influencers <<<<<<<<< NEEDS FIXING TOO!!! 25 USERS WITH 0 POSTS UNACCOUNTED FOR
SELECT STD(num_of_posts)
FROM (SELECT users.id, COUNT(*) AS num_of_posts
		FROM users
		JOIN photos ON users.id = photos.user_id
		GROUP BY photos.user_id
		HAVING users.id NOT IN (SELECT id FROM influencers)
	) AS b;
    
-- ==> T-value = (3.8 - 2.505263158) / sqrt( (3.9698866482558^2 / 5) + (2.4532413969686^2 / 95) )
--             = 0.7220500081

-- ==> Since T-value = 0.7220500081 < 1.984 = critical_value
-- ==> We fail to reject H_0, ie There is no significant difference between the number of posts by influencers vs non-influencers

-- Unequal Variance T-test -- 
-- H_0: They're the same, alpha = 0.05
-- For influencers: avg_1 = 3.8, n_1 = 5, var_1 = 15.76 (correct values calculated manually)
-- Avg for non-influencers: avg_2 = 2.505263158, n_2 = 95, var_2 = 6.0183933518 (correct values calculated manually)
-- df = ( (var_1^2/n_1) +  (var_2^2/n_2) ) ^ 2 / ( ( (var_1^2/n_1)^2 / (n_1 - 1) ) + ( (var_2^2/n_2)^2 / (n_2 - 1) ) )
--    = ( (15.76^2/5) + (6.018^2/95) ) ^ 2 / ( ( (15.76^2/5)^2 / (5-1) ) + ( (6.018^2/95)^2 / (95-1) ) )
--    = 4.06161973879
--    ~ 4 (round down)
-- critical_value = 2.776

-- T-value = (avg_1 - avg_2) / sqrt( (var_1/n1) + (var_2/n2) )
--         = (3.8-2.505) / sqrt ( (15.76/5) + (6.018/95) )
--         = 0.72219723129

-- Since 0.7222 < 2.776 ==> We fail to reject H_0. Same conclusion as normal t-test.


--------------------------------------------------- SECTION 4: Posts and Content ---------------------------------------------------

-- QUESTION 12
-- What type of posts receive the most likes?
SELECT tags.tag_name, COUNT(*) likes_by_tags
FROM photos
JOIN likes ON photos.id = likes.photo_id
JOIN photo_tags ON photos.id = photo_tags.photo_id
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tags.tag_name
ORDER BY likes_by_tags DESC
LIMIT 10;

-- QUSTION 13
-- What is the correlation between follower count and likes per post?

-- STEP 1) Sort by follower count
CREATE TABLE follower_count AS (
	SELECT users.id, users.username, COUNT(*) as num_of_followers
	FROM users
	JOIN follows ON users.id = follows.followee_id
	GROUP BY users.id, users.username
	ORDER BY num_of_followers ASC
);

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

-- Combining to see num_of_followers next to avg_likes_per_photo
SELECT likes_per_photo.user_id, likes_per_photo.username, num_of_followers, avg_likes_per_photo
FROM likes_per_photo
JOIN follower_count ON likes_per_photo.user_id = follower_count.id;

-- STEP 3) Analyze
-- Upon analysis, there is 0 correlation between the two indicating that the amount of followers you have 
-- does NOT affect the average likes per photo for your account.
