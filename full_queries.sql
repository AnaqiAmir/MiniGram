-- Section 1: Basic Analytics
-- a) How many users?
SELECT COUNT(*) FROM users;

-- b) How many posts?
SELECT COUNT(*) FROM photos;

-- c) What is the average post per user?
SELECT (
	(SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users)
) AS avg_photo_per_user;

-- d) What is the average amount of likes per post?
SELECT (
	(SELECT COUNT(*) FROM likes) / (SELECT COUNT(*) FROM photos)
) AS avg_likes_per_photo;

-- e) What is the average number of comments under each post?
SELECT (
	(SELECT COUNT(*) FROM comments) / (SELECT COUNT(*) FROM photos)
) AS avg_comments_per_photo;

-- Section 2: User Engagement
-- a) User registration by year/month/day/hour
SELECT
	YEAR(created_at) AS year,
    COUNT(*) AS total
FROM users
GROUP BY year
ORDER BY year DESC;

SELECT
	MONTHNAME(created_at) AS month,
    COUNT(*) AS total
FROM users
GROUP BY month
ORDER BY FIELD(MONTH,'January','February','March','April','May','June',
					 'July','August','September','October','November','December');

SELECT
	DAYNAME(created_at) AS day_of_week,
    COUNT(*) AS total
FROM users
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

SELECT
	HOUR(created_at) AS hour,
    COUNT(*) AS total
FROM users
GROUP BY hour
ORDER BY hour;

-- b) Which users are the most active? When are they most active?
-- Activity metrics will be calculated as such:
-- i ) activity = # of photos + # of likes + # of comments + # of followings
-- ii) activity_rate = (# of photos + # of likes + # of comments + # of followings) / # of days since the user registered

-- Active and inactive users are measured (wrt to the specified metrics) to be the top and bottom 5% of users.

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

-- Active users (by activity) (excludes bots)
CREATE VIEW active_users_by_activity AS (
	SELECT *
    FROM user_activities
    WHERE
		activity < 1000 AND  -- exclude bots
		activity >= 223  -- active users (~250 users)
	ORDER BY activity DESC
);

-- Active users (by activity rate) (excludes suspected bots and new users)
CREATE VIEW active_users_by_activity_rate AS (
	SELECT *
    FROM user_activities
    WHERE
		activity_rate >= 1 AND  -- active users
        activity < 1000 AND  -- exclude bots
        days_on_minigram > 10  -- exclude brand new users
	ORDER BY activity_rate DESC
);
-- NOTE: Queries will be after inactive users definitions

-- c) Which users are the most inactive? When are they most active?
-- Inactive users (by activity) (excludes bots)
CREATE VIEW inactive_users_by_activity AS (
	SELECT *
    FROM user_activities
    WHERE activity <= 144
    ORDER BY activity
);

-- Inactive users (by activity rate) (excludes suspected bots and new users)
CREATE VIEW inactive_users_by_activity_rate AS (
	SELECT *
    FROM user_activities
    WHERE activity_rate <= 0.045
    ORDER BY activity_rate
);

-- Targetted users (a placeholder)
-- How to use:
-- SELECT * FROM [active_users_by_activity/active_users_by_activity_rate/inactive_users_by_activity/inactive_users_by_activity_rate]
DROP VIEW target_users;
CREATE VIEW target_users AS (
	SELECT * FROM inactive_users_by_activity
);

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

-- A different approach
-- WITH active_users_by_activity AS (
-- 	SELECT *
--     FROM user_activity
--     WHERE
-- 		activity < 1000 AND  -- exclude bots
-- 		activity > 150  -- active users
-- ),
-- active_users_by_activity_rate AS (
-- 	SELECT *
--     FROM user_activity
--     WHERE
-- 		activity_rate >= 1 AND  -- active users
--         activity < 1000 AND  -- exclude bots
--         days_on_minigram > 10  -- exclude brand new users
-- ),
-- when_photos_are_created AS (
-- 	SELECT
-- 		DAYNAME(photos.created_at) AS day
-- 	FROM users
-- 	JOIN photos ON users.id = photos.user_id
-- 	GROUP BY day
-- )
-- -- ChatGPT test
-- SELECT
--     COALESCE(t1.day, t2.day) AS day,
--     COUNT(t1.id) AS count_t1,
--     COUNT(t2.id) AS count_t2
-- FROM
--     (SELECT day, id FROM active_users_by_activity) t1
-- FULL OUTER JOIN
--     (SELECT day, id FROM active_users_by_activity_rate) t2
-- ON t1.day = t2.day
-- GROUP BY COALESCE(t1.day, t2.day)
-- ORDER BY day;

-- Section 3: Posts and Content
-- a) Which types of content typically receive the most engagement?
-- Engagement = # of likes + (# of comments)*1.5 <----- Comments are worth more

-- Table that displays total engagement of photos
DROP VIEW photo_engagements;
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

-- b) What is the ideal time for a user to post content?
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

-- Section 4: Influencers
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

-- a) What types of content do influencers post compared to non-influencers?

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

-- b) Find the difference in activity between influencers and non-influencers.
-- i) activity
-- Average activity of influencers
WITH influencer_activity AS (
	SELECT *
	FROM user_activities
	WHERE id IN (SELECT id FROM influencers)
)
SELECT AVG(activity) AS avg_influencer_activity
FROM influencer_activity;

-- Average activity of non-influencers
WITH non_influencer_activity AS (
	SELECT *
    FROM user_activities
    WHERE id NOT IN (SELECT id FROM influencers) -- AND activity<1000  <---- if you want to exclude bots
)
SELECT AVG(activity) AS avg_non_influencer_activity
FROM non_influencer_activity;

