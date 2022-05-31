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
```
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
```snowsql
$ use ROLE TRANSFORM_ROLE
$ use WAREHOUSE TRANSFORM_WH
$ use DATABASE MINI_ASSIGNMENT
$ use SCHEMA DBT
```
- From here I could use `PUT` and `COPY` commands to upload data to Snowflake
