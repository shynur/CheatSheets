/* DML */

-- 添加数据
---- 未指定的字段留空
INSERT INTO table_name(field_1, field_3)
  VALUES(value_1, value_3),
        (value_1, value_3);
---- 逐字段填充
INSERT INTO table_name
  VALUES(value_1, value_2, value_3);

-- 更新数据
---- 更新所有
UPDATE table_name
  SET field_1 = value_1,
      field_3 = value_3;
---- 更新指定条目
UPDATE table_name
  SET field_1 = value_1
  WHERE field_3 = value_3;

-- 删除数据
DELETE FROM table_name;
DELETE FROM table_name
  WHERE field_2 = value_2;

/* DQL */

-- 查询字段
SELECT field_1 FROM table_name;
---- 查询所有字段 (相当于显示整张 table)
SELECT * FROM table_name;
---- 给查询到的字段设置别名 (可省略 ‘AS’)
SELECT field_1 AS 'alias_1', field_2 AS 'alias_2' FROM table_name;
---- 去重
SELECT DISTINCT field_1 FROM table_name;

-- 条件查询 WHERE
/*
   比较:
     <, =, >, <=, >=, <> 或 !=,
     BETWEEN min AND max, IN(...), LIKE, IS NULL
   逻辑运算:
     AND, OR, NOT
*/
SELECT * FROM people
       WHERE age = 20
             AND height BETWEEN 160 AND 180
             AND party IS NOT NULL
             AND gender IN('male', 'female')
             AND name LIKE '姓_%';

-- 聚合函数 (‘NULL’ 不参与计算)
/* COUNT, AVG, MAX, MIN, SUM */
---- ‘COUNT’
------ 统计行数 (即使行中全是 ‘NULL’)
SELECT COUNT(*) FROM people;
------ 统计非 ‘NULL’ 字段
SELECT COUNT(party) FROM people;
---- ‘AVG’
SELECT AVG(age) FROM people;

-- 分组查询 (分组之后, 只有被分组的字段和聚合函数是有意义的)
---- 统计男女人数
SELECT gender, COUNT(*)
       FROM people
       WHERE gender IN('男', '女')
       GROUP BY gender;
---- 1. 只考虑成年人; 2. 按地区分组, 算出各地区人数; 3. 保留人数达到一千万的行.
SELECT address,
       COUNT(*) AS 地区人口
  FROM people
  WHERE age >= 18
  GROUP BY address
  HAVING 地区人口 >= 10000000;

-- Local Variables:
-- coding: utf-8-unix
-- eval: (abbrev-mode)
-- End:
