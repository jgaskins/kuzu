require "kuzu"

db = Kuzu::Client.new("/tmp/test-db")

db.execute "CREATE NODE TABLE User(id UUID, name String, PRIMARY KEY (id))"
db.query "CREATE (user:User{id: gen_random_uuid(), name: 'Jamie'}) RETURN user", as: {User} do |(user)|
  p! user
end

db.query <<-CYPHER, as: {Int64?, String} do |int, string|
  UNWIND [1, 2, 3, null, 4] AS value
  RETURN value, "lol"
CYPHER
  p! int, string.downcase
end

db.query "RETURN gen_random_uuid()", as: {UUID} do |(uuid)|
  p! uuid
end

db.query "RETURN timestamp('2024-06-10T12:34:56.789123456-05:00')", as: {Time} do |(time)|
  p! time
end

struct User < Kuzu::Node
  getter id : UUID
  getter name : String
end
