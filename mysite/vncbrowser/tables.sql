SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
CREATE PROCEDURAL LANGUAGE plpgsql;
SET search_path = public, pg_catalog;
CREATE TYPE double3d AS (
	x double precision,
	y double precision,
	z double precision
);
CREATE TYPE integer3d AS (
	x integer,
	y integer,
	z integer
);
CREATE TYPE rgba AS (
	r real,
	g real,
	b real,
	a real
);
CREATE TYPE tablefunc_crosstab_2 AS (
	row_name text,
	category_1 text,
	category_2 text
);
CREATE TYPE tablefunc_crosstab_3 AS (
	row_name text,
	category_1 text,
	category_2 text,
	category_3 text
);
CREATE TYPE tablefunc_crosstab_4 AS (
	row_name text,
	category_1 text,
	category_2 text,
	category_3 text,
	category_4 text
);
CREATE FUNCTION on_edit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    NEW."edition_time" := now();
    RETURN NEW;
END;
$$;
SET default_with_oids = false;
CREATE TABLE auth_group (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);
CREATE SEQUENCE auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE auth_group_id_seq OWNED BY auth_group.id;
CREATE TABLE auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);
CREATE SEQUENCE auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE auth_group_permissions_id_seq OWNED BY auth_group_permissions.id;
CREATE TABLE auth_message (
    id integer NOT NULL,
    user_id integer NOT NULL,
    message text NOT NULL
);
CREATE SEQUENCE auth_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE auth_message_id_seq OWNED BY auth_message.id;
CREATE TABLE auth_permission (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);
CREATE SEQUENCE auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE auth_permission_id_seq OWNED BY auth_permission.id;
CREATE TABLE auth_user (
    id integer NOT NULL,
    username character varying(30) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying(75) NOT NULL,
    password character varying(128) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    is_superuser boolean NOT NULL,
    last_login timestamp with time zone NOT NULL,
    date_joined timestamp with time zone NOT NULL
);
CREATE TABLE auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);
CREATE SEQUENCE auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE auth_user_groups_id_seq OWNED BY auth_user_groups.id;
CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE auth_user_id_seq OWNED BY auth_user.id;
CREATE TABLE auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);
CREATE SEQUENCE auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE auth_user_user_permissions_id_seq OWNED BY auth_user_user_permissions.id;
CREATE TABLE broken_slice (
    stack_id integer NOT NULL,
    index integer NOT NULL
);
CREATE TABLE concept (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    creation_time timestamp with time zone DEFAULT now() NOT NULL,
    edition_time timestamp with time zone DEFAULT now() NOT NULL,
    project_id bigint NOT NULL
);
CREATE SEQUENCE concept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE concept_id_seq OWNED BY concept.id;
CREATE TABLE class (
    class_name character varying(255) NOT NULL,
    description text
)
INHERITS (concept);
CREATE TABLE relation_instance (
    relation_id bigint NOT NULL
)
INHERITS (concept);
COMMENT ON TABLE relation_instance IS 'despite the table names, it is an abstract table only used for inheritance';
CREATE TABLE class_class (
    class_a bigint,
    class_b bigint
)
INHERITS (relation_instance);
COMMENT ON TABLE class_class IS 'relates two classes';
CREATE TABLE class_instance (
    class_id bigint NOT NULL,
    name character varying(255) NOT NULL
)
INHERITS (concept);
CREATE TABLE class_instance_class_instance (
    class_instance_a bigint,
    class_instance_b bigint
)
INHERITS (relation_instance);
COMMENT ON TABLE class_instance_class_instance IS 'relates two class_instances';
CREATE TABLE location (
    location double3d NOT NULL
)
INHERITS (concept);
CREATE TABLE connector (
    confidence integer DEFAULT 5 NOT NULL
)
INHERITS (location);
CREATE TABLE connector_class_instance (
    connector_id bigint NOT NULL,
    class_instance_id bigint NOT NULL
)
INHERITS (relation_instance);
CREATE TABLE django_content_type (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);
CREATE SEQUENCE django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE django_content_type_id_seq OWNED BY django_content_type.id;
CREATE TABLE django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);
CREATE TABLE django_site (
    id integer NOT NULL,
    domain character varying(100) NOT NULL,
    name character varying(50) NOT NULL
);
CREATE SEQUENCE django_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE django_site_id_seq OWNED BY django_site.id;
CREATE TABLE message (
    id integer NOT NULL,
    user_id integer NOT NULL,
    "time" timestamp with time zone DEFAULT now() NOT NULL,
    read boolean DEFAULT false NOT NULL,
    title text DEFAULT 'New message'::text NOT NULL,
    text text,
    action text
);
COMMENT ON COLUMN message.action IS 'URL to be executed (remember that this is not safe against man in the middle when not encrypted)';
CREATE SEQUENCE message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE message_id_seq OWNED BY message.id;
CREATE TABLE project (
    id integer NOT NULL,
    title text NOT NULL,
    public boolean DEFAULT true NOT NULL
);
CREATE SEQUENCE project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE project_id_seq OWNED BY project.id;
CREATE TABLE project_stack (
    project_id integer NOT NULL,
    stack_id integer NOT NULL,
    translation double3d DEFAULT ROW((0)::double precision, (0)::double precision, (0)::double precision) NOT NULL
);
COMMENT ON COLUMN project_stack.translation IS 'nanometer';
CREATE TABLE project_user (
    project_id integer NOT NULL,
    user_id integer NOT NULL
);
CREATE TABLE relation (
    relation_name character varying(255) NOT NULL,
    uri text,
    description text,
    isreciprocal boolean DEFAULT false NOT NULL
)
INHERITS (concept);
COMMENT ON COLUMN relation.isreciprocal IS 'Is the converse of the relationship valid?';
CREATE TABLE settings (
    key text NOT NULL,
    value text
);
CREATE TABLE stack (
    id integer NOT NULL,
    title text NOT NULL,
    dimension integer3d NOT NULL,
    resolution double3d NOT NULL,
    image_base text NOT NULL,
    comment text,
    trakem2_project boolean DEFAULT false NOT NULL
);
COMMENT ON COLUMN stack.dimension IS 'pixel';
COMMENT ON COLUMN stack.resolution IS 'nanometer per pixel';
COMMENT ON COLUMN stack.image_base IS 'base URL to the images';
COMMENT ON COLUMN stack.trakem2_project IS 'States if a TrakEM2 project file is available for this stack.';
CREATE SEQUENCE stack_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE stack_id_seq OWNED BY stack.id;
CREATE TABLE textlabel (
    id integer NOT NULL,
    type character varying(32) NOT NULL,
    text text DEFAULT 'Edit this text ...'::text NOT NULL,
    colour rgba DEFAULT ROW((1)::real, (0.5)::real, (0)::real, (1)::real) NOT NULL,
    font_name text,
    font_style text,
    font_size double precision DEFAULT 32 NOT NULL,
    project_id integer NOT NULL,
    scaling boolean DEFAULT true NOT NULL,
    creation_time timestamp with time zone DEFAULT now() NOT NULL,
    edition_time timestamp with time zone DEFAULT now() NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT textlabel_type_check CHECK ((((type)::text = 'text'::text) OR ((type)::text = 'bubble'::text)))
);
CREATE SEQUENCE textlabel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE textlabel_id_seq OWNED BY textlabel.id;
CREATE TABLE textlabel_location (
    textlabel_id integer NOT NULL,
    location double3d NOT NULL,
    deleted boolean DEFAULT false NOT NULL
);
CREATE TABLE treenode (
    parent_id bigint,
    radius double precision DEFAULT 0 NOT NULL,
    confidence integer DEFAULT 5 NOT NULL
)
INHERITS (location);
CREATE TABLE treenode_class_instance (
    treenode_id bigint NOT NULL,
    class_instance_id bigint NOT NULL
)
INHERITS (relation_instance);
CREATE TABLE treenode_connector (
    treenode_id bigint NOT NULL,
    connector_id bigint NOT NULL
)
INHERITS (relation_instance);
CREATE TABLE "user" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    pwd character varying(255) NOT NULL,
    longname text
);
CREATE SEQUENCE user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER SEQUENCE user_id_seq OWNED BY "user".id;
ALTER TABLE auth_group ALTER COLUMN id SET DEFAULT nextval('auth_group_id_seq'::regclass);
ALTER TABLE auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('auth_group_permissions_id_seq'::regclass);
ALTER TABLE auth_message ALTER COLUMN id SET DEFAULT nextval('auth_message_id_seq'::regclass);
ALTER TABLE auth_permission ALTER COLUMN id SET DEFAULT nextval('auth_permission_id_seq'::regclass);
ALTER TABLE auth_user ALTER COLUMN id SET DEFAULT nextval('auth_user_id_seq'::regclass);
ALTER TABLE auth_user_groups ALTER COLUMN id SET DEFAULT nextval('auth_user_groups_id_seq'::regclass);
ALTER TABLE auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('auth_user_user_permissions_id_seq'::regclass);
ALTER TABLE concept ALTER COLUMN id SET DEFAULT nextval('concept_id_seq'::regclass);
ALTER TABLE django_content_type ALTER COLUMN id SET DEFAULT nextval('django_content_type_id_seq'::regclass);
ALTER TABLE django_site ALTER COLUMN id SET DEFAULT nextval('django_site_id_seq'::regclass);
ALTER TABLE message ALTER COLUMN id SET DEFAULT nextval('message_id_seq'::regclass);
ALTER TABLE project ALTER COLUMN id SET DEFAULT nextval('project_id_seq'::regclass);
ALTER TABLE stack ALTER COLUMN id SET DEFAULT nextval('stack_id_seq'::regclass);
ALTER TABLE textlabel ALTER COLUMN id SET DEFAULT nextval('textlabel_id_seq'::regclass);
ALTER TABLE "user" ALTER COLUMN id SET DEFAULT nextval('user_id_seq'::regclass);
ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);
ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_key UNIQUE (group_id, permission_id);
ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth_message
    ADD CONSTRAINT auth_message_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_key UNIQUE (content_type_id, codename);
ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_key UNIQUE (user_id, group_id);
ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_key UNIQUE (user_id, permission_id);
ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);
ALTER TABLE ONLY class
    ADD CONSTRAINT class_id_key UNIQUE (id);
