SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: facets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.facets (
    id bigint NOT NULL,
    model character varying,
    "column" character varying,
    value character varying,
    locale character varying,
    country character varying,
    home_screen_section character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: facets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.facets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.facets_id_seq OWNED BY public.facets.id;


--
-- Name: localized_strings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localized_strings (
    id bigint NOT NULL,
    model character varying,
    "column" character varying,
    value character varying,
    value_in_hu character varying,
    value_in_de character varying,
    value_in_rs character varying,
    value_in_en character varying,
    value_in_sk character varying,
    value_in_ro character varying,
    value_in_sl character varying,
    value_in_cz character varying,
    value_in_hr character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: localized_strings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.localized_strings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localized_strings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.localized_strings_id_seq OWNED BY public.localized_strings.id;


--
-- Name: restaurant_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurant_images (
    id bigint NOT NULL,
    restaurant_id bigint,
    name character varying,
    paid boolean,
    restaurant_image_file_name character varying,
    restaurant_image_content_type character varying,
    restaurant_image_file_size integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: restaurant_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.restaurant_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: restaurant_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restaurant_images_id_seq OWNED BY public.restaurant_images.id;


--
-- Name: restaurant_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurant_reviews (
    id bigint NOT NULL,
    restaurant_id integer,
    title character varying,
    print text,
    year character varying,
    rating character varying,
    english_translation text,
    german_translation text,
    localized_translation text,
    price_value character varying,
    price_information character varying,
    price_information_rating integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: restaurant_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.restaurant_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: restaurant_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restaurant_reviews_id_seq OWNED BY public.restaurant_reviews.id;


--
-- Name: restaurants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurants (
    id bigint NOT NULL,
    title character varying,
    city character varying,
    postcode character varying,
    address character varying,
    email character varying,
    website character varying,
    twitter character varying,
    facebook character varying,
    phone_1 character varying,
    phone_2 character varying,
    region character varying,
    country character varying,
    marker character varying,
    show_on_maps boolean,
    latitude character varying,
    longitude character varying,
    zoom text,
    def_people_one_name character varying,
    def_people_one_title character varying,
    def_people_two_name character varying,
    def_people_two_title character varying,
    def_people_three_name character varying,
    def_people_three_title character varying,
    credit_card boolean,
    wifi boolean,
    reservation_needed boolean,
    has_parking boolean,
    pop boolean,
    open_info character varying,
    open_on_monday boolean,
    open_on_sunday boolean,
    open_on_tuesday boolean,
    open_on_wednesday boolean,
    open_on_thursday boolean,
    open_on_friday boolean,
    open_on_saturday boolean,
    open_mon_morning_start character varying,
    open_mon_morning_end character varying,
    open_mon_afternoon_start character varying,
    open_mon_afternoon_end character varying,
    open_tue_morning_start character varying,
    open_tue_morning_end character varying,
    open_tue_afternoon_start character varying,
    open_tue_afternoon_end character varying,
    open_wed_morning_start character varying,
    open_wed_morning_end character varying,
    open_wed_afternoon_start character varying,
    open_wed_afternoon_end character varying,
    open_thu_morning_start character varying,
    open_thu_morning_end character varying,
    open_thu_afternoon_start character varying,
    open_thu_afternoon_end character varying,
    open_fri_morning_start character varying,
    open_fri_morning_end character varying,
    open_fri_afternoon_start character varying,
    open_fri_afternoon_end character varying,
    open_sat_morning_start character varying,
    open_sat_morning_end character varying,
    open_sat_afternoon_start character varying,
    open_sat_afternoon_end character varying,
    open_sun_morning_start character varying,
    open_sun_morning_end character varying,
    open_sun_afternoon_start character varying,
    open_sun_afternoon_end character varying,
    year character varying,
    search_cache text,
    tags_cache text,
    tags_index character varying,
    "position" integer,
    rating character varying,
    price_value character varying,
    price_information character varying,
    price_information_rating integer,
    hero_image_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tsv tsvector
);


--
-- Name: restaurants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.restaurants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restaurants_id_seq OWNED BY public.restaurants.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying,
    name_in_de character varying,
    name_in_en character varying,
    name_in_sk character varying,
    name_in_rs character varying,
    name_in_ro character varying,
    name_in_cz character varying,
    name_in_sl character varying,
    name_in_hr character varying,
    app_home_screen_section character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    id bigint NOT NULL,
    model character varying,
    "column" character varying,
    value character varying,
    icon character varying,
    locale character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    unique_hash character varying,
    expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: facets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facets ALTER COLUMN id SET DEFAULT nextval('public.facets_id_seq'::regclass);


--
-- Name: localized_strings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localized_strings ALTER COLUMN id SET DEFAULT nextval('public.localized_strings_id_seq'::regclass);


--
-- Name: restaurant_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_images ALTER COLUMN id SET DEFAULT nextval('public.restaurant_images_id_seq'::regclass);


--
-- Name: restaurant_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_reviews ALTER COLUMN id SET DEFAULT nextval('public.restaurant_reviews_id_seq'::regclass);


--
-- Name: restaurants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants ALTER COLUMN id SET DEFAULT nextval('public.restaurants_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: facets facets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.facets
    ADD CONSTRAINT facets_pkey PRIMARY KEY (id);


--
-- Name: localized_strings localized_strings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localized_strings
    ADD CONSTRAINT localized_strings_pkey PRIMARY KEY (id);


--
-- Name: restaurant_images restaurant_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_images
    ADD CONSTRAINT restaurant_images_pkey PRIMARY KEY (id);


--
-- Name: restaurant_reviews restaurant_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_reviews
    ADD CONSTRAINT restaurant_reviews_pkey PRIMARY KEY (id);


--
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_restaurant_images_on_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurant_images_on_restaurant_id ON public.restaurant_images USING btree (restaurant_id);


--
-- Name: index_restaurants_on_hero_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_hero_image_id ON public.restaurants USING btree (hero_image_id);


--
-- Name: index_restaurants_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_restaurants_on_tsv ON public.restaurants USING gin (tsv);


--
-- Name: index_users_on_unique_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unique_hash ON public.users USING btree (unique_hash);


--
-- Name: restaurants tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.restaurants FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tsv', 'pg_catalog.simple', 'search_cache', 'tags_cache');


--
-- Name: restaurant_images fk_rails_3ede18e470; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurant_images
    ADD CONSTRAINT fk_rails_3ede18e470 FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20171107150337'),
('20171108144410'),
('20171108145704'),
('20171108154745'),
('20171115140509'),
('20171115141540'),
('20171205143744'),
('20171207152354'),
('20171207152421');


