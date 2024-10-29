# MiniGram
A database of a scaled-down version of Instagram

## Overview
MiniGram is a social media platform designed for users to share moments from their lives with close friends and their broader community. It enables users to post photos, engage with followers, and interact with content through likes, comments, and descriptive tags, allowing easy discovery of similar posts.

This report provides an in-depth analysis of MiniGram's database, focusing on how users utilize the application and how they interact with one another within it. It offers valuable insights into user behavior that the marketing team can leverage to develop targeted strategies, enhancing outreach to specific user segments.

The following areas will be covered in this report:
* **User Engagement**: Discover the distribution of user registration period and which users are most active/inactive and when they are most active/inactive.
* **Posts and Content**: Investigate what types of post gets the most engagement and how users can optimize the timing of their post to increase their change to make it go viral.
* **Influencers**: Find the different influencers on MiniGram and how they behave differently from normal users.
* **Bots**: Locate suspected bots through their behaviours and understand the impact that they create through their interactions with other users and their activities.
* **Year over Year Analysis**: Observe the trends of how MiniGram is progressing from year to year.

## Executive Summary

**Overview of findings**

Upon analysis, we can see a steady growth in user registrations and activity from year to year with 5000 total users and 25000 total photos posted on MiniGram by the end of 2024. Influencers make up 2.7% of the users and plays a pivotal role in driving up engagement on the platform, with users being 4.21x more likely to engage with posts by influencers compared to normal users.The issue of bots on MiniGram is significant, with suspected bots comprising approximately 0.98% of the total user base. These bots have a noticeable impact on user engagement, as they account for an average of 23% of the likes on photos.

**Quick Numbers:**
* 5000 users
* 25000 photos
* 250 tags
* 504025 likes
* 350333 comments
* 135 influencers
* 49 suspected bots
* An average of 5 photos per user
* An average of 20.16 likes per photo
* An average of 14.01 comments per photo

**User Engagement:**

* **User Registration Trends**: Registrations on MiniGram peaked in 2020, with 491 new users, likely influenced by the COVID-19 pandemic as people sought to increase their social interactions online. This surge reflects how external factors can significantly impact user acquisition.

* **Seasonal Registration Patterns**: August stands out as the most popular month for sign-ups, with 451 registrations, while February saw the lowest with only 359. January and March also experienced lower registration numbers (417 and 408, respectively), indicating a potential gap in marketing efforts at the start of the year. This trend suggests that ramping up promotional activities in early months could help maintain consistent growth throughout the year.

* **Activity Patterns Among Active Users**: Active users tend to post photos and follow others mostly on weekends, with 231 photos posted on Saturdays and 989 follows on Sundays. In contrast, Wednesdays see the highest engagement in likes (4,370) and comments (3,299). This suggests users reserve weekends for personal activities, such as posting and following, when they have more free time, while passive activities like liking and commenting occur mid-week when users are likely busier. These patterns align with intuitive user behavior.

* **Inactive User Engagement**: For the 255 inactive users, engagement peaks at the end of the week. These users liked the most photos on Thursdays (2,340), posted the most on Fridays (172), and followed other users primarily on Saturdays (553). This insight can guide targeted marketing efforts to re-engage these users by leveraging their existing activity patterns to increase their overall platform interaction.

**Posts and Content:**

* **Highly Engaged Tags**: The top three tags associated with highly engaged photos are positive in nature—bestoftheday (14), cute (10), and celebration (10). This indicates that users are more likely to engage with content that is uplifting or positive, suggesting a strong correlation between emotional appeal and user interaction.

* **Photography-Related Engagement**: Interestingly, three of the top eight tags are related to photography—blackandwhite (9), camera (8), and digitalmarketing (8). This highlights the interest of MiniGram's audience in visually-oriented content, making photography a key driver of engagement on the platform.

* **Sports and Fitness Tags**: Three out of the top twelve tags are associated with sports and fitness—gym (8), cardio (7), and biker (7). This shows that users interested in active lifestyles form a significant segment of the engaged community, making fitness-related content another important category for driving interactions.

**Influencers**:

* **Top Tags for Influencers**: Influencers on MiniGram predominantly use the tags bestoftheday, blackandwhite, comedy, quoteoftheday, and cute, with bestoftheday being the most popular at 33 instances. This suggests that influencers tend to focus on visually appealing or emotionally resonant content to engage their audiences.

* **Top Tags for Non-Influencers**: Non-influencers gravitate toward the tags blackandwhite, photography, comedy, motivation, and bestoftheday, with blackandwhite being the most frequently used at 751 instances. This indicates that non-influencers also place a strong emphasis on photography and motivational content to drive engagement.

* **Shared Tags Between Influencers and Non-Influencers**: The tags bestoftheday, blackandwhite, and comedy are commonly used by both influencers and non-influencers, highlighting that these themes resonate across different user groups and play a significant role in generating engagement regardless of follower count or influence level.

* **Difference in Activities**: There is no significant difference in the activity levels or activity rates between influencers and non-influencers, suggesting that it is not the volume of activity that drives someone to become an influencer, but rather an external factor that remains to be identified.

* **Engagement in Posts**: There is a significant disparity in user engagement between posts by influencers and non-influencers, with posts from influencers being 4.21 times more likely to receive interaction.

**Bots:**

**Year over Year Analysis:**



## Data Structure
MiniGram's database structure can be seen below consisting of 7 tables:
1. users
2. photos
3. tags
4. photo_tags
5. follows
6. likes
7. comments

![ERD MiniGram](https://github.com/user-attachments/assets/9913087b-bf00-49c7-8372-534c53ea1e6e)

## Limitations
The primary limitation of this project lies in the nature of the data, as it is based on synthetic data rather than real-world user interactions. As a result, the findings of this report may not perfectly mirror actual user behavior on social media platforms. However, the objective of this report is to analyze the unique dynamics of MiniGram's ecosystem. Therefore, it should be viewed as an analysis specific to this application, rather than a comprehensive reflection of broader social media trends.

## Recommendations
