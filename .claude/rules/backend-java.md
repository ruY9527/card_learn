# Java 后端编码规范 (强化版)

## 1. 项目分层与职责

- **必须**严格遵循 `Controller → Service → Mapper` 三层调用链，禁止跨层调用。
- **Controller 层**职责仅限：
  - 接收和校验请求参数（`@Valid` / `@Validated`）
  - 调用 Service 层方法
  - 将 Service 返回的 DTO/VO 包装为统一响应格式（`Result<T>`）返回
- **禁止**在 Controller 中：
  - 直接操作数据库（调用 Mapper）
  - 包含任何业务计算或判断
  - 手动 try-catch 业务异常（应抛给统一异常拦截器）
- **Service 层**是所有业务逻辑的唯一栖息地，必须包含：
  - 数据校验（对复杂业务规则，即使 Controller 已做基础校验，Service 仍要检查）
  - 业务计算、规则判断、状态流转
  - 事务管理（`@Transactional`）
  - 调用多个 Mapper 时的数据组装与协调
- 当 Service 类超过 **500 行** 时，必须抽取独立的 Domain Service 或 使用策略/模板模式拆分。

---

## 2. 命名规范

| 元素 | 规则 | 示例 |
|------|------|------|
| 类名 | `UpperCamelCase`，接口不加 `I` 前缀 | `UserService`, `OrderMapper` |
| 方法名 | `lowerCamelCase`，动词开头 | `createOrder`, `findUserById` |
| 变量名 | `lowerCamelCase` | `orderList`, `userId` |
| 常量 | 全大写 + 下划线 | `MAX_RETRY_COUNT` |
| 包名 | 全小写，按层与模块划分 | `com.example.order.service` |
| 数据库实体 | 与表名对应，`PascalCase` | `Order`, `UserInfo` |
| DTO/VO | 后缀明确 | `OrderCreateDTO`, `UserVO` |

---

## 3. MyBatis 与 SQL 编写规则（重点强化）

### 3.1 XML 与注解的选择

- **强制**所有 SQL 语句写在 XML 映射文件中，**禁止**在 Mapper 接口使用 `@Select`、`@Insert`、`@Update`、`@Delete` 注解。
- 每条 SQL 必须拥有有意义的 `id`，且与 Mapper 接口方法名完全一致。

### 3.2 SQL 中禁止业务计算

- **绝对禁止**在 SQL 中进行任何业务相关计算，包括但不限于：
  - 算术运算：`price * quantity`
  - 复杂 `CASE WHEN` 业务规则判断（如根据金额、等级人工分段）
  - 日期函数进行业务差值计算（如 `DATEDIFF` 算账期）
- **允许的 SQL 计算**仅限于：
  - 数据库自身维护的聚合（`COUNT`, `SUM`, `AVG` 等统计类，但返回结果应映射为 DTO，禁止在 SQL 中做进一步逻辑加工）
  - 简单的 `CASE WHEN` 用于数据格式兼容（如枚举转文本），但不得承载业务规则。
- **所有计算逻辑必须迁移到 Service 层**，利用 Java 的面向对象特性实现复用和测试。

### 3.3 SQL 可读性要求

- SQL 关键字**必须**全部大写。
- 每个主要子句（`SELECT`, `FROM`, `WHERE`, `ORDER BY`, `GROUP BY`, `JOIN` …）**单独起一行**。
- 字段列表每行列一个字段（简单查询不超过 5 个字段时可单行）。
- 必须为复杂查询添加注释，说明业务目的、关联关系。
- 动态 SQL（`<if>`, `<choose>`, `<foreach>`）必须保持缩进对齐，保证 XML 可读性。

### 3.4 参数绑定与安全

- **禁止** SQL 注入风险：所有参数**必须**使用 `#{}` 占位符，**禁止**直接在 XML 中拼接 `${}`（除非是表名、字段名等动态标识符，且必须通过白名单校验）。
- 动态表名/字段名如需使用 `${}`，必须在 Service 层做白名单验证后才传入。

