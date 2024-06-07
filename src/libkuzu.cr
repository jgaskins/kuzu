@[Link("kuzu")]
lib LibKuzu
  alias String = UInt8*

  fun default_system_config = kuzu_default_system_config : SystemConfig

  fun database_init = kuzu_database_init(database_path : String, system_config : SystemConfig, out_database : Database*) : State
  fun database_destroy = kuzu_database_destroy(db : Database*)

  fun connection_init = kuzu_connection_init(database : Database*, out_connection : Connection*) : State
  fun connection_set_max_num_thread_for_exec = kuzu_connection_set_max_num_thread_for_exec(connection : Connection*, num_threads : UInt64) : State
  fun connection_query = kuzu_connection_query(connection : Connection*, query : String, out_query_result : QueryResult*) : State
  fun connection_prepare = kuzu_connection_prepare(connection : Connection*, query : String, out_prepared_statement : PreparedStatement*) : State
  fun connection_execute = kuzu_connection_execute(connection : Connection*, prepared_statement : PreparedStatement*, out_query_result : QueryResult*) : State
  fun connection_interrupt = kuzu_connection_interrupt(connection : Connection*)
  fun connection_set_query_timeout = kuzu_connection_set_query_timeout(connection : Connection*, timeout_in_ms : UInt64) : State
  fun connection_destroy = kuzu_connection_destroy(conn : Connection*)

  fun prepared_statement_is_success = kuzu_prepared_statement_is_success(prepared_statement : PreparedStatement*) : Bool
  fun prepared_statement_get_error_message = kuzu_prepared_statement_get_error_message(prepared_statement : PreparedStatement*) : String
  fun prepared_statement_bind_bool = kuzu_prepared_statement_bind_bool(prepared_statement : PreparedStatement*, param_name : String, value : Bool) : State
  fun prepared_statement_bind_int64 = kuzu_prepared_statement_bind_int64(prepared_statement : PreparedStatement*, param_name : String, value : Int64) : State
  fun prepared_statement_bind_int32 = kuzu_prepared_statement_bind_int32(prepared_statement : PreparedStatement*, param_name : String, value : Int32) : State
  fun prepared_statement_bind_int16 = kuzu_prepared_statement_bind_int16(prepared_statement : PreparedStatement*, param_name : String, value : Int16) : State
  fun prepared_statement_bind_int8 = kuzu_prepared_statement_bind_int8(prepared_statement : PreparedStatement*, param_name : String, value : Int8) : State
  fun prepared_statement_bind_uint64 = kuzu_prepared_statement_bind_uint64(prepared_statement : PreparedStatement*, param_name : String, value : UInt64) : State
  fun prepared_statement_bind_uint32 = kuzu_prepared_statement_bind_uint32(prepared_statement : PreparedStatement*, param_name : String, value : UInt32) : State
  fun prepared_statement_bind_uint16 = kuzu_prepared_statement_bind_uint16(prepared_statement : PreparedStatement*, param_name : String, value : UInt16) : State
  fun prepared_statement_bind_uint8 = kuzu_prepared_statement_bind_uint8(prepared_statement : PreparedStatement*, param_name : String, value : UInt8) : State
  fun prepared_statement_bind_double = kuzu_prepared_statement_bind_double(prepared_statement : PreparedStatement*, param_name : String, value : Float64) : State
  fun prepared_statement_bind_float = kuzu_prepared_statement_bind_float(prepared_statement : PreparedStatement*, param_name : String, value : Float32) : State
  fun prepared_statement_bind_date = kuzu_prepared_statement_bind_date(prepared_statement : PreparedStatement*, param_name : String, value : Date) : State
  fun prepared_statement_bind_timestamp_ns = kuzu_prepared_statement_bind_timestamp_ns(prepared_statement : PreparedStatement*, param_name : String, value : TimestampNS) : State
  fun prepared_statement_bind_timestamp_ms = kuzu_prepared_statement_bind_timestamp_ms(prepared_statement : PreparedStatement*, param_name : String, value : TimestampMS) : State
  fun prepared_statement_bind_timestamp_tz = kuzu_prepared_statement_bind_timestamp_tz(prepared_statement : PreparedStatement*, param_name : String, value : TimestampTZ) : State
  fun prepared_statement_bind_timestamp_sec = kuzu_prepared_statement_bind_timestamp_sec(prepared_statement : PreparedStatement*, param_name : String, value : TimestampSec) : State
  fun prepared_statement_bind_timestamp = kuzu_prepared_statement_bind_timestamp(prepared_statement : PreparedStatement*, param_name : String, value : Timestamp) : State
  fun prepared_statement_bind_interval = kuzu_prepared_statement_bind_interval(prepared_statement : PreparedStatement*, param_name : String, value : Interval) : State
  fun prepared_statement_bind_string = kuzu_prepared_statement_bind_string(prepared_statement : PreparedStatement*, param_name : String, value : String) : State
  fun prepared_statement_destroy = kuzu_prepared_statement_destroy(prepared_statement : PreparedStatement*)

  fun query_result_is_success = kuzu_query_result_is_success(query_result : QueryResult*) : Bool
  fun query_result_has_next = kuzu_query_result_has_next(query_result : QueryResult*) : Bool
  fun query_result_get_next = kuzu_query_result_get_next(query_result : QueryResult*, tuple : FlatTuple*) : State
  fun query_result_get_error_message = kuzu_query_result_get_error_message(query_result : QueryResult*) : String
  fun query_result_get_num_columns = kuzu_query_result_get_num_columns(query_result : QueryResult*) : UInt64
  fun query_result_get_column_name = kuzu_query_result_get_column_name(query_result : QueryResult*, index : UInt64, out_column_name : Char**) : State
  fun query_result_destroy = kuzu_query_result_destroy(result : QueryResult*)

  fun flat_tuple_destroy = kuzu_flat_tuple_destroy(flat_tuple : FlatTuple*)
  fun flat_tuple_get_value = kuzu_flat_tuple_get_value(flat_tuple : FlatTuple*, index : UInt64, out_value : Value*) : State

  fun value_get_data_type = kuzu_value_get_data_type(value : Value*, logical_type : LogicalType*)
  fun value_get_int64 = kuzu_value_get_int64(value : Value*, out_result : Int64*) : State
  fun value_get_string = kuzu_value_get_string(value : Value*, out_result : String*) : State
  fun value_get_uuid = kuzu_value_get_uuid(value : Value*, out_result : String*) : State
  fun value_get_timestamp = kuzu_value_get_timestamp(value : Value*, out_result : Timestamp*) : State
  fun value_get_timestamp_ns = kuzu_value_get_timestamp_ns(value : Value*, out_result : TimestampNS*) : State
  fun value_get_timestamp_ms = kuzu_value_get_timestamp_ms(value : Value*, out_result : TimestampMS*) : State
  fun value_get_timestamp_sec = kuzu_value_get_timestamp_sec(value : Value*, out_result : TimestampSec*) : State
  fun value_get_timestamp_tz = kuzu_value_get_timestamp_tz(value : Value*, out_result : TimestampTZ*) : State
  fun value_get_internal_id = kuzu_value_get_internal_id(value : Value*, out_result : InternalID*) : State
  fun value_is_null = kuzu_value_is_null(value : Value*) : Bool
  fun value_destroy = kuzu_value_destroy(value : Value*)

  fun node_val_get_id_val = kuzu_node_val_get_id_val(node_val : Value*, out_value : Value*) : State
  fun node_val_get_property_size = kuzu_node_val_get_property_size(node_val : Value*, out_value : UInt64*) : State
  fun node_val_get_property_name_at = kuzu_node_val_get_property_name_at(node_val : Value*, index : UInt64, out_result : String*) : State
  fun node_val_get_property_value_at = kuzu_node_val_get_property_value_at(node_val : Value*, index : UInt64, out_value : Value*) : State

  struct QueryResult
    query_result : Void*
    is_owned_by_cpp : Bool
  end

  struct PreparedStatement
    prepared_statement : Void*
    bound_values : Void*
  end

  struct Connection
    connection : Void*
  end

  struct Database
    database : Void*
  end

  struct SystemConfig
    buffer_pool_size : UInt64
    max_num_threads : UInt64
    enable_compression : Bool
    read_only : Bool
    max_db_size : UInt64
  end

  struct LogicalType
    data_type : DataType*
  end

  enum State
    Success = 0
    Error   = 1
  end

  enum DataType
    ANY           =  0
    NODE          = 10
    REL           = 11
    RECURSIVE_REL = 12

    # SERIAL is a special data type that is used to represent a sequence of
    # INT64 values that are incremented by 1 starting from 0.
    SERIAL = 13

    # fixed size types
    BOOL          = 22
    INT64         = 23
    INT32         = 24
    INT16         = 25
    INT8          = 26
    UINT64        = 27
    UINT32        = 28
    UINT16        = 29
    UINT8         = 30
    INT128        = 31
    DOUBLE        = 32
    FLOAT         = 33
    DATE          = 34
    TIMESTAMP     = 35
    TIMESTAMP_SEC = 36
    TIMESTAMP_MS  = 37
    TIMESTAMP_NS  = 38
    TIMESTAMP_TZ  = 39
    INTERVAL      = 40
    DECIMAL       = 41
    INTERNAL_ID   = 42

    # variable size types

    STRING      = 50
    BLOB        = 51
    LIST        = 52
    ARRAY       = 53
    STRUCT      = 54
    MAP         = 55
    UNION       = 56
    RDF_VARIANT = 57
    POINTER     = 58
    UUID        = 59
  end

  struct FlatTuple
    tuple : Void*
    is_owned_by_cpp : Bool
  end

  struct Date
    days : Int32
  end

  struct TimestampNS
    value : Int64
  end

  struct TimestampMS
    value : Int64
  end

  struct TimestampSec
    value : Int64
  end

  struct TimestampTZ
    microseconds : Int64
  end

  struct Timestamp
    microseconds : Int64
  end

  struct Interval
    months : Int32
    days : Int32
    microseconds : Int64
  end

  struct Value
    value : Void*
    is_owned_by_cpp : Bool
  end

  struct InternalID
    table_id : UInt64
    offset : UInt64
  end

  struct QuerySummary
    summary : Void*
  end

  # TODO: Can we use a plain Crystal Int128 here?
  struct Int128
    low : UInt64
    high : Int64
  end
end
