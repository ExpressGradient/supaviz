CREATE SCHEMA supaviz;

CREATE TABLE supaviz.pages (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    page_description TEXT
);

CREATE TYPE supaviz.chart_kind AS ENUM ('area', 'bar', 'line', 'pie', 'donut');

CREATE TABLE supaviz.charts (
    id SERIAL PRIMARY KEY,
    page_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    kind supaviz.chart_kind NOT NULL,

    custom_query BOOLEAN NOT NULL DEFAULT FALSE,

    data_key TEXT,
    categories TEXT[],

    table_from TEXT,
    query TEXT,

    records JSON,

    FOREIGN KEY (page_id) REFERENCES supaviz.pages(id)
);

CREATE OR REPLACE FUNCTION supaviz.populate_records()
RETURNS void AS $$
DECLARE
    chart_id INTEGER;
    chart RECORD;
    table_name TEXT;
    data_key TEXT;
    categories TEXT[];
    query TEXT;
    records JSON;
BEGIN
    FOR chart_id IN SELECT id FROM charts LOOP
        SELECT * FROM charts WHERE id = chart_id INTO chart;
        table_name = chart.table_from;
        data_key = chart.data_key;
        categories = chart.categories;
        query = chart.query;

        IF chart.custom_query THEN
            EXECUTE query INTO records;
        ELSE
            SELECT array_to_json(array_agg(row_to_json(t))) FROM (
                SELECT DISTINCT data_key, unnest(categories) as category
                FROM table_name
            ) t INTO records;
        END IF;

        UPDATE charts SET records = records WHERE id = chart_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;