ALTER TABLE ONLY class_instance
    ADD CONSTRAINT class_instance_id_key UNIQUE (id);
ALTER TABLE ONLY class_instance
    ADD CONSTRAINT class_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY class_instance_class_instance
    ADD CONSTRAINT class_instance_relation_instance_id_key UNIQUE (id);
ALTER TABLE ONLY class_instance_class_instance
    ADD CONSTRAINT class_instance_relation_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY class
    ADD CONSTRAINT class_pkey PRIMARY KEY (id);
ALTER TABLE ONLY class_class
    ADD CONSTRAINT class_relation_instance_id_key UNIQUE (id);
ALTER TABLE ONLY class_class
    ADD CONSTRAINT class_relation_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY concept
    ADD CONSTRAINT concept_id_key UNIQUE (id);
ALTER TABLE ONLY concept
    ADD CONSTRAINT concept_pkey PRIMARY KEY (id);
ALTER TABLE ONLY connector_class_instance
    ADD CONSTRAINT connector_class_instance_id_key UNIQUE (id);
ALTER TABLE ONLY connector_class_instance
    ADD CONSTRAINT connector_class_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY connector
    ADD CONSTRAINT connector_id_key UNIQUE (id);
ALTER TABLE ONLY connector
    ADD CONSTRAINT connector_pkey PRIMARY KEY (id);
ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_app_label_key UNIQUE (app_label, model);
ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);
ALTER TABLE ONLY django_site
    ADD CONSTRAINT django_site_pkey PRIMARY KEY (id);
