SELECT COUNT(*) FROM emp
  WHERE age BETWEEN 20 AND 40
  GROUP BY gender;

-- --------------------------------------
-- SQL keywords 不区分大小写, 但是 表名, 列名 依赖于具体实现
-- --------------------------------------

/* DML */

-- 添加数据
---- 未指定的字段置 NULL
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

-- 检索列
SELECT name, gender FROM people;

---- 检索所有列 (相当于显示整张 table)
SELECT * FROM people;

---- 给查询到的字段设置别名 (可省略 ‘AS’)
SELECT field_1 AS 'alias_1', field_2 AS 'alias_2' FROM table_name;

---- 去重
---- : ‘DISTINCT’ 只能紧贴 ‘SELECT’ 之后, 作用于所有列, 将列的组合完全相同的行排除.
SELECT DISTINCT age, gender FROM people;

-- 排序 (默认升序): ‘ORDER BY’
--   ASC/ASCENDING, DESC/DESCENDING
-- ‘ORDER BY’ 应当是 ‘SELECT’ 的最后一条 clause.
SELECT age, birthday FROM people ORDER BY 1 ASC, 2 DESC, name;

-- 条件查询: ‘WHERE’ (位于 ‘FROM’ 之后, ‘ORDER BY’ 之前)
-- 比较:
--   <, =, >, <= 或 !>, >= 或 !<, <> 或 !=,
--   BETWEEN min AND max, IS NULL, IN (可以包含其它 ‘SELECT’ 语句), LIKE
-- 逻辑运算:
--   AND (结合性高于 ‘OR’), OR, NOT (可以放在要过滤的列 之前 或 之后)
SELECT name FROM people
       WHERE age = 20
             AND height BETWEEN 160 AND 180
             -- 不该指望通过 取反条件/通配 (e.g., age != 20; LIKE '%') 来返回含 NULL 的行.
             AND party IS NULL
             AND (NOT gender NOT IN('male', 'female')
                  -- 有些 DBMS 会在字符串类型的字段后填充空格, 此时则需要用函数去掉右端空格.
                  OR username LIKE '[^rt]__%');

-- 聚合函数 (‘NULL’ 不参与计算)
--   COUNT, AVG, MAX, MIN, SUM
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

-- -------------------
-- Local Variables:
-- coding: utf-8-unix
-- sql-dialect: 'ansi
-- eval: (abbrev-mode)
-- End:
