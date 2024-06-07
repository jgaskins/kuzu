# kuzu

[Kuzu](https://kuzudb.com/) is an embedded property-graph database.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     kuzu:
       github: jgaskins/kuzu
   ```

2. Run `shards install`

## Usage

```crystal
require "kuzu"

kuzu = Kuzu::Client.new("/path/to/db")
```

### Running a query

Use `Kuzu::Client#query` to run a query that retrieves data, specifying the types of the return values, and a block that yields those return values for each matching result.

```crystal
kuzu.query "MATCH (user:User) RETURN user.name", as: {String} do |(name)|
  # ...
end
```

### Running a query without a return value

The `Kuzu::Client#execute` method executes a query against the database that does not return a value. You can use this method when running [DDL queries](https://docs.kuzudb.com/cypher/data-definition/) and some [DML queries](https://docs.kuzudb.com/cypher/data-manipulation-clauses/) that don't require a `RETURN` clause.

As a rule of thumb, use `query` if your query has a `RETURN` clause and `execute` if it does not.

### Prepared queries

Not yet implemented in this client, but they will be.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/jgaskins/kuzu/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jamie Gaskins](https://github.com/jgaskins) - creator and maintainer
