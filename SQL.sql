-- --------------------------------------
-- SQL keywords 不区分大小写, 但是 表名, 列名 依赖于具体实现.
-- 测试 SQL 语句用 不带 ‘FROM’ 的 ‘SELECT’.
-- --------------------------------------

/* SQL 数据类型 (datatype)
TODO
*/

/* DML */

-- INSERT
-- -- INSERT 数据
-- ---- 未指定的列 置 NULL/默认值.
INSERT INTO people(id, name)
VALUES(10086, '张伟');
-- ---- 逐字段填充
INSERT INTO people
VALUES(10086, '后面省略 ...');
-- -- INSERT SELECT
INSERT INTO people(id, name)
SELECT id_number,  -- DBMS 不关心列名, 只关心位置.
       name
FROM old_people_table
WHERE id_number BETWEEN 1001 AND 2000;

-- 复制表 (Db2 不支持): 创建 (有些 DBMS 可以覆盖已存在的表) 一个全新的表并将部分行复制过去.
CREATE TABLE adults_with_accounts AS
SELECT people.id, people.name, COUNT(accounts.num)
FROM people
INNER JOIN accounts ON people.id = accounts.id  -- 可使用各种联结.
WHERE people.age >= 18  -- 实际上, 任何 ‘SELECT’ 选项和子句都可以使用.
GROUP BY people.id;
CREATE TABLE people_copy AS SELECT * FROM people;
SELECT * INTO people_copy FROM people;  -- SQL Server 的写法.

-- UPDATE 行
UPDATE people
SET name = '张伟',
     age = 24
WHERE id = 10086;  -- 省略 ‘WHERE’ 子句将会 更新所有行.

-- DELETE 行 (若要删除表中所有行, 使用 ‘TRUNCATE TABLE’ 速度更快, 因为它不记录数据的变动)
DELETE FROM people
WHERE name LIKE '李%';  -- 省略 ‘WHERE’ 子句将会 删除所有行.

/* DDL */
-- 查询数据库
SHOW DATABASES;  -- 查看所有数据库.
SELECT DATABASES();  -- 查看当前数据库.
-- 选择数据库
USE 数据库名字;
-- 创建表
CREATE TABLE people(
  id   CHAR(100) NOT NULL PRIMARY KEY,
  name CHAR(100) NOT NULL,
  birthday DATETIME NULL,  -- 某些 DBMS 要求指定 ‘NULL’, 有些 (e.g., Db2) 却必须省略 ‘NULL’.
  age INTEGER DEFAULT 1
);
-- 更新表 (的元数据): 所有 DBMS 都允许新增列 (但对新列的数据类型及属性有所限制); 许多 DBMS 不允许 删除/更改 原有列; 多数 DBMS 允许重命名原有列; 许多 DBMS 限制对已经填写过数据的列的更改, 但对未填写过数据的列几乎没有限制.
ALTER TABLE accounts
ADD opening_time DATETIME;
ALTER TABLE accounts
DROP COLUMN opening_time;
-- 删除表
DROP TABLE people_copy;

/* DQL */

-- 检索列
SELECT name, gender FROM people;

-- -- 检索所有列 (相当于显示整张 table)
SELECT * FROM people;

-- -- 给查询到的字段设置别名 (可省略 ‘AS’, 而 Oracle DB 根本没有该关键字)
SELECT field_1 AS 'alias_1', field_2 AS 'alias_2' FROM table_name;

-- -- 去重
-- -- : ‘DISTINCT’ 只能紧贴 ‘SELECT’ 之后, 作用于所有列, 将列的组合完全相同的行排除.
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

-- 计算字段
-- -- 算数运算 (加减乘除)
SELECT
  name,
  age - 18 AS grown_years
FROM people
WHERE age >= 18;

