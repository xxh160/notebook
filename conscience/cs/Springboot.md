# Springboot 笔记 故障排查

## Mybatis Dynamic Sql Support

获取自增主键：

在对应`Mapper`文件中加上`@Option...`

```java
@InsertProvider(type = SqlProviderAdapter.class, method = "insert")
@Options(useGeneratedKeys = true, keyProperty = "record.id")
int insert(InsertStatementProvider<Comment> insertStatement);
```

`@Option...`换成这个也可以：

```java
@SelectKey(statement = "SELECT LAST_INSERT_ID()", keyProperty = "record.id", before = false, resultType = Integer.class)
```

也可以。
