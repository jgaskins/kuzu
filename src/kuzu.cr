require "uuid"
require "db/pool"

require "./version"
require "./libkuzu"
require "./errors"

module Kuzu
  def self.null?(value : LibKuzu::Value*)
    LibKuzu.value_is_null value
  end

  class Client
    getter db_name : String
    @db : LibKuzu::Database*

    def initialize(@db_name, @config = Config.new)
      db = Pointer(LibKuzu::Database).malloc
      LibKuzu.database_init(@db_name, c_config(@config), db)
      @db = db

      pool_options = DB::Pool::Options.new(
        max_idle_pool_size: 25,
      )
      @pool = DB::Pool(Connection).new(pool_options) do
        connection = Pointer(LibKuzu::Connection).malloc

        case state = LibKuzu.connection_init(@db, connection)
        in .success?
          Connection.new(connection)
        in .error?
          raise CannotAllocateConnection.new("Cannot allocate connection for DB #{@db_name}")
        end
      end
    end

    def query(query : String, as type : Tuple(*T)) forall T
      @pool.checkout &.query query, as: type do |result|
        yield result
      end
    end

    def execute(query : String)
      @pool.checkout &.execute query
    end

    def finalize
      LibKuzu.database_destroy @db
    end

    private def c_config(config : Config) : LibKuzu::SystemConfig
      LibKuzu::SystemConfig.new(
        buffer_pool_size: config.buffer_pool_size,
        max_num_threads: config.max_num_threads,
        enable_compression: config.enable_compression?,
        read_only: config.read_only?,
        max_db_size: config.max_db_size,
      )
    end
  end

  class Connection
    @connection : LibKuzu::Connection*

    def initialize(@connection)
    end

    def query(query : String, as type : Tuple(*T)) forall T
      result = Pointer(LibKuzu::QueryResult).malloc

      case LibKuzu.connection_query(@connection, query, result)
      in .success?
        query_result = QueryResult(T).new(result)

        query_result.each do |result|
          yield result
        end
      in .error?
        error_msg = LibKuzu.query_result_get_error_message(result)
        LibKuzu.query_result_destroy result
        raise QueryError.new("Error executing query: #{String.from_c_string error_msg}")
      end
    end

    def execute(query : String)
      result = Pointer(LibKuzu::QueryResult).malloc

      begin
        case LibKuzu.connection_query(@connection, query, result)
        in .success?
        in .error?
          error_msg = LibKuzu.query_result_get_error_message(result)
          raise QueryError.new("Error executing query: #{String.from_c_string error_msg}")
        end
      ensure
        LibKuzu.query_result_destroy result
      end
    end

    def close
      @closed = true
    end

    getter? closed = false

    def finalize
      LibKuzu.connection_destroy @connection
    end
  end

  class QueryResult(T)
    @query_result : LibKuzu::QueryResult*

    def initialize(@query_result)
    end

    def each
      tuple_count = 0
      tuple_value = Pointer(LibKuzu::FlatTuple).malloc
      begin
        while LibKuzu.query_result_has_next(@query_result)
          case LibKuzu.query_result_get_next(@query_result, tuple_value)
          in .success?
            yield T.from_kuzu_tuple tuple_value
          in .error?
            raise QueryError.new("Could not retrieve next tuple from the database")
          end
        end
      ensure
        LibKuzu.flat_tuple_destroy tuple_value
      end
    end

    def finalize
      LibKuzu.query_result_destroy @query_result
    end
  end

  struct Config
    DEFAULT_BUFFER_POOL_SIZE = 512u64 * 1024 * 1024 # 512MB

    getter buffer_pool_size : UInt64
    getter max_num_threads : UInt64
    getter? enable_compression
    getter? read_only
    getter max_db_size : UInt64

    def initialize(
      @buffer_pool_size = DEFAULT_BUFFER_POOL_SIZE,
      @max_num_threads = 4,
      @enable_compression = true,
      @read_only = false,
      @max_db_size = 1u64 << 43
    )
    end
  end

  abstract struct Node
    getter node_id : ID
    getter node_label : String

    def self.from_kuzu_value(value : ::LibKuzu::Value*) : self
      new value
    end

    def initialize(value : ::LibKuzu::Value*)
      {% begin %}
        {% for ivar in @type.instance_vars.reject { |ivar| ivar.name.stringify == "node_id" || ivar.name.stringify == "node_label" } %}
          %found{ivar.name} = false
          %value{ivar.name} = uninitialized {{ivar.type}}
        {% end %}

        node_id = Pointer(LibKuzu::Value).malloc
        label = Pointer(LibKuzu::Value).malloc
        size = Pointer(UInt64).malloc

        if LibKuzu.node_val_get_id_val(value, node_id).error?
          raise ArgumentError.new("Cannot get node id")
        end

        if LibKuzu.node_val_get_id_val(value, label).error?
          raise ArgumentError.new("Cannot get node label")
        end

        if LibKuzu.node_val_get_property_size(value, size).error?
          raise ArgumentError.new("Cannot get node property size")
        end

        @node_id = ID.from_kuzu_value(node_id)
        @node_label = String.from_kuzu_value(label)

        property_name = Pointer(Pointer(UInt8)).malloc
        property_value = Pointer(LibKuzu::Value).malloc
        size.value.times do |index|
          LibKuzu.node_val_get_property_name_at(value, index, property_name)
          case property_name.value
          {% for ivar in @type.instance_vars.reject { |ivar| ivar.name.stringify == "node_id" || ivar.name.stringify == "node_label" } %}
          when {{ivar.name.stringify}}
            LibKuzu.node_val_get_property_value_at(value, index, property_value)
            %found{ivar.name} = true
            %value{ivar.name} = {{ivar.type}}.from_kuzu_value(property_value)
          {% end %}
          end
        end

        {% for ivar in @type.instance_vars.reject { |ivar| ivar.name.stringify == "node_id" || ivar.name.stringify == "node_label" } %}
          if %found{ivar.name}
            if !%value{ivar.name}.nil?
              @{{ivar}} = %value{ivar.name}
            end
          {% unless ivar.default_value || ivar.type.union_types.includes?(Nil) %}
          else
            raise MissingProperty.new("Property `{{ivar.name}}` expected on node, but it was not provided")
          {% end %}
          end

        {% end %}
        {% debug %}
      {% end %}
    end

    record ID, table_id : UInt64, offset : UInt64 do
      def self.from_kuzu_value(value : Value*) : self
        case LibKuzu.value_get_internal_id(value, out internal_id)
        in .success?
          new(
            table_id: internal_id.table_id,
            offset: internal_id.offset,
          )
        in .error?
          raise ArgumentError.new("Could not deserialize Kuzu::Node::ID")
        end
      end
    end
  end