### 3.5 结果映射

- 查询结果**禁止**直接映射到数据库实体（带 `@Entity` 或 `@Table` 注解的类），必须映射到专门的 **DTO 或 View Object**。
- 多表关联查询的结果必须定义对应的结果 DTO，并使用 MyBatis 的 `resultMap` 或 `@Result` 明确映射，**禁止**依赖自动驼峰映射跳过字段检查。

### 3.6 分页规范

- 分页查询**必须统一**使用 PageHelper 或 MyBatis Plus 的 `Page` 对象，**禁止**手动在 SQL 中拼接 `LIMIT` 和偏移量。
- 分页方法命名统一后缀 `ByPage`，返回 `PageInfo<T>` 或 `IPage<T>`。

### 3.7 复杂查询与性能

- **禁止**使用 `SELECT *`，必须显式列出所需字段，即使该表字段全部需要也应逐一书写（防止表结构变更导致意外）。
- 关联查询超过 **3 张表**时，必须评估性能，优先考虑在 Service 层分步查询后组装，而非写出巨型 JOIN。
- 对于大数据量查询，必须考虑索引使用情况，并在 XML 上方用注释说明预期的索引命中路径。

### 3.8 示例：符合规范的 MyBatis XML

```xml
<!-- OrderMapper.xml -->
<select id="findOrderDetailById" resultMap="OrderDetailDTOMap">
    -- 查询订单详情及用户基础信息
    SELECT
        o.id              AS order_id,
        o.order_no        AS order_no,
        o.price           AS price,
        o.quantity        AS quantity,
        o.status          AS status,
        u.id              AS user_id,
        u.name            AS user_name
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.id
    WHERE o.id = #{orderId}
</select>

<resultMap id="OrderDetailDTOMap" type="com.example.dto.OrderDetailDTO">
    <id property="orderId" column="order_id"/>
    <result property="orderNo" column="order_no"/>
    <result property="price" column="price"/>
    <result property="quantity" column="quantity"/>
    <result property="status" column="status"/>
    <association property="user" javaType="com.example.dto.UserBriefDTO">
        <id property="id" column="user_id"/>
        <result property="name" column="user_name"/>
    </association>
</resultMap>


## 4. 面向对象与复用

- **必须**遵循"组合优于继承"原则，字段复用时优先使用组合（如提取公共字段到 `BaseEntity` 用 `@MappedSuperclass` 属于继承，但要节制）。
- 发现两次以上重复逻辑（校验、转换、工具方法）**必须**抽取为公共方法或工具类。
- **鼓励**使用策略模式、模板方法等设计模式消除 `if-else` 分支，但不要过度设计。
- 数据传输对象（DTO/VO）**必须**与数据库实体（Entity）分离，不允许直接暴露实体。

## 5. 异常处理与日志

- **必须**使用统一异常拦截器（`@ControllerAdvice`）处理所有异常，Controller 内不得 `try-catch` 业务异常。
- 业务异常**禁止**直接抛出 `RuntimeException`，必须使用自定义业务异常类（如 `BusinessException`）并携带错误码。
- 日志**必须**使用 SLF4j 门面，用 `@Slf4j` 注解引入。
- 关键方法入口、出口、异常分支**必须**打印日志，日志级别：info 用于关键流程，debug 用于调试细节，error 用于异常。
- **禁止**在循环或高频调用中使用 `System.out.println` 或 `e.printStackTrace()`。


## 6. 代码格式

- 缩进 4 个空格，禁止使用 Tab。
- 单行最大 120 字符。
- 所有 `if/for/while` **必须**使用大括号，即使只有一行。
- 使用 Lombok 简化代码（`@Data`, `@Builder` 等），但**禁止**在 `@Entity` 类上使用 `@Data`（避免 JPA 代理问题），可用 `@Getter`, `@Setter`。