ALTER TABLE ONLY location
    ADD CONSTRAINT location_id_key UNIQUE (id);
ALTER TABLE ONLY location
    ADD CONSTRAINT location_pkey PRIMARY KEY (id);
ALTER TABLE ONLY message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);
ALTER TABLE ONLY project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);
ALTER TABLE ONLY project_stack
    ADD CONSTRAINT project_stack_pkey PRIMARY KEY (project_id, stack_id);
ALTER TABLE ONLY project_user
    ADD CONSTRAINT project_user_pkey PRIMARY KEY (project_id, user_id);
ALTER TABLE ONLY relation
    ADD CONSTRAINT relation_id_key UNIQUE (id);
ALTER TABLE ONLY relation_instance
    ADD CONSTRAINT relation_instance_id_key UNIQUE (id);
ALTER TABLE ONLY relation_instance
    ADD CONSTRAINT relation_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY relation
    ADD CONSTRAINT relation_pkey PRIMARY KEY (id);
ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (key);
ALTER TABLE ONLY stack
    ADD CONSTRAINT stack_pkey PRIMARY KEY (id);
ALTER TABLE ONLY textlabel
    ADD CONSTRAINT textlabel_pkey PRIMARY KEY (id);
ALTER TABLE ONLY treenode_class_instance
    ADD CONSTRAINT treenode_class_instance_id_key UNIQUE (id);