end

def Tuple.from_kuzu_tuple(kuzu_tuple : LibKuzu::FlatTuple*)
  {% begin %}
    {
      {% for type, index in T %}
        begin
          state = LibKuzu.flat_tuple_get_value(kuzu_tuple, {{index}}, out %raw{index})
          begin
            case state
            in .success?
              %value{index} = {{type.instance}}.from_kuzu_value(pointerof(%raw{index}))
              LibKuzu.value_destroy pointerof(%raw{index})
              %value{index}
            in .error?
              raise ArgumentError.new("Could not get tuple")
            end
          ensure
            LibC.free pointerof(%raw{index}).as(Void*)
          end
        end,
      {% end %}
    }
  {% end %}
end

def Union.from_kuzu_value(value : LibKuzu::Value*)
  {% if T.includes? Nil %}
    if Kuzu.null? value
      return nil
    end
  {% end %}

  {% begin %}
    {% for type in T %}
      if v = {{type}}.from_kuzu_value? value
        return v
      end
    {% end %}
    raise "Missing data type"
  {% end %}
end

def Int64.from_kuzu_value(value : LibKuzu::Value*) : Int64
  from_kuzu_value?(value) || raise ArgumentError.new("Expected Int64")
end

def Int64.from_kuzu_value?(value : LibKuzu::Value*) : Int64?
  if Kuzu.null? value
    return
  end

  case LibKuzu.value_get_int64(value, out int64)
  in .success?
    int64
  in .error?
    nil
  end
end

def String.from_kuzu_value(value : LibKuzu::Value*) : String
  from_kuzu_value?(value) || raise ArgumentError.new("Expected String")
end

def String.from_kuzu_value?(value : LibKuzu::Value*) : String?
  case LibKuzu.value_get_string(value, out string)
  in .success?
    from_c_string string
  in .error?
    nil
  end
end

# :nodoc:
def String.from_c_string(string : UInt8*) : String
  bytesize = 0
  until string[bytesize] == 0
    bytesize += 1
  end
  String.new(string, bytesize)
end

def Nil.from_kuzu_value?(value : LibKuzu::Value*) : String?
end

def UUID.from_kuzu_value(value : LibKuzu::Value*) : UUID
  from_kuzu_value?(value) || raise ArgumentError.new("Expected UUID")
end

def UUID.from_kuzu_value?(value : LibKuzu::Value*) : UUID?
  if LibKuzu.value_get_uuid(value, out string).success?
    new String.from_c_string string
  end
end

def Time.from_kuzu_value(value : LibKuzu::Value*)
  from_kuzu_value?(value) || raise ArgumentError.new("Expected Time")
end

def Time.from_kuzu_value?(value : LibKuzu::Value*)
  epoch = Time::UNIX_EPOCH

  if LibKuzu.value_get_timestamp(value, out ts).success?
    epoch + ts.microseconds.microseconds
  elsif LibKuzu.value_get_timestamp_ns(value, out ts_ns).success?
    epoch + ts_ns.value.nanoseconds
  elsif LibKuzu.value_get_timestamp_ms(value, out ts_ms).success?
    epoch + ts_ms.value.milliseconds
  elsif LibKuzu.value_get_timestamp_tz(value, out ts_tz).success?
    epoch + ts_tz.microseconds.microseconds
  elsif LibKuzu.value_get_timestamp_sec(value, out ts_sec).success?
    epoch + ts_sec.value.seconds
  end
end
