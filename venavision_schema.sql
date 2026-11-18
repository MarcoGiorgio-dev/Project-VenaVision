--
-- PostgreSQL database dump
--

\restrict fTUfSs8yrN9ywTfoXaThpgp5QjBC7o4MWkOaaEbVhJEZVUxfIHl9gkOKKvieRa8

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    department_id integer NOT NULL,
    department_name character varying(100) NOT NULL,
    hospital_name character varying(150),
    location character varying(100)
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departments_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_department_id_seq OWNER TO postgres;

--
-- Name: departments_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departments_department_id_seq OWNED BY public.departments.department_id;


--
-- Name: device_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_logs (
    log_id integer NOT NULL,
    device_id integer,
    log_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    log_level character varying(20),
    message text,
    event_type character varying(50),
    resolved boolean DEFAULT false
);


ALTER TABLE public.device_logs OWNER TO postgres;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    device_id integer NOT NULL,
    device_name character varying(100) NOT NULL,
    device_type character varying(100),
    serial_number character varying(100),
    status character varying(30) DEFAULT 'inactive'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    battery_level integer,
    last_seen timestamp without time zone,
    firmware_version character varying(30),
    CONSTRAINT devices_battery_level_check CHECK (((battery_level >= 0) AND (battery_level <= 100)))
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: device_error_log; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.device_error_log AS
 SELECT l.log_id,
    d.device_name,
    l.log_time,
    l.log_level,
    l.event_type,
    l.message,
    l.resolved
   FROM (public.device_logs l
     JOIN public.devices d ON ((l.device_id = d.device_id)))
  WHERE ((l.log_level)::text = 'ERROR'::text);


ALTER VIEW public.device_error_log OWNER TO postgres;

--
-- Name: device_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.device_logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.device_logs_log_id_seq OWNER TO postgres;

--
-- Name: device_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.device_logs_log_id_seq OWNED BY public.device_logs.log_id;


--
-- Name: device_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.device_status AS
 SELECT device_id,
    device_name,
    device_type,
    serial_number,
    status,
    battery_level,
    last_seen,
    firmware_version
   FROM public.devices;


ALTER VIEW public.device_status OWNER TO postgres;

--
-- Name: devices_device_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.devices_device_id_seq OWNER TO postgres;

--
-- Name: devices_device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_device_id_seq OWNED BY public.devices.device_id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name text CONSTRAINT patienter_fornavn_not_null NOT NULL,
    last_name text CONSTRAINT patienter_efternavn_not_null NOT NULL,
    birth_date date CONSTRAINT patienter_foedselsdato_not_null NOT NULL,
    diagnose text CONSTRAINT patienter_diagnose_not_null NOT NULL,
    last_prick date CONSTRAINT patienter_sidste_visit_not_null NOT NULL,
    blood_type character varying(3),
    sex text,
    follow_up date CONSTRAINT patienter_opfoelgning_not_null NOT NULL,
    cpr_number character varying(10),
    notes text,
    source text DEFAULT 'Manuel'::text CONSTRAINT patienter_kilde_not_null NOT NULL,
    CONSTRAINT patients_sex_check CHECK ((sex = ANY (ARRAY['Female'::text, 'Male'::text]))),
    CONSTRAINT patients_source_check CHECK ((source = ANY (ARRAY['Manuel'::text, 'Script'::text])))
);


ALTER TABLE public.patients OWNER TO postgres;

--
-- Name: patients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.patients_id_seq OWNER TO postgres;

--
-- Name: patients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patients_id_seq OWNED BY public.patients.id;


--
-- Name: scans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scans (
    scan_id integer NOT NULL,
    visit_id integer NOT NULL,
    device_id integer,
    scan_time timestamp with time zone DEFAULT now(),
    vein_detected boolean,
    marking_completed boolean DEFAULT false,
    image_path text,
    notes text,
    scan_duration_ms integer,
    confidence_score numeric(5,2),
    error_message text
);


ALTER TABLE public.scans OWNER TO postgres;

--
-- Name: visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visits (
    id integer CONSTRAINT besoeg_id_not_null NOT NULL,
    patient_id integer CONSTRAINT besoeg_patient_id_not_null NOT NULL,
    staff_id integer,
    visit_time timestamp without time zone CONSTRAINT besoeg_tidspunkt_not_null NOT NULL,
    notes text,
    source text DEFAULT 'manuel'::text CONSTRAINT besoeg_kilde_not_null NOT NULL,
    CONSTRAINT visits_source_check CHECK ((source = ANY (ARRAY['manuel'::text, 'generator'::text])))
);


ALTER TABLE public.visits OWNER TO postgres;

--
-- Name: scan_history; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.scan_history AS
 SELECT s.scan_id,
    p.id AS patient_id,
    p.first_name,
    p.last_name,
    v.visit_time,
    d.device_name,
    s.scan_time,
    s.vein_detected,
    s.marking_completed,
    s.scan_duration_ms,
    s.confidence_score
   FROM (((public.scans s
     JOIN public.visits v ON ((s.visit_id = v.id)))
     JOIN public.patients p ON ((v.patient_id = p.id)))
     JOIN public.devices d ON ((s.device_id = d.device_id)));


ALTER VIEW public.scan_history OWNER TO postgres;

--
-- Name: scans_scan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.scans_scan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scans_scan_id_seq OWNER TO postgres;

--
-- Name: scans_scan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.scans_scan_id_seq OWNED BY public.scans.scan_id;


--
-- Name: staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff (
    id integer CONSTRAINT laeger_id_not_null NOT NULL,
    name text CONSTRAINT laeger_navn_not_null NOT NULL,
    specialty text,
    department_id integer,
    job_title character varying(100)
);


ALTER TABLE public.staff OWNER TO postgres;

--
-- Name: staff_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.staff_id_seq OWNER TO postgres;

--
-- Name: staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staff_id_seq OWNED BY public.staff.id;


--
-- Name: visits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visits_id_seq OWNER TO postgres;

--
-- Name: visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.visits_id_seq OWNED BY public.visits.id;


--
-- Name: departments department_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments ALTER COLUMN department_id SET DEFAULT nextval('public.departments_department_id_seq'::regclass);


--
-- Name: device_logs log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_logs ALTER COLUMN log_id SET DEFAULT nextval('public.device_logs_log_id_seq'::regclass);


--
-- Name: devices device_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices ALTER COLUMN device_id SET DEFAULT nextval('public.devices_device_id_seq'::regclass);


--
-- Name: patients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients ALTER COLUMN id SET DEFAULT nextval('public.patients_id_seq'::regclass);


--
-- Name: scans scan_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scans ALTER COLUMN scan_id SET DEFAULT nextval('public.scans_scan_id_seq'::regclass);


--
-- Name: staff id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff ALTER COLUMN id SET DEFAULT nextval('public.staff_id_seq'::regclass);


--
-- Name: visits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits ALTER COLUMN id SET DEFAULT nextval('public.visits_id_seq'::regclass);


--
-- Name: departments departments_department_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_department_name_key UNIQUE (department_name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: device_logs device_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_logs
    ADD CONSTRAINT device_logs_pkey PRIMARY KEY (log_id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (device_id);


--
-- Name: devices devices_serial_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_serial_number_key UNIQUE (serial_number);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: scans scans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scans
    ADD CONSTRAINT scans_pkey PRIMARY KEY (scan_id);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (id);


--
-- Name: idx_visits_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_visits_patient ON public.visits USING btree (patient_id);


--
-- Name: device_logs device_logs_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_logs
    ADD CONSTRAINT device_logs_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(device_id);


--
-- Name: scans scans_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scans
    ADD CONSTRAINT scans_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(device_id);


--
-- Name: scans scans_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scans
    ADD CONSTRAINT scans_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id);


--
-- Name: staff staff_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: visits visits_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: visits visits_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO webapp;
GRANT USAGE ON SCHEMA public TO generator;


--
-- Name: TABLE departments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.departments TO webapp;


--
-- Name: TABLE device_logs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE public.device_logs TO webapp;


--
-- Name: TABLE devices; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.devices TO webapp;


--
-- Name: TABLE device_error_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.device_error_log TO webapp;


--
-- Name: SEQUENCE device_logs_log_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.device_logs_log_id_seq TO webapp;


--
-- Name: TABLE device_status; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.device_status TO webapp;


--
-- Name: TABLE patients; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.patients TO webapp;
GRANT INSERT ON TABLE public.patients TO generator;


--
-- Name: COLUMN patients.id; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT(id) ON TABLE public.patients TO generator;


--
-- Name: SEQUENCE patients_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.patients_id_seq TO webapp;
GRANT USAGE ON SEQUENCE public.patients_id_seq TO generator;


--
-- Name: TABLE scans; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.scans TO webapp;


--
-- Name: TABLE visits; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.visits TO webapp;
GRANT INSERT ON TABLE public.visits TO generator;


--
-- Name: COLUMN visits.id; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT(id) ON TABLE public.visits TO generator;


--
-- Name: TABLE scan_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.scan_history TO webapp;


--
-- Name: SEQUENCE scans_scan_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.scans_scan_id_seq TO webapp;


--
-- Name: TABLE staff; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.staff TO webapp;


--
-- Name: SEQUENCE staff_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.staff_id_seq TO webapp;
GRANT USAGE ON SEQUENCE public.staff_id_seq TO generator;


--
-- Name: SEQUENCE visits_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.visits_id_seq TO webapp;
GRANT USAGE ON SEQUENCE public.visits_id_seq TO generator;


--
-- PostgreSQL database dump complete
--

\unrestrict fTUfSs8yrN9ywTfoXaThpgp5QjBC7o4MWkOaaEbVhJEZVUxfIHl9gkOKKvieRa8

