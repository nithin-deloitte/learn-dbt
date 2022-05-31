# Mini Assignment Document

**This markdown file documents the steps I followed to complete this mini assignment**

### 1. Download and extract data

- I downloaded the data from the given URL [here](https://archive.org/download/stackexchange/askubuntu.com.7z).
- Second I extracted the data into a common location in my computer

*Note: I first tried to uplaod data from xml files directly via the UI, 
then tried to use `Talend` to upload the large data files to Snowflake, 
both of these just errored out due to large size of the files.*

### 2. Data splitting

- I used a Python script to split the large files into smaller ones based on `split_num`.
- For each file, I would change the `test.xml` location as well as the `split_num` value based on size.
- This script would create the required splitting of XML files with just the rows as data 
```py
import xml.etree.ElementTree as ET
# context = ET.iterparse('Posts.xml', events=('start' , 'end'))
file = open('test.xml', 'r', encoding="utf-8" ) # mbcs or utf-8
tree = ET.parse(file)

split_num = 50000

index = 1
itr = 0

li = tree.findall('row')
wf = open(format("split/" + str(itr) + '.xml'), 'wb')

for i in li:
    if index % split_num == 0:
        itr += 1
        wf = open(format("split/" + str(itr) + '.xml'), 'wb')
        # wf.write(b"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    wf.write(ET.tostring(i))
    index += 1
    pass
```

### 3. Snowflake setup

- I setup the snowflake databases, warehouse, schema, role, permissions, etc
- Next I created the **file format**
```sql
create or replace file format xml_load_badges
type = 'XML'
compression = 'AUTO'
;
```
- Then I created the **stage table**
```sql
create or replace table badges_xml (
    src_xml variant
);
```
- I did the same for all tables (XML files in the downloaded ZIP) 


### 4. Download, install and use `snowSQL`

- Next, I had to install `snowSQL`
- I had to login to `snowSQL` on my terminal with the commands,
- ```snowsql -a pbb85879.us-east-1 -u ninjaasmoke```
- Then enter the password, and then set up all the required configurations, like
```sql
$ use ROLE TRANSFORM_ROLE
$ use WAREHOUSE TRANSFORM_WH
$ use DATABASE MINI_ASSIGNMENT
$ use SCHEMA DBT
```
- From here I could use `PUT` and `COPY` commands to upload data to Snowflake
- Example,
``` 
put file:///C:/src/split/badges/*.xml @xmy_stage_badges
copy into badges_xml from @xmy_stage_badges
```
- This venture would take a lot of time (to `PUT` into staging and then `COPY` to the XML table)

### 5. Back to snowflake

- Back in snowflake, I would now create a table for the data I just copied into it's XML table, like
```SQL
create table BADGES (
  Id INTEGER PRIMARY KEY,
  Name varchar,
  Date datetime,
  Class INTEGER,
  Tag_based boolean,
  user_id INTEGER
);
```
- Next, I would insert into the `BADGES` table from `BADGES_XML` using the `insert` command like,

```SQL
insert into BADGES (Id, Name, Date, Class, Tag_Based, user_id) 
select src_xml:"@Id", src_xml:"@Name", src_xml:"@Date", src_xml:"@Class", src_xml:"@TagBased", src_xml:"@UserId" from badges_xml
```
- Here, I found how to use the "$", "@" and "@attribute_name" after reading the docs [@snowflake](https://docs.snowflake.com/en/sql-reference/functions/xmlget.html#usage-notes)

### 6. Repeat
- I did the same for all the files in the zip

### 7. SQL queries

- Now I had to complete the assignment by adding the sql queries.

**REPUTATION**
Find top 10 users with the highest reputation. Print their id, displayname and reputation. Sort by highest reputation first. 
```SQL
select id, display_name, reputation from users order by reputation desc limit 10
```

**QUESTIONS**
Print the text of questions asked by user whose display name is alexandrul.  
```SQL
select body, owner_user_id from posts, users as u where POST_TYPE_ID=1 AND owner_user_id=u.id AND display_name='alexandrul'
```

**QUESTIONS_LIKE**
Print the text of questions asked by user whose display name contains the string “nau” 
```SQL
select body, u.display_name from posts, users as u where POST_TYPE_ID=1 AND owner_user_id=u.id AND u.display_name LIKE '%nau%'
```

**MOST POPULAR BADGES**
Print the 10 most popular badges, sorted by the number of users who have these badges. 
```SQL
select name, count(*) from badges group by name order by count(*) desc limit 10
```

**QUESTIONCOUNT**
For users who have a reputation greater than 75000, print their userid, displayname, reputation and the total number of questions they have asked.  
```sql
select
    u.id, u.display_name, u.reputation
from users as u, posts as p
where u.REPUTATION >= 75000
order by u.reputation desc
```
