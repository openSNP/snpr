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


SET search_path = public, pg_catalog;

--
-- Name: find_bad_row(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION find_bad_row(tablename text) RETURNS tid
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

CREATE FUNCTION upsert_user_snps(current_genotype_id integer) RETURNS void
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
-- Name: achievements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE achievements (
    id integer NOT NULL,
    award text,
    short_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE achievements_id_seq OWNED BY achievements.id;


--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE active_admin_comments (
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

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_users (
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

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: file_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE file_links (
    id integer NOT NULL,
    description text,
    url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: file_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_links_id_seq OWNED BY file_links.id;


--
-- Name: fitbit_activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fitbit_activities (
    id integer NOT NULL,
    fitbit_profile_id integer,
    steps integer,
    floors integer,
    date_logged date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: fitbit_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fitbit_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fitbit_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fitbit_activities_id_seq OWNED BY fitbit_activities.id;


--
-- Name: fitbit_bodies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fitbit_bodies (
    id integer NOT NULL,
    fitbit_profile_id integer,
    date_logged date,
    weight double precision,
    bmi double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: fitbit_bodies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fitbit_bodies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fitbit_bodies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fitbit_bodies_id_seq OWNED BY fitbit_bodies.id;


--
-- Name: fitbit_profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fitbit_profiles (
    id integer NOT NULL,
    fitbit_user_id character varying(255),
    user_id integer,
    request_token character varying(255),
    request_secret character varying(255),
    access_token character varying(255),
    access_secret character varying(255),
    verifier character varying(255),
    body boolean DEFAULT true,
    activities boolean DEFAULT true,
    sleep boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: fitbit_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fitbit_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fitbit_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fitbit_profiles_id_seq OWNED BY fitbit_profiles.id;


--
-- Name: fitbit_sleeps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fitbit_sleeps (
    id integer NOT NULL,
    fitbit_profile_id integer,
    minutes_asleep integer,
    minutes_awake integer,
    number_awakenings integer,
    minutes_to_sleep integer,
    date_logged date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: fitbit_sleeps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fitbit_sleeps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fitbit_sleeps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fitbit_sleeps_id_seq OWNED BY fitbit_sleeps.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE friendly_id_slugs (
    id integer NOT NULL,
    slug character varying(255) NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(40),
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendly_id_slugs_id_seq OWNED BY friendly_id_slugs.id;


--
-- Name: genome_gov_papers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genome_gov_papers (
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

CREATE SEQUENCE genome_gov_papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genome_gov_papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genome_gov_papers_id_seq OWNED BY genome_gov_papers.id;


--
-- Name: genotypes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genotypes (
    id integer NOT NULL,
    filetype character varying(255) DEFAULT '23andme'::character varying,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    md5sum character varying(255),
    genotype_file_name character varying(255),
    genotype_content_type character varying(255),
    genotype_file_size integer,
    genotype_updated_at timestamp without time zone,
    snps hstore DEFAULT ''::hstore NOT NULL
);


--
-- Name: genotypes_by_snp; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genotypes_by_snp (
    snp_name character varying NOT NULL,
    genotypes hstore DEFAULT ''::hstore NOT NULL
);


--
-- Name: genotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE genotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genotypes_id_seq OWNED BY genotypes.id;


--
-- Name: homepages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE homepages (
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

CREATE SEQUENCE homepages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: homepages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE homepages_id_seq OWNED BY homepages.id;


--
-- Name: mendeley_papers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mendeley_papers (
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

CREATE SEQUENCE mendeley_papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mendeley_papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mendeley_papers_id_seq OWNED BY mendeley_papers.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
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

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: pgp_annotations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pgp_annotations (
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

CREATE SEQUENCE pgp_annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pgp_annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pgp_annotations_id_seq OWNED BY pgp_annotations.id;


--
-- Name: phenotype_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phenotype_comments (
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

CREATE SEQUENCE phenotype_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phenotype_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phenotype_comments_id_seq OWNED BY phenotype_comments.id;


--
-- Name: phenotype_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phenotype_sets (
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

CREATE SEQUENCE phenotype_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phenotype_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phenotype_sets_id_seq OWNED BY phenotype_sets.id;


--
-- Name: phenotype_sets_phenotypes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phenotype_sets_phenotypes (
    phenotype_set_id integer,
    phenotype_id integer
);


--
-- Name: phenotypes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phenotypes (
    id integer NOT NULL,
    characteristic character varying(255),
    known_phenotypes text,
    number_of_users integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text
);


--
-- Name: phenotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE phenotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phenotypes_id_seq OWNED BY phenotypes.id;


--
-- Name: picture_phenotype_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE picture_phenotype_comments (
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

CREATE SEQUENCE picture_phenotype_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: picture_phenotype_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE picture_phenotype_comments_id_seq OWNED BY picture_phenotype_comments.id;


--
-- Name: picture_phenotypes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE picture_phenotypes (
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

CREATE SEQUENCE picture_phenotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: picture_phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE picture_phenotypes_id_seq OWNED BY picture_phenotypes.id;


--
-- Name: plos_papers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE plos_papers (
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

CREATE SEQUENCE plos_papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plos_papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE plos_papers_id_seq OWNED BY plos_papers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: snp_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE snp_comments (
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

CREATE SEQUENCE snp_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: snp_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE snp_comments_id_seq OWNED BY snp_comments.id;


--
-- Name: snp_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE snp_references (
    snp_id integer,
    paper_id integer,
    paper_type character varying(255)
);


--
-- Name: snp_references_backup; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE snp_references_backup (
    snp_id integer NOT NULL,
    paper_id integer NOT NULL,
    paper_type character varying(255) NOT NULL
);


--
-- Name: snpedia_papers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE snpedia_papers (
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

CREATE SEQUENCE snpedia_papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: snpedia_papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE snpedia_papers_id_seq OWNED BY snpedia_papers.id;


--
-- Name: snps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE snps (
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
    user_snps_count integer,
    genotypes hstore DEFAULT ''::hstore NOT NULL
)
WITH (autovacuum_enabled=false, toast.autovacuum_enabled=false);


--
-- Name: snps_by_genotype; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE snps_by_genotype (
    genotype_id integer NOT NULL,
    snps hstore DEFAULT ''::hstore NOT NULL
);


--
-- Name: snps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE snps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: snps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE snps_id_seq OWNED BY snps.id;


--
-- Name: user_achievements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_achievements (
    id integer NOT NULL,
    user_id integer,
    achievement_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_achievements_id_seq OWNED BY user_achievements.id;


--
-- Name: user_phenotypes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_phenotypes (
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

CREATE SEQUENCE user_phenotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_phenotypes_id_seq OWNED BY user_phenotypes.id;


--
-- Name: user_picture_phenotypes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_picture_phenotypes (
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

CREATE SEQUENCE user_picture_phenotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_picture_phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_picture_phenotypes_id_seq OWNED BY user_picture_phenotypes.id;


--
-- Name: user_snps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_snps (
    snp_name character varying(32) NOT NULL,
    genotype_id integer NOT NULL,
    local_genotype bpchar
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
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
    phenotype_additional_counter integer DEFAULT 0,
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
    message_on_new_phenotype boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY achievements ALTER COLUMN id SET DEFAULT nextval('achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_links ALTER COLUMN id SET DEFAULT nextval('file_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fitbit_activities ALTER COLUMN id SET DEFAULT nextval('fitbit_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fitbit_bodies ALTER COLUMN id SET DEFAULT nextval('fitbit_bodies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fitbit_profiles ALTER COLUMN id SET DEFAULT nextval('fitbit_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fitbit_sleeps ALTER COLUMN id SET DEFAULT nextval('fitbit_sleeps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('friendly_id_slugs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genome_gov_papers ALTER COLUMN id SET DEFAULT nextval('genome_gov_papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genotypes ALTER COLUMN id SET DEFAULT nextval('genotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY homepages ALTER COLUMN id SET DEFAULT nextval('homepages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mendeley_papers ALTER COLUMN id SET DEFAULT nextval('mendeley_papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pgp_annotations ALTER COLUMN id SET DEFAULT nextval('pgp_annotations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY phenotype_comments ALTER COLUMN id SET DEFAULT nextval('phenotype_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY phenotype_sets ALTER COLUMN id SET DEFAULT nextval('phenotype_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY phenotypes ALTER COLUMN id SET DEFAULT nextval('phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY picture_phenotype_comments ALTER COLUMN id SET DEFAULT nextval('picture_phenotype_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY picture_phenotypes ALTER COLUMN id SET DEFAULT nextval('picture_phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY plos_papers ALTER COLUMN id SET DEFAULT nextval('plos_papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY snp_comments ALTER COLUMN id SET DEFAULT nextval('snp_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY snpedia_papers ALTER COLUMN id SET DEFAULT nextval('snpedia_papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY snps ALTER COLUMN id SET DEFAULT nextval('snps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_achievements ALTER COLUMN id SET DEFAULT nextval('user_achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_phenotypes ALTER COLUMN id SET DEFAULT nextval('user_phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_picture_phenotypes ALTER COLUMN id SET DEFAULT nextval('user_picture_phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: file_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY file_links
    ADD CONSTRAINT file_links_pkey PRIMARY KEY (id);


--
-- Name: fitbit_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fitbit_activities
    ADD CONSTRAINT fitbit_activities_pkey PRIMARY KEY (id);


--
-- Name: fitbit_bodies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fitbit_bodies
    ADD CONSTRAINT fitbit_bodies_pkey PRIMARY KEY (id);


--
-- Name: fitbit_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fitbit_profiles
    ADD CONSTRAINT fitbit_profiles_pkey PRIMARY KEY (id);


--
-- Name: fitbit_sleeps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fitbit_sleeps
    ADD CONSTRAINT fitbit_sleeps_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: genome_gov_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genome_gov_papers
    ADD CONSTRAINT genome_gov_papers_pkey PRIMARY KEY (id);


--
-- Name: genotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genotypes
    ADD CONSTRAINT genotypes_pkey PRIMARY KEY (id);


--
-- Name: homepages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY homepages
    ADD CONSTRAINT homepages_pkey PRIMARY KEY (id);


--
-- Name: mendeley_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mendeley_papers
    ADD CONSTRAINT mendeley_papers_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: pgp_annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pgp_annotations
    ADD CONSTRAINT pgp_annotations_pkey PRIMARY KEY (id);


--
-- Name: phenotype_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY phenotype_comments
    ADD CONSTRAINT phenotype_comments_pkey PRIMARY KEY (id);


--
-- Name: phenotype_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY phenotype_sets
    ADD CONSTRAINT phenotype_sets_pkey PRIMARY KEY (id);


--
-- Name: phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY phenotypes
    ADD CONSTRAINT phenotypes_pkey PRIMARY KEY (id);


--
-- Name: picture_phenotype_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY picture_phenotype_comments
    ADD CONSTRAINT picture_phenotype_comments_pkey PRIMARY KEY (id);


--
-- Name: picture_phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY picture_phenotypes
    ADD CONSTRAINT picture_phenotypes_pkey PRIMARY KEY (id);


--
-- Name: plos_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plos_papers
    ADD CONSTRAINT plos_papers_pkey PRIMARY KEY (id);


--
-- Name: snp_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY snp_comments
    ADD CONSTRAINT snp_comments_pkey PRIMARY KEY (id);


--
-- Name: snpedia_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY snpedia_papers
    ADD CONSTRAINT snpedia_papers_pkey PRIMARY KEY (id);


--
-- Name: snps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY snps
    ADD CONSTRAINT snps_pkey PRIMARY KEY (id);


--
-- Name: user_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_achievements
    ADD CONSTRAINT user_achievements_pkey PRIMARY KEY (id);


--
-- Name: user_phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_phenotypes
    ADD CONSTRAINT user_phenotypes_pkey PRIMARY KEY (id);


--
-- Name: user_picture_phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_picture_phenotypes
    ADD CONSTRAINT user_picture_phenotypes_pkey PRIMARY KEY (id);


--
-- Name: user_snps_new_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_snps
    ADD CONSTRAINT user_snps_new_pkey PRIMARY KEY (genotype_id, snp_name);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_user_snps_snp_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_user_snps_snp_name ON user_snps USING btree (snp_name);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_genotypes_by_snp_on_snp_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_genotypes_by_snp_on_snp_name ON genotypes_by_snp USING btree (snp_name);


--
-- Name: index_snp_references_backup_on_paper_id_and_paper_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_snp_references_backup_on_paper_id_and_paper_type ON snp_references_backup USING btree (paper_id, paper_type);


--
-- Name: index_snp_references_backup_on_snp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_snp_references_backup_on_snp_id ON snp_references_backup USING btree (snp_id);


--
-- Name: index_snp_references_on_paper_id_and_paper_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_snp_references_on_paper_id_and_paper_type ON snp_references USING btree (paper_id, paper_type);


--
-- Name: index_snp_references_on_snp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_snp_references_on_snp_id ON snp_references USING btree (snp_id);


--
-- Name: index_snps_by_genotype_on_genotype_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_snps_by_genotype_on_genotype_id ON snps_by_genotype USING btree (genotype_id);


--
-- Name: index_snps_chromosome_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_snps_chromosome_position ON snps USING btree (chromosome, "position");


--
-- Name: index_snps_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_snps_on_id ON snps USING btree (id);


--
-- Name: index_snps_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_snps_on_name ON snps USING btree (name);


--
-- Name: index_snps_ranking; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_snps_ranking ON snps USING btree (ranking);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_persistence_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_persistence_token ON users USING btree (persistence_token);


--
-- Name: snps_position_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX snps_position_idx ON snps USING btree ("position");


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_a383e6630e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY genotypes_by_snp
    ADD CONSTRAINT fk_rails_a383e6630e FOREIGN KEY (snp_name) REFERENCES snps(name);


--
-- Name: fk_rails_b8184b81ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY snps_by_genotype
    ADD CONSTRAINT fk_rails_b8184b81ff FOREIGN KEY (genotype_id) REFERENCES genotypes(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

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