-- -- 函数:
-- --   LENGTH/DATALENGTH/LEN,
-- --   LEFT/RIGHT, LOWER/UPPER, TRIM/LTRIM/RTRIM, SUBSTR/SUBSTRING, CONCAT,
-- --   DATEPART, EXTRACT, YEAR,
-- --   ABS, COS, EXP, PI, SIN, SQRT, TAN
SELECT
  CONCAT(username, ' <', TRIM(email), '>') AS copyright_owner  -- ‘Alias’ 也称 ‘derived column’.
FROM people
WHERE SOUNDEX(username) = SOUNDEX('shiner')
ORDER BY username, copyright_owner;

-- -- 聚集函数:
-- --   AVG, MAX, MIN, SUM, COUNT (仅 “COUNT(*)” 会统计 ‘NULL’, 相当于计算行数)
SELECT AVG(ALL age),  -- ‘ALL’ 是默认的, 无需指明.
       COUNT(*),
       SUM(age - 18)
FROM people
WHERE gender = 'female';

SELECT COUNT(DISTINCT email) -- ‘DISTINCT’ 不能用于 “COUNT(*)”.
FROM people;

-- 分组查询 (分组之后, 只有被 分组的字段 和 聚集函数的结果 是有意义的)
--   ‘GROUP BY’ 跟的每一列必须是 物理检索列 (不能用别名) 或 表达式 (但不包括 聚集函数);
--   被 ‘SELECT’ 的每一列 (不包括 聚集函数) 都必须出现在 ‘GROUP BY’ 中;
--   ‘NULL’ 会被分组;
--   ‘GROUP BY’ 必须写在 ‘WHERE’ 之后, ‘ORDER BY’ 之前;
--   ‘WHERE’ 在数据 分组之前 过滤 行, 而 ‘HAVING’ 在 分组之后 过滤 分组.
SELECT address,
       COUNT(*) AS number_of_adults
FROM people
WHERE age >= 18
GROUP BY address HAVING COUNT(*) >= 10000000
ORDER BY number_of_adults DESC;  -- 这个例子还展示了 ‘SELECT’ 语句中各子句的书写顺序.

/* 子查询 (subquery)
   子查询总是从内向外处理
*/
-- 利用子查询进行过滤
SELECT name
FROM people
WHERE id IN(
    SELECT id
    FROM accounts
    WHERE deposit > 200000
);
-- 作为计算字段使用子查询
SELECT name,
       (SELECT COUNT(*)
        FROM accounts
        WHERE accounts.id = name.id) AS number_of_accounts
FROM people
GROUP BY name;

/* 联结 (join)
   通常 DBMS 处理联结比子查询更快.
   应该总是提供联结条件, 否则会返回 Cartesian product.
   在一个联结中可以包含多个表, 甚至可以对每个联结采用不同的联结类型.
*/

-- 等值联结 (equijoin) / 内联结 (inner-join)
SELECT bill_date,
       num,
       name
FROM bills,
     accounts,
     people
WHERE bill_date > {d '2012-12-21'}  -- ODBC 日期格式
      AND bills.out_account = accounts.num
      AND accounts.id = people.id;
-- -- 标准语法
SELECT bill_date,
       num,
       name
FROM bills
INNER JOIN accounts ON bills.out_account = accounts.num
INNER JOIN people ON accounts.id = people.id
WHERE bill_date > {d '2012-12-21'};
-- 自联结 (self-join)
SELECT people_alias1.name
FROM people AS people_alias1,  -- 自联结必须使用别名.
     people AS people_alias2
WHERE people_alias1.age = people_alias2.age
      AND people_alias2.name = 'Xie Qi';  -- 查找同龄人.
-- 自然联结 (natural join): 例子略.
-- 外联结 (outer join):
--     必须用 ‘LEFT’ 或 ‘RIGHT’ 指定包括所有行的表.  ‘LEFT’ 指的是 ‘OUTER JOIN’ 左侧的表.  有些 DB (e.g., SQLite) 仅支持 ‘LEFT’ 外联结.
--     调整 ‘FROM’ 或 ‘WHERE’ 子句中表的顺序, 左外联结可以转换为右外联结.
SELECT people.id,
       accounts.num