-- ii) activity rate
-- Average activity rate of influencers
WITH influencer_activity_rate AS (
	SELECT *
	FROM user_activities
	WHERE id IN (SELECT id FROM influencers)
)
SELECT AVG(activity_rate) AS avg_influencer_activity_rate
FROM influencer_activity_rate;

-- Average activity rate of non-influencers
WITH non_influencer_activity_rate AS (
	SELECT *
	FROM user_activities
	WHERE id NOT IN (SELECT id FROM influencers)  -- AND activity<1000  <---- if you want to exclude bots
)
SELECT AVG(activity_rate) AS avg_non_influencer_activity_rate
FROM non_influencer_activity_rate;

-- c) How do influencers impact other users' engagement on MiniGram?
-- Find which users engage the most with influencers

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

-- The engagement of each user-noninfluencer pair
CREATE VIEW engagement_by_user_non_influencer_pair AS (
	WITH likes_by_user_non_influencer_pair AS (  -- find total likes from each user-to-influencer pair
		SELECT
			likes.user_id AS user_id,
			photos.user_id AS non_influencer_id,
			COUNT(*) AS total_likes
		FROM likes
		INNER JOIN photos ON likes.photo_id = photos.id
		GROUP BY user_id, non_influencer_id
		HAVING non_influencer_id NOT IN (SELECT id FROM influencers)
	),
	comments_by_user_non_influencer_pair AS (  -- find total comments from each user-to-influencer pair
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

-- Average engagement of users towards influencers and non-influencers
SELECT AVG(engagement) FROM engagement_by_user_influencer_pair;
SELECT AVG(engagement) FROM engagement_by_user_non_influencer_pair;

-- Conduct t-test after

-- Section 5: Bots
-- Bots are defined as users who like >5% of all photos

DROP VIEW suspected_bots;
CREATE VIEW suspected_bots AS (
	SELECT
		users.id,
        users.username
	FROM users
	JOIN likes ON users.id = likes.user_id
	GROUP BY likes.user_id
	HAVING COUNT(*) >= (SELECT COUNT(*) FROM photos) * 0.05
);

-- a) When are the bots most active?
SELECT
	YEAR(likes.created_at) AS year,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY year
ORDER BY total DESC;

SELECT
	MONTHNAME(likes.created_at) AS month,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY month
ORDER BY total DESC;

SELECT
	DAYNAME(likes.created_at) AS day,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY day
ORDER BY total DESC;

SELECT
	HOUR(likes.created_at) AS hour,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY hour
ORDER BY total DESC;

-- b) How do bots impact the posts that they engage in?
-- Create df with photo.id, bot_likes, user_likes, total_likes

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

-- Average likes and percentage of likes by bots and likes by users on photos
SELECT
	AVG(bot_likes) AS avg_bot_likes,
    AVG(user_likes) AS avg_user_likes,
	AVG(pct_of_bot_likes) AS avg_pct_of_bot_likes,
    AVG(pct_of_user_likes) AS avg_pct_of_user_likes
FROM user_bot_likes;

-- c) Find which accounts (if any) implement the use of bots.
-- Combine user_bot_like with photos and group by user_id
-- Find users where their >50% of their likes are by bots
SELECT
	photos.user_id AS user_id,
    users.username AS username,
	SUM(bot_likes) AS total_likes_by_bots,
	SUM(total_likes) AS total_likes,
	SUM(bot_likes) / SUM(total_likes) AS pct_liked_by_bots
FROM photos
JOIN user_bot_likes ON photos.id = user_bot_likes.photo_id
JOIN users ON photos.user_id = users.id
GROUP BY user_id
HAVING pct_liked_by_bots >= 0.5  -- find users where >50% of their likes are by bots
ORDER BY pct_liked_by_bots DESC;

-- Section 6: Year by Year Analysis
-- a) Compare the amount of posts/likes/comments from year to year

CREATE VIEW yoy_analysis AS (  -- Table that shows the amount of photos/likes/comments from each year
	WITH photos_by_year AS (
		SELECT
			YEAR(photos.created_at) AS year,
			COUNT(*) AS total_photos
		FROM photos
		GROUP BY year
		ORDER BY year
	),
	likes_by_year AS (
		SELECT
			YEAR(likes.created_at) AS year,
			COUNT(*) AS total_likes
		FROM likes
		GROUP BY year
		ORDER BY year
	),
	comments_by_year AS (
		SELECT
			YEAR(comments.created_at) AS year,
			COUNT(*) AS total_comments
		FROM comments
		GROUP BY year
		ORDER BY year
	)
	SELECT
		photos_by_year.year AS year,
		total_photos,
		total_likes,
		total_comments,
		total_photos + total_likes + total_comments AS total
	FROM photos_by_year
	JOIN likes_by_year ON photos_by_year.year = likes_by_year.year
	JOIN comments_by_year ON photos_by_year.year = comments_by_year.year
	ORDER BY year
);

SELECT * FROM yoy_analysis;

-- b) Is there an increase in the rate of user and content growth from year to year?
-- Find the percentage increase from previous year

SELECT
	year,
    total_photos,
    (LEAD(total_photos) OVER() - total_photos) / total_photos AS photos_pct_diff,
    total_likes,
    (LEAD(total_likes) OVER() - total_likes) / total_likes AS likes_pct_diff,
    total_comments,
    (LEAD(total_comments) OVER() - total_comments) / total_comments AS comments_pct_diff,
    total,
	(LEAD(total) OVER() - total) / total AS pct_diff
FROM yoy_analysis;