ALTER TABLE ONLY treenode_class_instance
    ADD CONSTRAINT treenode_class_instance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY treenode
    ADD CONSTRAINT treenode_id_key UNIQUE (id);
ALTER TABLE ONLY treenode
    ADD CONSTRAINT treenode_pkey PRIMARY KEY (id);
ALTER TABLE ONLY "user"
    ADD CONSTRAINT users_name_key UNIQUE (name);
ALTER TABLE ONLY "user"
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
CREATE INDEX auth_message_user_id ON auth_message USING btree (user_id);
CREATE INDEX auth_permission_content_type_id ON auth_permission USING btree (content_type_id);
CREATE INDEX connector_x_index ON connector USING btree (((location).x));
CREATE INDEX connector_y_index ON connector USING btree (((location).y));
CREATE INDEX connector_z_index ON connector USING btree (((location).z));
CREATE INDEX idx_class_instance_id ON treenode_class_instance USING btree (class_instance_id);
CREATE INDEX location_x_index ON treenode USING btree (((location).x));
CREATE INDEX location_y_index ON treenode USING btree (((location).y));
CREATE INDEX location_z_index ON treenode USING btree (((location).z));
CREATE TRIGGER apply_edition_time_update
    BEFORE UPDATE ON class_instance
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit
    BEFORE UPDATE ON textlabel
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit
    BEFORE UPDATE ON concept
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_class
    BEFORE UPDATE ON class
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_class_class
    BEFORE UPDATE ON class_class
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_class_instance
    BEFORE UPDATE ON class_instance
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_class_instance_class_instance
    BEFORE UPDATE ON class_instance_class_instance
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_connector
    BEFORE UPDATE ON connector
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_connector_class_instance
    BEFORE UPDATE ON connector_class_instance
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_location
    BEFORE UPDATE ON location
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_relation
    BEFORE UPDATE ON relation
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_relation_instance
    BEFORE UPDATE ON relation_instance
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_treenode
    BEFORE UPDATE ON treenode
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_treenode_class_instance
    BEFORE UPDATE ON treenode_class_instance
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
CREATE TRIGGER on_edit_treenode_connector
    BEFORE UPDATE ON treenode_connector
    FOR EACH ROW
    EXECUTE PROCEDURE on_edit();
ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY auth_message
    ADD CONSTRAINT auth_message_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY class_class
    ADD CONSTRAINT class_class_class_a_fkey FOREIGN KEY (class_a) REFERENCES class(id) ON DELETE CASCADE;
ALTER TABLE ONLY class_class
    ADD CONSTRAINT class_class_class_b_fkey FOREIGN KEY (class_b) REFERENCES class(id) ON DELETE CASCADE;
ALTER TABLE ONLY class_instance
    ADD CONSTRAINT class_instance_class_id_fkey FOREIGN KEY (class_id) REFERENCES class(id);