FROM people  -- 列出所有人的所有银行账户, 包括那些未开户的人.
LEFT OUTER JOIN accounts ON people.id = accounts.id;
-- 在联结中使用聚集函数
SELECT people.id,
       COUNT(accounts.num)
FROM people
LEFT OUTER JOIN accounts ON people.id = accounts.id
GROUP BY people.id;

/* 组合查询 (union, compound query)
     规则: 每个查询必须包含相同的 列/表达式/聚集函数, 但各列不需要以相同的次序列出;
           列的数据类型必须兼容 (i.e., DBMS 能隐含转换).
           (综上可以看出, ‘UNION’ 可以组合多个不同的表, 即使表的列名不匹配, 此时可以使用别名来处理这种情况.)
*/
SELECT id, name
FROM people
WHERE TRIM(name) LIKE '张_'
UNION  -- 补上 ‘ALL’ 则 不去重, 这是 ‘WHERE’ 完成不了的工作.
SELECT id, name
FROM people
WHERE TRIM(name) LIKE '_伟'
ORDER BY id;  -- ‘UNION’ 查询只能使用一条 ‘ORDER BY’ 子句, 且必须位于最后.

/* 视图
     视图本身不包含数据, 它包含的是一条查询语句.  因此每次使用视图时都必须处理查询执行时需要的所有检索.
     常见的规则于限制:
       - 名字唯一 (表和视图使用同一命名空间);
       - 许多 DBMS 禁止在视图查询中使用 ‘ORDER BY’ 子句;
       - 有些 DBMS 要求对返回的所有列进行命名 (如果列是计算字段, 则需使用别名);
       - 视图不能索引, 也不能有关联的触发器或默认值;
       - 有些 DBMS (e.g., SQLite) 把视图作为只读的查询 (可以从视图检索数据, 但不能将数据写回底层表).
*/
-- 更新视图 (的元数据) 必须先 删除 它, 然后在重新创建.
DROP VIEW people_with_account;
-- 创建视图
CREATE VIEW people_with_account AS
SELECT RTRIM(name) + ' (' + people.id + ')' AS person,
       num
FROM people,
     accounts
WHERE people.id = accounts.id;

/* 存储过程
     类似于批处理.
     存储过程通常以编译过的形式存储, 因此 DBMS 处理命令所需的工作量更少.
     存储过程的调用方式大同小异 (通常使用 ‘EXECUTE’ 从句), 但不同 DBMS 编写存储过程的差异很大.
   (SQLite 不支持存储过程.)
*/

/* 事务处理 (transaction processing)
     可以 rollback 哪些语句?  事务处理用来管理 ‘INSERT’, ‘UPDATE’ 和 ‘DELETE’ 语句; 不能回退 ‘SELECT’ 语句 (回退它也没必要), 也不能回退 ‘CREATE’ 或 ‘DROP’ 操作 (事务处理中可以使用这些语句, 但进行回退时这些操作也不撤销).
*/
DROP PROCEDURE my_PROCEDURE;

/* 游标 (cursor)
   一些常见的选项和特性:
     - 能标记游标为只读, 使数据不能更新和删除.
     - 能控制可以执行的 navigation 操作 (e.g., 向前/后, 首/尾端, 相对/绝对位置).
     - 能标记某些列为 (不) 可编辑的.
     - 规定范围.
     - 指示 DBMS 对检索出的数据 (而不是指出表中活动数据) 进行复制, 使数据在游标打开和访问期间不变化.
   Usage:
     1. 声明 (定义) 游标.  这个过程实际上没有检索数据, 此时只是定义要使用的 ‘SELECT’ 语句和游标选项.
     2. 打开游标, 执行此前定义的 ‘SELECT’ 语句以实际检索出数据, 并存储它们以供浏览和滚动.
     3. 按需取出各行.
     4. 关闭游标; 对于某些 DBMS (e.g., SQL Server), 还需释放游标 (IOW, 游标所占用的资源).
     5. 根据需要再次打开游标.
*/
-- 创建游标
DECLARE adult_cursor CURSOR FOR
SELECT * FROM people
WHERE age >= 18;  -- Db2, MariaDB, MySQL 和 SQL Server 的语法.
DECLARE CURSOR adult_cursor IS
SELECT * FROM people
WHERE age >= 18;  -- Oracle 和 PostgreSQL 的语法.
-- 打开游标
OPEN CURSOR adult_cursor;
-- FETCH 指出要检索哪些行, 从何处检索它们, 将它们放到何处 (e.g., 变量).
-- 关闭游标
CLOSE adult_cursor;  -- Db2, Oracle 和 PostgreSQL 的语法.
CLOSE adult_cursor DEALLOCATE CURSOR adult_cursor;  -- Microsoft SQL Server 的语法.

/* 约束 (constraint) */

-- 主键:
--   表中任意列只要满足以下条件, 就可用作主键:
--     - 唯一 (UNIQUE).
--     - 非空 (non-NULL).
--     - 包含主键值的列从不修改或更新 (少数 DBMS 允许这么做).
--     - 主键值不能复用, i.e., 若删除某行, 其主键值不能分配给新行.
--   每个表只允许一个主键.
-- -- 使用 ‘CONSTRAINT’ 语法定义主键
ALTER TABLE people
ADD CONSTRAINT PRIMARY KEY (id);

-- 外键:
--   其值必须列在另一表的主键中, 以加强引用完整性 (referential integrity).
--   有些 DBMS 支持 cascading delete, 在下面的例子中表现为, 删除 people 中的某行, 将自动删除与之关联的位于 accounts 中的行.
-- -- 在 ‘CREATE TABLE’ 中定义
-- -- 使用 ‘CONSTRAINT’ 语法定义外键
ALTER TABLE accounts
ADD CONSTRAINT FOREIGN KEY (id) REFERENCES people(id);

-- 唯一
--   可包含 NULL 值; 可修改或更新; 可复用; 不能用来定义外键.
-- -- 在 ‘CREATE TABLE’ 中定义
-- -- 使用 ‘CONSTRAINT’ 语法进行唯一约束

-- 检查约束: 以保证一 (组) 列中的数据满足指定的条件.
--   有些 DBMS 允许用户自定义数据类型, 它们可能会自带检查约束.
-- -- 在 ‘CREATE TABLE’ 中定义
-- -- 使用 ‘CONSTRAINT’ 语法进行唯一约束
ALTER TABLE accounts
ADD CONSTRAINT CHECK (num >= 1);

CREATE TABLE accounts(
  num INT       NOT NULL CHECK (num >= 1) PRIMARY KEY,
  id  CHAR(100) NOT NULL                  REFERENCES people(id)
);

/* 索引
主键数据总是排序的 (这是 DBMS 的工作), 因此, 按主键检索特定行总是高效的.  但搜索其它列中的值通常效率不高, 除非使用索引.
特性:
  - 改善检索的性能, 但降低了 INSERT/UPDATE/DELETE 的性能.
  - 占用额外的存储空间.
  - 有些数据并不适合添加索引, e.g., 可取值较少的列 (e.g., 性别).
  - 可在列的组合上定义索引.  E.g., 在索引中定义“省+市”, 则在“省+市”排序时有用, 但单独的“省”/“市”排序时可能就没有用.
*/
CREATE INDEX birthday_INDEX  -- 索引必须唯一命名.
ON people(birthday);
DROP INDEX birthday_INDEX;

/* 触发器
触发器是特殊的存储过程, 可以与特定表上的 INSERT/UPDATE/DELETE 操作 (或组合) 相关联, 在特定的操作执行之前或之后被触发.
触发器内的代码具有以下数据的访问权:
  - 被 insert 的新数据.
  - 被 update 的旧数据与新数据.
  - 被 detele 的旧数据.
N.b., 约束 比 触发器 更早.
*/


-- ------------------
-- Local Variables:
-- coding: utf-8-unix
-- sql-dialect: ansi
-- End:
