CREATE OR REPLACE VIEW events_parsed AS
SELECT
    JSONExtractString(_airbyte_data, 'event') AS event,
    JSONExtractInt(_airbyte_data, 'time') AS time,
    JSONExtractString(_airbyte_data, 'distinct_id') AS distinct_id,
    IF(JSONHas(_airbyte_data, 'email'), JSONExtractString(_airbyte_data, 'email'), NULL) AS user_email,
    IF(JSONHas(_airbyte_data, 'toolId'), JSONExtractString(_airbyte_data, 'toolId'), NULL) AS toolId
FROM default_raw__stream_events_file;