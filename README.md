# Famous Paintings & Museums - SQL Project

## Project Overview

This project explores the Famous Paintings & Museum dataset by solving SQL problems to extract meaningful insights about museums, paintings, artists, and canvas sizes. It involves analyzing relationships between entities, handling invalid data, and optimizing queries for better performance.

---

## Database Schema

The Famous Paintings & Museum dataset includes the following tables and their relationships:

### 1. `artist`
- **Columns:**
  - `artist_id` (BIGINT, Primary Key)
  - `full_name` (TEXT)
  - `first_name` (TEXT)
  - `middle_names` (TEXT)
  - `last_name` (TEXT)
  - `nationality` (TEXT)
  - `style` (TEXT)
  - `birth` (BIGINT)
  - `death` (BIGINT)

### 2. `work`
- **Columns:**
  - `work_id` (BIGINT, Primary Key)
  - `name` (TEXT)
  - `artist_id` (BIGINT, Foreign Key to `artist.artist_id`)
  - `style` (TEXT)
  - `museum_id` (BIGINT, Foreign Key to `museum.museum_id`)

### 3. `subject`
- **Columns:**
  - `work_id` (BIGINT, Foreign Key to `work.work_id`)
  - `subject` (TEXT)
- **Primary Key:** (`work_id`, `subject`)

### 4. `image_link`
- **Columns:**
  - `work_id` (BIGINT, Primary Key, Foreign Key to `work.work_id`)
  - `url` (TEXT)
  - `thumbnail_small_url` (TEXT)
  - `thumbnail_large_url` (TEXT)

### 5. `product_size`
- **Columns:**
  - `work_id` (BIGINT, Foreign Key to `work.work_id`)
  - `size_id` (BIGINT, Foreign Key to `canvas_size.size_id`)
  - `sale_price` (DOUBLE)
  - `regular_price` (DOUBLE)
- **Primary Key:** (`work_id`, `size_id`)

### 6. `canvas_size`
- **Columns:**
  - `size_id` (BIGINT, Primary Key)
  - `width` (DOUBLE)
  - `height` (DOUBLE)
  - `label` (TEXT)

### 7. `museum`
- **Columns:**
  - `museum_id` (BIGINT, Primary Key)
  - `name` (TEXT)
  - `address` (TEXT)
  - `city` (TEXT)
  - `state` (TEXT)
  - `postal` (TEXT)
  - `country` (TEXT)
  - `phone` (TEXT)
  - `url` (TEXT)

### 8. `museum_hours`
- **Columns:**
  - `museum_id` (BIGINT, Foreign Key to `museum.museum_id`)
  - `day` (TEXT)
  - `open` (TEXT)
  - `close` (TEXT)

### Schema Diagram

![Database Schema](C:\Users\Hritik Kadam\Desktop\SQL\Famous Painting Case Study\Schema.png)

> **Note:** Update the image link above with your schema diagram file (`schema_image.png`) to visualize the relationships.

---

## SQL Problems Solved

This project solves the following SQL queries to explore and analyze the dataset:

1. **Fetch all the paintings which are not displayed on any museums?**
2. **Are there museums without any paintings?**
3. **How many paintings have an asking price of more than their regular price?**
4. **Identify the paintings whose asking price is less than 50% of its regular price.**
5. **Which canvas size costs the most?**
6. **Delete duplicate records from work, product_size, subject, and image_link tables.**
7. **Identify the museums with invalid city information in the given dataset.**
8. **Fetch the top 10 most famous painting subjects.**
9. **Identify the museums which are open on both Sunday and Monday. Display museum name, city.**
10. **How many museums are open every single day?**
11. **Which are the top 5 most popular museums? (Popularity is defined based on the highest number of paintings in a museum).**
12. **Who are the top 5 most popular artists? (Popularity is defined based on the highest number of paintings by an artist).**
13. **Display the 3 least popular canvas sizes.**
14. **Which museum is open for the longest during a day? Display museum name, state, and hours open.**
15. **Which museum has the most number of the most popular painting style?**
16. **Identify the artists whose paintings are displayed in multiple countries.**
17. **Display the country and the city with the most number of museums.**
18. **Identify the artist and the museum where the most expensive and least expensive painting is placed.**
19. **Which country has the 5th highest number of paintings?**
20. **Which are the 3 most popular and 3 least popular painting styles?**
21. **Which artist has the most number of Portrait paintings outside the USA?**

---

## Data

You can download the dataset from the following link:

[Download Dataset]([data/your_dataset_file.zip](https://github.com/Hritik74/Famous_Paintings_Case_Study/blob/main/Famous%20Painting%20Case%20Study%20Data.zip))

---
