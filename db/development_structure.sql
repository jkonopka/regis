--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--



SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: geocode_log_entries; Type: TABLE; Schema: public; Owner: regis; Tablespace: 
--

CREATE TABLE geocode_log_entries (
    id integer NOT NULL,
    header text,
    query text,
    result text,
    provider character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.geocode_log_entries OWNER TO regis;

--
-- Name: geocode_log_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: regis
--

CREATE SEQUENCE geocode_log_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.geocode_log_entries_id_seq OWNER TO regis;

--
-- Name: geocode_log_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: regis
--

ALTER SEQUENCE geocode_log_entries_id_seq OWNED BY geocode_log_entries.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: regis; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO regis;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: regis
--

ALTER TABLE ONLY geocode_log_entries ALTER COLUMN id SET DEFAULT nextval('geocode_log_entries_id_seq'::regclass);


--
-- Name: geocode_log_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: regis; Tablespace: 
--

ALTER TABLE ONLY geocode_log_entries
    ADD CONSTRAINT geocode_log_entries_pkey PRIMARY KEY (id);


--
-- Name: index_geocode_log_entries_on_created_at; Type: INDEX; Schema: public; Owner: regis; Tablespace: 
--

CREATE INDEX index_geocode_log_entries_on_created_at ON geocode_log_entries USING btree (created_at);


--
-- Name: index_geocode_log_entries_on_provider; Type: INDEX; Schema: public; Owner: regis; Tablespace: 
--

CREATE INDEX index_geocode_log_entries_on_provider ON geocode_log_entries USING btree (provider);


--
-- Name: index_geocode_log_entries_on_updated_at; Type: INDEX; Schema: public; Owner: regis; Tablespace: 
--

CREATE INDEX index_geocode_log_entries_on_updated_at ON geocode_log_entries USING btree (updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: regis; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