ALTER TABLE ONLY class_instance_class_instance
    ADD CONSTRAINT class_instance_class_instance_class_instance_a_fkey FOREIGN KEY (class_instance_a) REFERENCES class_instance(id) ON DELETE CASCADE;
ALTER TABLE ONLY class_instance_class_instance
    ADD CONSTRAINT class_instance_class_instance_class_instance_b_fkey FOREIGN KEY (class_instance_b) REFERENCES class_instance(id) ON DELETE CASCADE;
ALTER TABLE ONLY class_instance_class_instance
    ADD CONSTRAINT class_instance_relation_instance_relation_id_fkey FOREIGN KEY (relation_id) REFERENCES relation(id);
ALTER TABLE ONLY class_instance_class_instance
    ADD CONSTRAINT class_instance_relation_instance_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY class_instance
    ADD CONSTRAINT class_instance_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY class_class
    ADD CONSTRAINT class_relation_instance_relation_id_fkey FOREIGN KEY (relation_id) REFERENCES relation(id);
ALTER TABLE ONLY class_class
    ADD CONSTRAINT class_relation_instance_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY class
    ADD CONSTRAINT class_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY concept
    ADD CONSTRAINT concept_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY connector_class_instance
    ADD CONSTRAINT connector_class_instance_class_instance_id_fkey FOREIGN KEY (class_instance_id) REFERENCES class_instance(id);
ALTER TABLE ONLY connector_class_instance
    ADD CONSTRAINT connector_class_instance_location_id_fkey FOREIGN KEY (connector_id) REFERENCES connector(id) ON DELETE CASCADE;
ALTER TABLE ONLY connector_class_instance
    ADD CONSTRAINT connector_class_instance_project_id_fkey FOREIGN KEY (project_id) REFERENCES project(id);
ALTER TABLE ONLY connector_class_instance
    ADD CONSTRAINT connector_class_instance_relation_id_fkey FOREIGN KEY (relation_id) REFERENCES relation(id);
ALTER TABLE ONLY connector_class_instance
    ADD CONSTRAINT connector_class_instance_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT content_type_id_refs_id_728de91f FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY message
    ADD CONSTRAINT message_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY project_stack
    ADD CONSTRAINT project_stack_project_id_fkey FOREIGN KEY (project_id) REFERENCES project(id);
ALTER TABLE ONLY project_stack
    ADD CONSTRAINT project_stack_stack_id_fkey FOREIGN KEY (stack_id) REFERENCES stack(id);
ALTER TABLE ONLY project_user
    ADD CONSTRAINT project_user_project_id_fkey FOREIGN KEY (project_id) REFERENCES project(id);
ALTER TABLE ONLY project_user
    ADD CONSTRAINT project_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY relation_instance
    ADD CONSTRAINT relation_instance_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY relation
    ADD CONSTRAINT relation_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY textlabel_location
    ADD CONSTRAINT textlabel_location_textlabel_id_fkey FOREIGN KEY (textlabel_id) REFERENCES textlabel(id);
ALTER TABLE ONLY textlabel
    ADD CONSTRAINT textlabel_project_id_fkey FOREIGN KEY (project_id) REFERENCES project(id);
ALTER TABLE ONLY treenode_class_instance
    ADD CONSTRAINT treenode_class_instance_class_instance_id_fkey FOREIGN KEY (class_instance_id) REFERENCES class_instance(id) ON DELETE CASCADE;
ALTER TABLE ONLY treenode_class_instance
    ADD CONSTRAINT treenode_class_instance_relation_id_fkey FOREIGN KEY (relation_id) REFERENCES relation(id);
ALTER TABLE ONLY treenode_class_instance
    ADD CONSTRAINT treenode_class_instance_treenode_id_fkey FOREIGN KEY (treenode_id) REFERENCES treenode(id) ON DELETE CASCADE;
ALTER TABLE ONLY treenode_class_instance
    ADD CONSTRAINT treenode_class_instance_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE ONLY treenode
    ADD CONSTRAINT treenode_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES treenode(id);
