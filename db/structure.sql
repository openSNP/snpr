--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.11
-- Dumped by pg_dump version 9.5.12

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: find_bad_row(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_bad_row(tablename text) RETURNS tid
    LANGUAGE plpgsql
    AS $_$
DECLARE
result tid;
curs REFCURSOR;
row1 RECORD;
row2 RECORD;
tabName TEXT;
count BIGINT := 0;
BEGIN
SELECT reverse(split_part(reverse($1), '.', 1)) INTO tabName;
OPEN curs FOR EXECUTE 'SELECT ctid FROM ' || tableName;
count := 1;
FETCH curs INTO row1;
WHILE row1.ctid IS NOT NULL LOOP
result = row1.ctid;
count := count + 1;
FETCH curs INTO row1;
EXECUTE 'SELECT (each(hstore(' || tabName || '))).* FROM '
|| tableName || ' WHERE ctid = $1' INTO row2
USING row1.ctid;
IF count % 100000 = 0 THEN
RAISE NOTICE 'rows processed: %', count;
END IF;
END LOOP;
CLOSE curs;
RETURN row1.ctid;
EXCEPTION
WHEN OTHERS THEN
RAISE NOTICE 'LAST CTID: %', result;
RAISE NOTICE '%: %', SQLSTATE, SQLERRM;
RETURN result;
END
$_$;


--
-- Name: upsert_user_snps(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.upsert_user_snps(current_genotype_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          temp_table_name VARCHAR := CONCAT('user_snps_temp_', current_genotype_id::varchar);
          query VARCHAR := FORMAT('SELECT snp_name, local_genotype from %s', temp_table_name);
          temp_record RECORD;
        BEGIN
          FOR temp_record IN EXECUTE(query) LOOP
            BEGIN
              INSERT INTO user_snps (snp_name, genotype_id, local_genotype)
              VALUES (temp_record.snp_name,
                      current_genotype_id,
                      temp_record.local_genotype);
            EXCEPTION WHEN unique_violation THEN
              UPDATE user_snps
              SET local_genotype = temp_record.local_genotype
              WHERE snp_name = temp_record.snp_name
                    AND user_snps.genotype_id = current_genotype_id;
            END;
          END LOOP;
        END;
      $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.achievements (
    id integer NOT NULL,
    award text,
    short_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.achievements_id_seq OWNED BY public.achievements.id;


--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    namespace character varying(255)
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


--
-- Name: file_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_links (
    id integer NOT NULL,
    description text,
    url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: file_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_links_id_seq OWNED BY public.file_links.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id integer NOT NULL,
    slug character varying(255) NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(40),
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: genome_gov_papers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genome_gov_papers (
    id integer NOT NULL,
    first_author text,
    title text,
    pubmed_link text,
    pub_date text,
    journal text,
    trait text,
    pvalue double precision,
    pvalue_description text,
    confidence_interval text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: genome_gov_papers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genome_gov_papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genome_gov_papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genome_gov_papers_id_seq OWNED BY public.genome_gov_papers.id;


--
-- Name: genotypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genotypes (
    id integer NOT NULL,
    filetype character varying(255) DEFAULT '23andme'::character varying,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    md5sum character varying(255),
    genotype_file_name character varying(255),
    genotype_content_type character varying(255),
    genotype_file_size integer,
    genotype_updated_at timestamp without time zone
);


--
-- Name: genotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genotypes_id_seq OWNED BY public.genotypes.id;


--
-- Name: homepages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.homepages (
    id integer NOT NULL,
    url text,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer
);


--
-- Name: homepages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.homepages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: homepages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.homepages_id_seq OWNED BY public.homepages.id;


--
-- Name: mendeley_papers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mendeley_papers (
    id integer NOT NULL,
    first_author text,
    title text,
    mendeley_url text,
    doi text,
    pub_year integer,
    uuid character varying(255),
    open_access boolean,
    reader integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mendeley_papers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mendeley_papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mendeley_papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mendeley_papers_id_seq OWNED BY public.mendeley_papers.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    subject text,
    user_id integer,
    body text,
    sent boolean,
    user_has_seen boolean,
    from_id integer,
    to_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: open_humans_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.open_humans_profiles (
    id integer NOT NULL,
    open_humans_user_id character varying,
    project_member_id character varying,
    user_id integer,
    access_token character varying,
    refresh_token character varying,
    expires_in timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: open_humans_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.open_humans_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: open_humans_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.open_humans_profiles_id_seq OWNED BY public.open_humans_profiles.id;


--
-- Name: pgp_annotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pgp_annotations (
    id integer NOT NULL,
    gene text,
    qualified_impact text,
    inheritance text,
    summary text,
    trait text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    snp_id integer
);


--
-- Name: pgp_annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pgp_annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pgp_annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pgp_annotations_id_seq OWNED BY public.pgp_annotations.id;


--
-- Name: phenotype_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phenotype_comments (
    id integer NOT NULL,
    comment_text text,
    subject text,
    user_id integer,
    phenotype_id integer,
    reply_to_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: phenotype_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phenotype_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phenotype_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phenotype_comments_id_seq OWNED BY public.phenotype_comments.id;


--
-- Name: phenotype_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phenotype_sets (
    id integer NOT NULL,
    user_id integer,
    title character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: phenotype_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phenotype_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phenotype_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phenotype_sets_id_seq OWNED BY public.phenotype_sets.id;


--
-- Name: phenotype_sets_phenotypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phenotype_sets_phenotypes (
    phenotype_set_id integer,
    phenotype_id integer
);


--
-- Name: phenotypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phenotypes (
    id integer NOT NULL,
    characteristic character varying(255),
    known_phenotypes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text
);


--
-- Name: phenotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phenotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phenotypes_id_seq OWNED BY public.phenotypes.id;


--
-- Name: picture_phenotype_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.picture_phenotype_comments (
    id integer NOT NULL,
    comment_text text,
    subject text,
    user_id integer,
    picture_phenotype_id integer,
    reply_to_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: picture_phenotype_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.picture_phenotype_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: picture_phenotype_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.picture_phenotype_comments_id_seq OWNED BY public.picture_phenotype_comments.id;


--
-- Name: picture_phenotypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.picture_phenotypes (
    id integer NOT NULL,
    characteristic character varying(255),
    description text,
    number_of_users integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: picture_phenotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.picture_phenotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: picture_phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.picture_phenotypes_id_seq OWNED BY public.picture_phenotypes.id;


--
-- Name: plos_papers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plos_papers (
    id integer NOT NULL,
    first_author text,
    title text,
    doi text,
    pub_date timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reader integer
);


--
-- Name: plos_papers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plos_papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plos_papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plos_papers_id_seq OWNED BY public.plos_papers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: snp_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.snp_comments (
    id integer NOT NULL,
    comment_text text,
    subject text,
    user_id integer,
    snp_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reply_to_id integer
);


--
-- Name: snp_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.snp_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: snp_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.snp_comments_id_seq OWNED BY public.snp_comments.id;


--
-- Name: snp_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.snp_references (
    snp_id integer,
    paper_id integer,
    paper_type character varying(255)
);


--
-- Name: snp_references_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.snp_references_backup (
    snp_id integer NOT NULL,
    paper_id integer NOT NULL,
    paper_type character varying(255) NOT NULL
);


--
-- Name: snpedia_papers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.snpedia_papers (
    id integer NOT NULL,
    url character varying(255),
    summary text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    revision integer DEFAULT 0
);


--
-- Name: snpedia_papers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.snpedia_papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: snpedia_papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.snpedia_papers_id_seq OWNED BY public.snpedia_papers.id;


--
-- Name: snps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.snps (
    id integer NOT NULL,
    name character varying(255),
    "position" character varying(255),
    chromosome character varying(255),
    genotype_frequency character varying(255) DEFAULT '--- {}
'::character varying,
    allele_frequency character varying(255) DEFAULT '---
A: 0
T: 0
G: 0
C: 0
'::character varying,
    ranking integer DEFAULT 0,
    number_of_users integer DEFAULT 0,
    mendeley_updated timestamp without time zone DEFAULT '2011-08-24 03:44:32.459467'::timestamp without time zone,
    plos_updated timestamp without time zone DEFAULT '2011-08-24 03:44:32.459582'::timestamp without time zone,
    snpedia_updated timestamp without time zone DEFAULT '2011-08-24 03:44:32.459627'::timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_snps_count integer
)
WITH (autovacuum_enabled='false', toast.autovacuum_enabled='false');


--
-- Name: snps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.snps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: snps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.snps_id_seq OWNED BY public.snps.id;


--
-- Name: user_achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_achievements (
    id integer NOT NULL,
    user_id integer,
    achievement_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_achievements_id_seq OWNED BY public.user_achievements.id;


--
-- Name: user_phenotypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_phenotypes (
    id integer NOT NULL,
    user_id integer,
    phenotype_id integer,
    variation character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_phenotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_phenotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_phenotypes_id_seq OWNED BY public.user_phenotypes.id;


--
-- Name: user_picture_phenotypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_picture_phenotypes (
    id integer NOT NULL,
    user_id integer,
    picture_phenotype_id integer,
    variation character varying(255),
    phenotype_picture_file_name character varying(255),
    phenotype_picture_content_type character varying(255),
    phenotype_picture_file_size integer,
    phenotype_picture_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_picture_phenotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_picture_phenotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_picture_phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_picture_phenotypes_id_seq OWNED BY public.user_picture_phenotypes.id;


--
-- Name: user_snps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_snps (
    snp_name character varying(32) NOT NULL,
    genotype_id integer NOT NULL,
    local_genotype bpchar
)
WITH (autovacuum_enabled='false', toast.autovacuum_enabled='false');


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    password_salt character varying(255),
    crypted_password character varying(255),
    persistence_token character varying(255),
    perishable_token character varying(255),
    has_sequence boolean DEFAULT false,
    sequence_link character varying(255),
    description text,
    finished_snp_parsing boolean DEFAULT false,
    phenotype_creation_counter integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    avatar_file_name character varying(255),
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    help_one boolean DEFAULT false,
    help_two boolean DEFAULT false,
    help_three boolean DEFAULT false,
    sex character varying(255) DEFAULT 'rather not say'::character varying,
    yearofbirth character varying(255) DEFAULT 'rather not say'::character varying,
    message_on_message boolean DEFAULT true,
    message_on_snp_comment_reply boolean DEFAULT true,
    message_on_phenotype_comment_reply boolean DEFAULT true,
    message_on_newsletter boolean DEFAULT true,
    message_on_new_phenotype boolean DEFAULT false,
    admin boolean DEFAULT false NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements ALTER COLUMN id SET DEFAULT nextval('public.achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_links ALTER COLUMN id SET DEFAULT nextval('public.file_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genome_gov_papers ALTER COLUMN id SET DEFAULT nextval('public.genome_gov_papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genotypes ALTER COLUMN id SET DEFAULT nextval('public.genotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homepages ALTER COLUMN id SET DEFAULT nextval('public.homepages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mendeley_papers ALTER COLUMN id SET DEFAULT nextval('public.mendeley_papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.open_humans_profiles ALTER COLUMN id SET DEFAULT nextval('public.open_humans_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgp_annotations ALTER COLUMN id SET DEFAULT nextval('public.pgp_annotations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phenotype_comments ALTER COLUMN id SET DEFAULT nextval('public.phenotype_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phenotype_sets ALTER COLUMN id SET DEFAULT nextval('public.phenotype_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phenotypes ALTER COLUMN id SET DEFAULT nextval('public.phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picture_phenotype_comments ALTER COLUMN id SET DEFAULT nextval('public.picture_phenotype_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picture_phenotypes ALTER COLUMN id SET DEFAULT nextval('public.picture_phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plos_papers ALTER COLUMN id SET DEFAULT nextval('public.plos_papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snp_comments ALTER COLUMN id SET DEFAULT nextval('public.snp_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snpedia_papers ALTER COLUMN id SET DEFAULT nextval('public.snpedia_papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snps ALTER COLUMN id SET DEFAULT nextval('public.snps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_achievements ALTER COLUMN id SET DEFAULT nextval('public.user_achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_phenotypes ALTER COLUMN id SET DEFAULT nextval('public.user_phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_picture_phenotypes ALTER COLUMN id SET DEFAULT nextval('public.user_picture_phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: file_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_links
    ADD CONSTRAINT file_links_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: genome_gov_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genome_gov_papers
    ADD CONSTRAINT genome_gov_papers_pkey PRIMARY KEY (id);


--
-- Name: genotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genotypes
    ADD CONSTRAINT genotypes_pkey PRIMARY KEY (id);


--
-- Name: homepages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homepages
    ADD CONSTRAINT homepages_pkey PRIMARY KEY (id);


--
-- Name: mendeley_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mendeley_papers
    ADD CONSTRAINT mendeley_papers_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: open_humans_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.open_humans_profiles
    ADD CONSTRAINT open_humans_profiles_pkey PRIMARY KEY (id);


--
-- Name: pgp_annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgp_annotations
    ADD CONSTRAINT pgp_annotations_pkey PRIMARY KEY (id);


--
-- Name: phenotype_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phenotype_comments
    ADD CONSTRAINT phenotype_comments_pkey PRIMARY KEY (id);


--
-- Name: phenotype_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phenotype_sets
    ADD CONSTRAINT phenotype_sets_pkey PRIMARY KEY (id);


--
-- Name: phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phenotypes
    ADD CONSTRAINT phenotypes_pkey PRIMARY KEY (id);


--
-- Name: picture_phenotype_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picture_phenotype_comments
    ADD CONSTRAINT picture_phenotype_comments_pkey PRIMARY KEY (id);


--
-- Name: picture_phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picture_phenotypes
    ADD CONSTRAINT picture_phenotypes_pkey PRIMARY KEY (id);


--
-- Name: plos_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plos_papers
    ADD CONSTRAINT plos_papers_pkey PRIMARY KEY (id);


--
-- Name: snp_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snp_comments
    ADD CONSTRAINT snp_comments_pkey PRIMARY KEY (id);


--
-- Name: snpedia_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snpedia_papers
    ADD CONSTRAINT snpedia_papers_pkey PRIMARY KEY (id);


--
-- Name: snps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snps
    ADD CONSTRAINT snps_pkey PRIMARY KEY (id);


--
-- Name: user_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_pkey PRIMARY KEY (id);


--
-- Name: user_phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_phenotypes
    ADD CONSTRAINT user_phenotypes_pkey PRIMARY KEY (id);


--
-- Name: user_picture_phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_picture_phenotypes
    ADD CONSTRAINT user_picture_phenotypes_pkey PRIMARY KEY (id);


--
-- Name: user_snps_new_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_snps
    ADD CONSTRAINT user_snps_new_pkey PRIMARY KEY (genotype_id, snp_name);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_user_snps_snp_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_snps_snp_name ON public.user_snps USING btree (snp_name);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON public.admin_users USING btree (reset_password_token);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON public.friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_snp_references_backup_on_paper_id_and_paper_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_snp_references_backup_on_paper_id_and_paper_type ON public.snp_references_backup USING btree (paper_id, paper_type);


--
-- Name: index_snp_references_backup_on_snp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_snp_references_backup_on_snp_id ON public.snp_references_backup USING btree (snp_id);


--
-- Name: index_snp_references_on_paper_id_and_paper_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_snp_references_on_paper_id_and_paper_type ON public.snp_references USING btree (paper_id, paper_type);


--
-- Name: index_snp_references_on_snp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_snp_references_on_snp_id ON public.snp_references USING btree (snp_id);


--
-- Name: index_snps_chromosome_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_snps_chromosome_position ON public.snps USING btree (chromosome, "position");


--
-- Name: index_snps_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_snps_on_id ON public.snps USING btree (id);


--
-- Name: index_snps_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_snps_on_name ON public.snps USING btree (name);


--
-- Name: index_snps_ranking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_snps_ranking ON public.snps USING btree (ranking);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_persistence_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_persistence_token ON public.users USING btree (persistence_token);


--
-- Name: snps_position_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snps_position_idx ON public.snps USING btree ("position");


--
-- Name: user_phenotypes_phenotype_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_phenotypes_phenotype_id_idx ON public.user_phenotypes USING btree (phenotype_id);


--
-- Name: user_phenotypes_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_phenotypes_user_id_idx ON public.user_phenotypes USING btree (user_id);


--
-- Name: genotypes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genotypes
    ADD CONSTRAINT genotypes_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: homepages_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homepages
    ADD CONSTRAINT homepages_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: phenotype_comments_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phenotype_comments
    ADD CONSTRAINT phenotype_comments_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: picture_phenotype_comments_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picture_phenotype_comments
    ADD CONSTRAINT picture_phenotype_comments_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_achievements_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_phenotypes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_phenotypes
    ADD CONSTRAINT user_phenotypes_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_picture_phenotypes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_picture_phenotypes
    ADD CONSTRAINT user_picture_phenotypes_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_snps_genotype_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_snps
    ADD CONSTRAINT user_snps_genotype_id_fk FOREIGN KEY (genotype_id) REFERENCES public.genotypes(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20110608000645');

INSERT INTO schema_migrations (version) VALUES ('20110615045458');

INSERT INTO schema_migrations (version) VALUES ('20110615173154');

INSERT INTO schema_migrations (version) VALUES ('20110616192820');

INSERT INTO schema_migrations (version) VALUES ('20110617144145');

INSERT INTO schema_migrations (version) VALUES ('20110819233120');

INSERT INTO schema_migrations (version) VALUES ('20110820195410');

INSERT INTO schema_migrations (version) VALUES ('20110821112909');

INSERT INTO schema_migrations (version) VALUES ('20110822071221');

INSERT INTO schema_migrations (version) VALUES ('20110822110806');

INSERT INTO schema_migrations (version) VALUES ('20110823032055');

INSERT INTO schema_migrations (version) VALUES ('20110824164934');

INSERT INTO schema_migrations (version) VALUES ('20110830134100');

INSERT INTO schema_migrations (version) VALUES ('20110912190409');

INSERT INTO schema_migrations (version) VALUES ('20110914100443');

INSERT INTO schema_migrations (version) VALUES ('20110914100516');

INSERT INTO schema_migrations (version) VALUES ('20110914151105');

INSERT INTO schema_migrations (version) VALUES ('20110917193600');

INSERT INTO schema_migrations (version) VALUES ('20110926092220');

INSERT INTO schema_migrations (version) VALUES ('20110926172905');

INSERT INTO schema_migrations (version) VALUES ('20111005210020');

INSERT INTO schema_migrations (version) VALUES ('20111006133700');

INSERT INTO schema_migrations (version) VALUES ('20111006163700');

INSERT INTO schema_migrations (version) VALUES ('20111007141500');

INSERT INTO schema_migrations (version) VALUES ('20111007145000');

INSERT INTO schema_migrations (version) VALUES ('20111018040633');

INSERT INTO schema_migrations (version) VALUES ('20111028190606');

INSERT INTO schema_migrations (version) VALUES ('20111028212506');

INSERT INTO schema_migrations (version) VALUES ('20111029180506');

INSERT INTO schema_migrations (version) VALUES ('20111102033039');

INSERT INTO schema_migrations (version) VALUES ('20111212063354');

INSERT INTO schema_migrations (version) VALUES ('20120208020405');

INSERT INTO schema_migrations (version) VALUES ('20120324143135');

INSERT INTO schema_migrations (version) VALUES ('20120509234035');

INSERT INTO schema_migrations (version) VALUES ('20120902113435');

INSERT INTO schema_migrations (version) VALUES ('20120902174500');

INSERT INTO schema_migrations (version) VALUES ('20120902175000');

INSERT INTO schema_migrations (version) VALUES ('20120902175500');

INSERT INTO schema_migrations (version) VALUES ('20120916211800');

INSERT INTO schema_migrations (version) VALUES ('20120916212700');

INSERT INTO schema_migrations (version) VALUES ('20121006230458');

INSERT INTO schema_migrations (version) VALUES ('20121020153113');

INSERT INTO schema_migrations (version) VALUES ('20121023032404');

INSERT INTO schema_migrations (version) VALUES ('20121123234958');

INSERT INTO schema_migrations (version) VALUES ('20121123235228');

INSERT INTO schema_migrations (version) VALUES ('20121124201111');

INSERT INTO schema_migrations (version) VALUES ('20121210131554');

INSERT INTO schema_migrations (version) VALUES ('20121213120010');

INSERT INTO schema_migrations (version) VALUES ('20130124085042');

INSERT INTO schema_migrations (version) VALUES ('20130608135719');

INSERT INTO schema_migrations (version) VALUES ('20130904010945');

INSERT INTO schema_migrations (version) VALUES ('20130904010949');

INSERT INTO schema_migrations (version) VALUES ('20130904010950');

INSERT INTO schema_migrations (version) VALUES ('20131117101353');

INSERT INTO schema_migrations (version) VALUES ('20131130123430');

INSERT INTO schema_migrations (version) VALUES ('20140120005457');

INSERT INTO schema_migrations (version) VALUES ('20140221060607');

INSERT INTO schema_migrations (version) VALUES ('20140509001806');

INSERT INTO schema_migrations (version) VALUES ('20140820071334');

INSERT INTO schema_migrations (version) VALUES ('20150524081137');

INSERT INTO schema_migrations (version) VALUES ('20150916070052');

INSERT INTO schema_migrations (version) VALUES ('20151019160643');

INSERT INTO schema_migrations (version) VALUES ('20151028130755');

INSERT INTO schema_migrations (version) VALUES ('20151119070640');

INSERT INTO schema_migrations (version) VALUES ('20160207043305');

INSERT INTO schema_migrations (version) VALUES ('20160626121340');

INSERT INTO schema_migrations (version) VALUES ('20160806143618');

INSERT INTO schema_migrations (version) VALUES ('20161226175703');

INSERT INTO schema_migrations (version) VALUES ('20171113104813');

INSERT INTO schema_migrations (version) VALUES ('20180118100003');

