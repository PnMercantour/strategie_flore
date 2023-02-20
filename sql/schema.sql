--
-- PostgreSQL database dump
--

-- Dumped from database version 13.10 (Debian 13.10-1.pgdg100+1)
-- Dumped by pg_dump version 13.10 (Debian 13.10-1.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: flore; Type: SCHEMA; Schema: -; Owner: flore
--

CREATE SCHEMA flore;


ALTER SCHEMA flore OWNER TO flore;

--
-- Name: find_species_12(integer); Type: FUNCTION; Schema: flore; Owner: flore
--

CREATE FUNCTION flore.find_species_12(id integer) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
--fonction permettant de renvoyer le cd_ref de l'espèce parente d'un taxon à partir de son cd_ref


  DECLARE ref integer;
  BEGIN
	SELECT INTO ref 
	case 
		when id_rang = 'ES' then cd_nom 
		when id_rang in ('SSES', 'VAR') then flore.find_species_12(cd_taxsup)
		else null
	end
		 FROM flore.taxref_12  WHERE cd_nom = id;
	return ref;
  END;
$$;


ALTER FUNCTION flore.find_species_12(id integer) OWNER TO flore;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: taxref_12; Type: TABLE; Schema: flore; Owner: flore
--

CREATE TABLE flore.taxref_12 (
    cd_nom integer NOT NULL,
    cd_ref integer NOT NULL,
    cd_taxsup integer,
    id_rang character varying(10),
    nom_complet character varying(255),
    nom_valide character varying(255),
    nom_complet_html character varying(255),
    classe character varying(50),
    ordre character varying(50),
    famille character varying(50),
    group1_inpn character varying(255),
    group2_inpn character varying(255),
    url text
);


ALTER TABLE flore.taxref_12 OWNER TO flore;

--
-- Name: TABLE taxref_12; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON TABLE flore.taxref_12 IS 'Taxonomie v12 des espèces flore stratégiques';


--
-- Name: cor_taxon_attribut; Type: MATERIALIZED VIEW; Schema: flore; Owner: flore
--

CREATE MATERIALIZED VIEW flore.cor_taxon_attribut AS
 SELECT cor_taxon_attribut.id_attribut,
    max(cor_taxon_attribut.valeur_attribut) AS valeur_attribut,
    t.cd_ref
   FROM ((taxonomie.cor_taxon_attribut
     JOIN taxonomie.taxref USING (cd_ref))
     JOIN flore.taxref_12 t USING (cd_nom))
  WHERE (cor_taxon_attribut.id_attribut = ANY (ARRAY[1, 2]))
  GROUP BY cor_taxon_attribut.id_attribut, t.cd_ref
  WITH NO DATA;


ALTER TABLE flore.cor_taxon_attribut OWNER TO flore;

--
-- Name: MATERIALIZED VIEW cor_taxon_attribut; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON MATERIALIZED VIEW flore.cor_taxon_attribut IS 'Prendre le max permet 1/ d''éliminer les doublons et 2/ de choisir oui lorsque oui et non sont proposés.
id_attribut = 1 pour les espèces patrimoniales et 2 pour les espèces protégées.';


--
-- Name: flore_vasculaire_sensible_SINP_PACA_2021; Type: TABLE; Schema: flore; Owner: flore
--

CREATE TABLE flore."flore_vasculaire_sensible_SINP_PACA_2021" (
    cd_nom integer NOT NULL,
    nom_cite character varying,
    cd_ref integer,
    cd_sensibilite integer,
    duree character varying,
    niveau_administratif character varying,
    cd_administratif integer,
    "version taxref v12" character varying
);


ALTER TABLE flore."flore_vasculaire_sensible_SINP_PACA_2021" OWNER TO flore;

--
-- Name: TABLE "flore_vasculaire_sensible_SINP_PACA_2021"; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON TABLE flore."flore_vasculaire_sensible_SINP_PACA_2021" IS 'Liste_flore_vasculaire_sensible_SINP_PACA_2021 — RefSensibilite';


--
-- Name: flore_vasculaire_sensible_SINP_PACA_2021_cd_nom_seq; Type: SEQUENCE; Schema: flore; Owner: flore
--

CREATE SEQUENCE flore."flore_vasculaire_sensible_SINP_PACA_2021_cd_nom_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE flore."flore_vasculaire_sensible_SINP_PACA_2021_cd_nom_seq" OWNER TO flore;

--
-- Name: flore_vasculaire_sensible_SINP_PACA_2021_cd_nom_seq; Type: SEQUENCE OWNED BY; Schema: flore; Owner: flore
--

ALTER SEQUENCE flore."flore_vasculaire_sensible_SINP_PACA_2021_cd_nom_seq" OWNED BY flore."flore_vasculaire_sensible_SINP_PACA_2021".cd_nom;


--
-- Name: gn_synthese; Type: VIEW; Schema: flore; Owner: flore
--

CREATE VIEW flore.gn_synthese AS
 SELECT s.id_synthese,
    s.unique_id_sinp,
    s.unique_id_sinp_grp,
    s.id_source,
    s.id_module,
    s.entity_source_pk_value,
    s.id_dataset,
    s.id_nomenclature_geo_object_nature,
    s.id_nomenclature_grp_typ,
    s.id_nomenclature_obs_technique,
    s.id_nomenclature_bio_status,
    s.id_nomenclature_bio_condition,
    s.id_nomenclature_naturalness,
    s.id_nomenclature_exist_proof,
    s.id_nomenclature_valid_status,
    s.id_nomenclature_diffusion_level,
    s.id_nomenclature_life_stage,
    s.id_nomenclature_sex,
    s.id_nomenclature_obj_count,
    s.id_nomenclature_type_count,
    s.id_nomenclature_sensitivity,
    s.id_nomenclature_observation_status,
    s.id_nomenclature_blurring,
    s.id_nomenclature_source_status,
    s.id_nomenclature_info_geo_type,
    s.count_min,
    s.count_max,
    s.cd_nom,
    s.nom_cite,
    s.meta_v_taxref,
    s.sample_number_proof,
    s.digital_proof,
    s.non_digital_proof,
    s.altitude_min,
    s.altitude_max,
    s.date_min,
    s.date_max,
    s.validator,
    s.validation_comment,
    s.observers,
    s.determiner,
    s.id_digitiser,
    s.id_nomenclature_determination_method,
    s.comment_context,
    s.comment_description,
    s.meta_validation_date,
    s.meta_create_date,
    s.meta_update_date,
    s.reference_biblio,
    s.id_area_attachment,
    s.cd_hab,
    s.grp_method,
    s.id_nomenclature_behaviour,
    s.place_name,
    s."precision",
    s.additional_data,
    s.id_nomenclature_biogeo_status,
    s.geom
   FROM gn_synthese.synthese_avec_partenaires s
  WHERE ((s.id_nomenclature_info_geo_type = ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO'::character varying, '1'::character varying)) AND (s.id_nomenclature_observation_status = ref_nomenclatures.get_id_nomenclature('STATUT_OBS'::character varying, 'Pr'::character varying)));


ALTER TABLE flore.gn_synthese OWNER TO flore;

--
-- Name: VIEW gn_synthese; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON VIEW flore.gn_synthese IS 'Observations geonature éligibles pour la stratégie flore';


--
-- Name: redirection_taxon; Type: TABLE; Schema: flore; Owner: flore
--

CREATE TABLE flore.redirection_taxon (
    cd_ref_source integer NOT NULL,
    cd_ref integer,
    commentaire character varying
);


ALTER TABLE flore.redirection_taxon OWNER TO flore;

--
-- Name: TABLE redirection_taxon; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON TABLE flore.redirection_taxon IS 'Taxons observés (cd_ref 12) à rediriger vers un autre taxon (également cd_ref 12)';


--
-- Name: COLUMN redirection_taxon.cd_ref_source; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.redirection_taxon.cd_ref_source IS 'Taxon observé (geonature)';


--
-- Name: COLUMN redirection_taxon.cd_ref; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.redirection_taxon.cd_ref IS 'Taxon de substitution';


--
-- Name: strategie_taxons; Type: TABLE; Schema: flore; Owner: flore
--

CREATE TABLE flore.strategie_taxons (
    cd_ref integer NOT NULL,
    nom_valide character varying,
    rang character varying,
    zc_av90 integer,
    zc_ap90 integer,
    aoa_av90 integer,
    aoa_ap90 integer,
    pnm_av90 integer,
    pnm_ap90 integer,
    dep0406_av90 integer,
    dep0406_ap90 integer,
    paca_av90 integer,
    paca_ap90 integer,
    alpes_sud_av90 integer,
    alpes_sud_ap90 integer,
    alpes_av90 integer,
    alpes_ap90 integer,
    uicn_paca character varying,
    uicn_fr character varying,
    cd_indigenat character varying,
    lb_indigenat character varying,
    cdh2 integer,
    cdh4 integer,
    cdh5 integer,
    nv1 integer,
    rv93 integer,
    dv04 integer,
    dv06 character varying,
    hie_for_alp integer,
    hie_tfo_alp integer,
    hie_for_paca integer,
    hie_tfo_paca integer,
    pna_m integer,
    score smallint,
    priorite smallint
);


ALTER TABLE flore.strategie_taxons OWNER TO flore;

--
-- Name: COLUMN strategie_taxons.score; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_taxons.score IS 'Score calculé';


--
-- Name: redirection_cache; Type: MATERIALIZED VIEW; Schema: flore; Owner: flore
--

CREATE MATERIALIZED VIEW flore.redirection_cache AS
 WITH taxons AS (
         SELECT a.cd_ref
           FROM ( SELECT strategie_taxons.cd_ref
                   FROM flore.strategie_taxons
                UNION
                 SELECT rt_1.cd_ref_source
                   FROM (flore.redirection_taxon rt_1
                     LEFT JOIN flore.strategie_taxons st ON ((rt_1.cd_ref_source = st.cd_ref)))) a
        )
 SELECT t.cd_nom,
        CASE
            WHEN (rt.cd_ref_source IS NOT NULL) THEN rt.cd_ref
            ELSE t.cd_ref
        END AS redirect_cd_ref
   FROM ((flore.taxref_12 t
     JOIN taxons USING (cd_ref))
     LEFT JOIN flore.redirection_taxon rt ON ((t.cd_ref = rt.cd_ref_source)))
  WITH NO DATA;


ALTER TABLE flore.redirection_cache OWNER TO flore;

--
-- Name: observation_redirigee; Type: VIEW; Schema: flore; Owner: flore
--

CREATE VIEW flore.observation_redirigee AS
 SELECT obs.id_synthese,
    obs.unique_id_sinp,
    obs.unique_id_sinp_grp,
    obs.id_source,
    obs.id_module,
    obs.entity_source_pk_value,
    obs.id_dataset,
    obs.id_nomenclature_geo_object_nature,
    obs.id_nomenclature_grp_typ,
    obs.id_nomenclature_obs_technique,
    obs.id_nomenclature_bio_status,
    obs.id_nomenclature_bio_condition,
    obs.id_nomenclature_naturalness,
    obs.id_nomenclature_exist_proof,
    obs.id_nomenclature_valid_status,
    obs.id_nomenclature_diffusion_level,
    obs.id_nomenclature_life_stage,
    obs.id_nomenclature_sex,
    obs.id_nomenclature_obj_count,
    obs.id_nomenclature_type_count,
    obs.id_nomenclature_sensitivity,
    obs.id_nomenclature_observation_status,
    obs.id_nomenclature_blurring,
    obs.id_nomenclature_source_status,
    obs.id_nomenclature_info_geo_type,
    obs.count_min,
    obs.count_max,
    obs.cd_nom,
    obs.nom_cite,
    obs.meta_v_taxref,
    obs.sample_number_proof,
    obs.digital_proof,
    obs.non_digital_proof,
    obs.altitude_min,
    obs.altitude_max,
    obs.date_min,
    obs.date_max,
    obs.validator,
    obs.validation_comment,
    obs.observers,
    obs.determiner,
    obs.id_digitiser,
    obs.id_nomenclature_determination_method,
    obs.comment_context,
    obs.comment_description,
    obs.meta_validation_date,
    obs.meta_create_date,
    obs.meta_update_date,
    obs.reference_biblio,
    obs.id_area_attachment,
    obs.cd_hab,
    obs.grp_method,
    obs.id_nomenclature_behaviour,
    obs.place_name,
    obs."precision",
    obs.additional_data,
    obs.id_nomenclature_biogeo_status,
    obs.geom,
    t.cd_ref,
    t.cd_taxsup,
    t.id_rang,
    t.nom_complet,
    t.nom_complet_html,
    t.classe,
    t.ordre,
    t.famille,
    t.group1_inpn,
    t.group2_inpn,
    t.url,
    patrim.patrimonial,
    protect.protege,
    st.uicn_paca,
    st.uicn_fr,
    st.cd_indigenat,
    st.score,
    st.priorite
   FROM (((((flore.gn_synthese obs
     JOIN flore.redirection_cache rc USING (cd_nom))
     JOIN flore.taxref_12 t ON ((rc.redirect_cd_ref = t.cd_nom)))
     JOIN flore.strategie_taxons st ON ((rc.redirect_cd_ref = st.cd_ref)))
     LEFT JOIN ( SELECT cor_taxon_attribut.cd_ref,
            cor_taxon_attribut.valeur_attribut AS patrimonial
           FROM flore.cor_taxon_attribut
          WHERE (cor_taxon_attribut.id_attribut = 1)) patrim ON ((st.cd_ref = patrim.cd_ref)))
     LEFT JOIN ( SELECT cor_taxon_attribut.cd_ref,
            cor_taxon_attribut.valeur_attribut AS protege
           FROM flore.cor_taxon_attribut
          WHERE (cor_taxon_attribut.id_attribut = 2)) protect ON ((st.cd_ref = protect.cd_ref)));


ALTER TABLE flore.observation_redirigee OWNER TO flore;

--
-- Name: VIEW observation_redirigee; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON VIEW flore.observation_redirigee IS 'observations synthese de taxons stratégiques avec attributs du taxon de référence (après redirection)';


--
-- Name: qgis_projects; Type: TABLE; Schema: flore; Owner: flore
--

CREATE TABLE flore.qgis_projects (
    name text NOT NULL,
    metadata jsonb,
    content bytea
);


ALTER TABLE flore.qgis_projects OWNER TO flore;

--
-- Name: strategie_maille_taxon_cache_v2; Type: MATERIALIZED VIEW; Schema: flore; Owner: flore
--

CREATE MATERIALIZED VIEW flore.strategie_maille_taxon_cache_v2 AS
 SELECT m.id,
    rc.redirect_cd_ref AS cd_ref,
    count(*) AS nb_obs,
    count(*) FILTER (WHERE (s.date_min >= '1990-01-01 00:00:00'::timestamp without time zone)) AS nb_obs_recentes
   FROM ((flore.gn_synthese s
     JOIN flore.redirection_cache rc USING (cd_nom))
     JOIN limites.grid m ON ((m.geom OPERATOR(public.&&) s.geom)))
  WHERE ((m.surface_coeur + m.surface_aoa) > (0)::numeric)
  GROUP BY m.id, rc.redirect_cd_ref
  WITH NO DATA;


ALTER TABLE flore.strategie_maille_taxon_cache_v2 OWNER TO flore;

--
-- Name: MATERIALIZED VIEW strategie_maille_taxon_cache_v2; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON MATERIALIZED VIEW flore.strategie_maille_taxon_cache_v2 IS 'Cumul des  observations par maille1k (recouvrement de l''aire optimale totale) et par taxon (après redirection), date seuil au 1990-01-01';


--
-- Name: strategie_maille_resume_cache_v3; Type: MATERIALIZED VIEW; Schema: flore; Owner: flore
--

CREATE MATERIALIZED VIEW flore.strategie_maille_resume_cache_v3 AS
 SELECT cache.id,
    count(*) AS nb_taxons,
    count(*) FILTER (WHERE (cache.nb_obs_recentes > 0)) AS nb_taxons_recents,
    count(*) FILTER (WHERE ((st.priorite = 1) AND (cache.nb_obs_recentes > 0))) AS priorite_1,
    count(*) FILTER (WHERE ((st.priorite = 2) AND (cache.nb_obs_recentes > 0))) AS priorite_2,
    count(*) FILTER (WHERE ((st.priorite = 3) AND (cache.nb_obs_recentes > 0))) AS priorite_3,
    sum(cache.nb_obs) AS nb_obs,
    sum(cache.nb_obs_recentes) AS nb_obs_recentes
   FROM (flore.strategie_maille_taxon_cache_v2 cache
     JOIN flore.strategie_taxons st USING (cd_ref))
  GROUP BY cache.id
  WITH NO DATA;


ALTER TABLE flore.strategie_maille_resume_cache_v3 OWNER TO flore;

--
-- Name: strategie_maille_resume_attributs; Type: VIEW; Schema: flore; Owner: flore
--

CREATE VIEW flore.strategie_maille_resume_attributs AS
 SELECT cache.id,
    cache.nb_taxons,
    cache.nb_taxons_recents,
    cache.priorite_1,
    cache.priorite_2,
    cache.priorite_3,
    cache.nb_obs,
    cache.nb_obs_recentes,
    grid.cd_sig,
    grid.surface_coeur,
    grid.surface_aire_adhesion,
    grid.surface_aoa,
    grid.nom_vallee,
    grid.geom
   FROM (flore.strategie_maille_resume_cache_v3 cache
     JOIN limites.grid USING (id));


ALTER TABLE flore.strategie_maille_resume_attributs OWNER TO flore;

--
-- Name: VIEW strategie_maille_resume_attributs; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON VIEW flore.strategie_maille_resume_attributs IS 'résumé de ce qu''on trouve dans la maille 1k, nombre de taxons, nombre d''observations et  données de localisation géographique';


--
-- Name: strategie_maille_taxon_attributs; Type: VIEW; Schema: flore; Owner: flore
--

CREATE VIEW flore.strategie_maille_taxon_attributs AS
 SELECT grid.id,
    grid.cd_sig,
    t.cd_ref,
    t.cd_taxsup,
    t.id_rang,
    t.nom_complet,
    t.nom_complet_html,
    t.classe,
    t.ordre,
    t.famille,
    t.group1_inpn,
    t.group2_inpn,
    t.url,
    patrim.patrimonial,
    protect.protege,
    st.uicn_paca,
    st.uicn_fr,
    st.cd_indigenat,
    st.score,
    st.priorite,
    cache.nb_obs,
    cache.nb_obs_recentes,
    grid.surface_coeur,
    grid.surface_aire_adhesion,
    grid.surface_aoa,
    grid.nom_vallee,
    grid.geom
   FROM (((((flore.strategie_maille_taxon_cache_v2 cache
     JOIN limites.grid USING (id))
     JOIN flore.taxref_12 t ON ((cache.cd_ref = t.cd_nom)))
     JOIN flore.strategie_taxons st ON ((cache.cd_ref = st.cd_ref)))
     LEFT JOIN ( SELECT cor_taxon_attribut.cd_ref,
            cor_taxon_attribut.valeur_attribut AS patrimonial
           FROM flore.cor_taxon_attribut
          WHERE (cor_taxon_attribut.id_attribut = 1)) patrim ON ((cache.cd_ref = patrim.cd_ref)))
     LEFT JOIN ( SELECT cor_taxon_attribut.cd_ref,
            cor_taxon_attribut.valeur_attribut AS protege
           FROM flore.cor_taxon_attribut
          WHERE (cor_taxon_attribut.id_attribut = 2)) protect ON ((cache.cd_ref = protect.cd_ref)));


ALTER TABLE flore.strategie_maille_taxon_attributs OWNER TO flore;

--
-- Name: VIEW strategie_maille_taxon_attributs; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON VIEW flore.strategie_maille_taxon_attributs IS 'clé primaire id, cd_ref
Donne les principales informations taxonomiques, de protection, de stratégie, de nombre d''observations et de localisation de la maille relatives aux observations du taxon cd_ref (après redirection éventuelle) sur la maille 1k id (cd_sig pour la référence de la maille).';


--
-- Name: strategie_mailles; Type: TABLE; Schema: flore; Owner: flore
--

CREATE TABLE flore.strategie_mailles (
    secteur character varying,
    mailles_1000 integer,
    mailles_actives integer,
    mailles_actives_depuis_1990 integer,
    mailles_actives_avant_1990 integer
);


ALTER TABLE flore.strategie_mailles OWNER TO flore;

--
-- Name: COLUMN strategie_mailles.mailles_1000; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_mailles.mailles_1000 IS 'Nombre total de mailles 1000';


--
-- Name: COLUMN strategie_mailles.mailles_actives; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_mailles.mailles_actives IS 'Nombre de mailles 1000 sur lesquelles au moins une espèce ciblée a été observée';


--
-- Name: COLUMN strategie_mailles.mailles_actives_depuis_1990; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_mailles.mailles_actives_depuis_1990 IS 'Nombre de mailles actives depuis 1990';


--
-- Name: COLUMN strategie_mailles.mailles_actives_avant_1990; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_mailles.mailles_actives_avant_1990 IS 'Nombre de mailles actives avant 1990';


--
-- Name: strategie_notation; Type: TABLE; Schema: flore; Owner: flore
--

CREATE TABLE flore.strategie_notation (
    ogc_fid integer NOT NULL,
    cd_ref integer,
    nom_valide character varying,
    rang character varying,
    zc_av90 integer,
    zc_ap90 integer,
    aoa_av90 integer,
    aoa_ap90 integer,
    pnm_av90 integer,
    pnm_ap90 integer,
    alpes_av90 integer,
    alpes_ap90 integer,
    uicn_paca character varying,
    uicn_fr character varying,
    cd_indigenat character varying,
    lb_indigenat character varying,
    cdh2 integer,
    cdh4 integer,
    cdh5 integer,
    nv1 integer,
    rv93 integer,
    dv04 integer,
    dv06 character varying,
    hie_for_alp integer,
    hie_tfo_alp integer,
    hie_for_paca integer,
    hie_tfo_paca integer,
    pna_m integer,
    m1_pnm integer,
    m1_alpes integer,
    cr_pnm double precision,
    cr_boullet integer,
    vo_alpes character varying,
    va_alpes double precision,
    "vo/va" character varying,
    ir_alpes character varying,
    "paca+alpes" character varying,
    "point sup" integer,
    "point statut" character varying,
    "point vf" integer,
    "paca+alpes+points vf" integer,
    field41 integer,
    field42 character varying,
    field43 integer
);


ALTER TABLE flore.strategie_notation OWNER TO flore;

--
-- Name: COLUMN strategie_notation.cd_ref; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.cd_ref IS 'cd ref Taxref 12 (sauf   >= 20 000 000 : codes internes pour taxons non présents dans Taxref)';


--
-- Name: COLUMN strategie_notation.nom_valide; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.nom_valide IS 'nom valide Taxref';


--
-- Name: COLUMN strategie_notation.rang; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.rang IS 'rang taxonomique';


--
-- Name: COLUMN strategie_notation.zc_av90; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.zc_av90 IS 'Zone cœur : nombre de mailles de 1km de présence ; données < 1990';


--
-- Name: COLUMN strategie_notation.zc_ap90; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.zc_ap90 IS 'Zone cœur : nombre de mailles de 1km de présence ; données >= 1990';


--
-- Name: COLUMN strategie_notation.aoa_av90; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.aoa_av90 IS 'Aire optimale d''adhésion : nombre de mailles de 1km de présence ; données < 1990';


--
-- Name: COLUMN strategie_notation.aoa_ap90; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.aoa_ap90 IS 'Aire optimale d''adhésion : nombre de mailles de 1km de présence ; données >= 1990';


--
-- Name: COLUMN strategie_notation.pnm_av90; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.pnm_av90 IS 'Zone cœur+Aire optimale d''adhésion : nombre de mailles de 1km de présence ; données < 1990';


--
-- Name: COLUMN strategie_notation.pnm_ap90; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.pnm_ap90 IS 'Zone cœur+Aire optimale d''adhésion : nombre de mailles de 1km de présence ; données >= 1990';


--
-- Name: COLUMN strategie_notation.alpes_av90; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.alpes_av90 IS 'Massif des Alpes : nombre de mailles de 1km de présence ; données < 1990';


--
-- Name: COLUMN strategie_notation.alpes_ap90; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.alpes_ap90 IS 'Massif des Alpes : nombre de mailles de 1km de présence ; données >= 1990';


--
-- Name: COLUMN strategie_notation.uicn_paca; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.uicn_paca IS 'cotation UICN PACA';


--
-- Name: COLUMN strategie_notation.uicn_fr; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.uicn_fr IS 'cotation UICN France';


--
-- Name: COLUMN strategie_notation.cd_indigenat; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.cd_indigenat IS 'code indigénat PACA';


--
-- Name: COLUMN strategie_notation.lb_indigenat; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.lb_indigenat IS 'Libellé indigénat PACA';


--
-- Name: COLUMN strategie_notation.cdh2; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.cdh2 IS 'Directive Habitats-Faune-Flore annexe 2';


--
-- Name: COLUMN strategie_notation.cdh4; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.cdh4 IS 'Directive Habitats-Faune-Flore annexe 4';


--
-- Name: COLUMN strategie_notation.cdh5; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.cdh5 IS 'Directive Habitats-Faune-Flore annexe 5';


--
-- Name: COLUMN strategie_notation.nv1; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.nv1 IS 'Espèces végétales protégées en France';


--
-- Name: COLUMN strategie_notation.rv93; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.rv93 IS 'Espèces végétales protégées en région Provence-Alpes-Côte d''Azur';


--
-- Name: COLUMN strategie_notation.dv04; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.dv04 IS 'Espèces végétales protégées dans le département Alpes-de-Haute-Provence';


--
-- Name: COLUMN strategie_notation.dv06; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.dv06 IS 'Espèces végétales protégées dans le département Alpes-Maritimes';


--
-- Name: COLUMN strategie_notation.hie_for_alp; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.hie_for_alp IS 'Hiérarchisation des enjeux de conservation sur le domaine Alpin - espèces à fort enjeux (NIV_PRIO_ALP 2)';


--
-- Name: COLUMN strategie_notation.hie_tfo_alp; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.hie_tfo_alp IS 'Hiérarchisation des enjeux de conservation sur le domaine Alpin - espèces à très fort enjeux (NIV_PRIO_ALP 1)';


--
-- Name: COLUMN strategie_notation.hie_for_paca; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.hie_for_paca IS 'Hiérarchisation des enjeux de conservation en région Provence-Alpes-Côte d''Azur - Espèces à fort enjeu';


--
-- Name: COLUMN strategie_notation.hie_tfo_paca; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.hie_tfo_paca IS 'Hiérarchisation des enjeux de conservation en région Provence-Alpes-Côte d''Azur - Espèces à très fort enjeu';


--
-- Name: COLUMN strategie_notation.pna_m; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON COLUMN flore.strategie_notation.pna_m IS 'PNA messicoles';


--
-- Name: strategie_taxonomie; Type: VIEW; Schema: flore; Owner: flore
--

CREATE VIEW flore.strategie_taxonomie AS
 SELECT t.cd_nom AS cd_ref,
    t.cd_taxsup,
    t.id_rang,
    t.nom_complet,
    t.nom_complet_html,
    t.classe,
    t.ordre,
    t.famille,
    t.group1_inpn,
    t.group2_inpn,
    t.url,
    st.zc_av90,
    st.zc_ap90,
    st.aoa_av90,
    st.aoa_ap90,
    st.pnm_av90,
    st.pnm_ap90,
    st.dep0406_av90,
    st.dep0406_ap90,
    st.paca_av90,
    st.paca_ap90,
    st.alpes_sud_av90,
    st.alpes_sud_ap90,
    st.alpes_av90,
    st.alpes_ap90,
    st.uicn_paca,
    st.uicn_fr,
    st.cd_indigenat,
    st.lb_indigenat,
    st.cdh2,
    st.cdh4,
    st.cdh5,
    st.nv1,
    st.rv93,
    st.dv04,
    st.dv06,
    st.hie_for_alp,
    st.hie_tfo_alp,
    st.hie_for_paca,
    st.hie_tfo_paca,
    st.pna_m,
    st.score,
    st.priorite
   FROM (flore.taxref_12 t
     JOIN flore.strategie_taxons st ON ((t.cd_nom = st.cd_ref)));


ALTER TABLE flore.strategie_taxonomie OWNER TO flore;

--
-- Name: taxons_pnm_ogc_fid_seq; Type: SEQUENCE; Schema: flore; Owner: flore
--

CREATE SEQUENCE flore.taxons_pnm_ogc_fid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE flore.taxons_pnm_ogc_fid_seq OWNER TO flore;

--
-- Name: taxons_pnm_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: flore; Owner: flore
--

ALTER SEQUENCE flore.taxons_pnm_ogc_fid_seq OWNED BY flore.strategie_notation.ogc_fid;


--
-- Name: taxref; Type: VIEW; Schema: flore; Owner: flore
--

CREATE VIEW flore.taxref AS
 SELECT
        CASE
            WHEN (rt.cd_ref_source IS NOT NULL) THEN rt.cd_ref
            ELSE t.cd_ref
        END AS redirect_cd_ref,
    t.cd_nom,
    t.cd_ref,
    t.cd_taxsup,
    t.id_rang,
    t.nom_complet,
    t.nom_valide,
    t.nom_complet_html,
    t.classe,
    t.ordre,
    t.famille,
    t.group1_inpn,
    t.group2_inpn,
    t.url
   FROM (flore.taxref_12 t
     LEFT JOIN flore.redirection_taxon rt ON ((t.cd_ref = rt.cd_ref_source)));


ALTER TABLE flore.taxref OWNER TO flore;

--
-- Name: VIEW taxref; Type: COMMENT; Schema: flore; Owner: flore
--

COMMENT ON VIEW flore.taxref IS 'Taxonomie v12 flore stratégique, avec redirection des taxons (attribut redirect_cd_ref)';


--
-- Name: flore_vasculaire_sensible_SINP_PACA_2021 cd_nom; Type: DEFAULT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore."flore_vasculaire_sensible_SINP_PACA_2021" ALTER COLUMN cd_nom SET DEFAULT nextval('flore."flore_vasculaire_sensible_SINP_PACA_2021_cd_nom_seq"'::regclass);


--
-- Name: strategie_notation ogc_fid; Type: DEFAULT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore.strategie_notation ALTER COLUMN ogc_fid SET DEFAULT nextval('flore.taxons_pnm_ogc_fid_seq'::regclass);


--
-- Name: flore_vasculaire_sensible_SINP_PACA_2021 flore_vasculaire_sensible_SINP_PACA_2021_pkey; Type: CONSTRAINT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore."flore_vasculaire_sensible_SINP_PACA_2021"
    ADD CONSTRAINT "flore_vasculaire_sensible_SINP_PACA_2021_pkey" PRIMARY KEY (cd_nom);


--
-- Name: qgis_projects qgis_projects_pkey; Type: CONSTRAINT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore.qgis_projects
    ADD CONSTRAINT qgis_projects_pkey PRIMARY KEY (name);


--
-- Name: redirection_taxon redirection_taxon_pk; Type: CONSTRAINT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore.redirection_taxon
    ADD CONSTRAINT redirection_taxon_pk PRIMARY KEY (cd_ref_source);


--
-- Name: strategie_taxons strategie_taxons_pk; Type: CONSTRAINT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore.strategie_taxons
    ADD CONSTRAINT strategie_taxons_pk PRIMARY KEY (cd_ref);


--
-- Name: strategie_notation taxons_pnm_pkey; Type: CONSTRAINT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore.strategie_notation
    ADD CONSTRAINT taxons_pnm_pkey PRIMARY KEY (ogc_fid);


--
-- Name: taxref_12 taxref_12_pk; Type: CONSTRAINT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore.taxref_12
    ADD CONSTRAINT taxref_12_pk PRIMARY KEY (cd_nom);


--
-- Name: cor_taxon_attribut_cd_ref_idx; Type: INDEX; Schema: flore; Owner: flore
--

CREATE INDEX cor_taxon_attribut_cd_ref_idx ON flore.cor_taxon_attribut USING btree (cd_ref);


--
-- Name: redirection_cache_cd_nom_idx; Type: INDEX; Schema: flore; Owner: flore
--

CREATE INDEX redirection_cache_cd_nom_idx ON flore.redirection_cache USING btree (cd_nom);


--
-- Name: redirection_taxon_cd_ref_idx; Type: INDEX; Schema: flore; Owner: flore
--

CREATE INDEX redirection_taxon_cd_ref_idx ON flore.redirection_taxon USING btree (cd_ref);


--
-- Name: strategie_maille_resume_cache_v3_id_idx; Type: INDEX; Schema: flore; Owner: flore
--

CREATE INDEX strategie_maille_resume_cache_v3_id_idx ON flore.strategie_maille_resume_cache_v3 USING btree (id);


--
-- Name: strategie_notation_cd_ref_idx; Type: INDEX; Schema: flore; Owner: flore
--

CREATE INDEX strategie_notation_cd_ref_idx ON flore.strategie_notation USING btree (cd_ref);


--
-- Name: taxref_12_cd_ref_idx; Type: INDEX; Schema: flore; Owner: flore
--

CREATE INDEX taxref_12_cd_ref_idx ON flore.taxref_12 USING btree (cd_ref);


--
-- Name: redirection_taxon redirection_taxon_fk; Type: FK CONSTRAINT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore.redirection_taxon
    ADD CONSTRAINT redirection_taxon_fk FOREIGN KEY (cd_ref) REFERENCES flore.strategie_taxons(cd_ref);


--
-- Name: strategie_taxons strategie_taxons_cd_ref_fkey; Type: FK CONSTRAINT; Schema: flore; Owner: flore
--

ALTER TABLE ONLY flore.strategie_taxons
    ADD CONSTRAINT strategie_taxons_cd_ref_fkey FOREIGN KEY (cd_ref) REFERENCES flore.taxref_12(cd_nom);


--
-- Name: SCHEMA flore; Type: ACL; Schema: -; Owner: flore
--

GRANT USAGE ON SCHEMA flore TO PUBLIC;
GRANT USAGE ON SCHEMA flore TO consult_flore;
GRANT USAGE ON SCHEMA flore TO pnm_consult;
GRANT USAGE ON SCHEMA flore TO consult_agpasto;
GRANT USAGE ON SCHEMA flore TO consult_eau;


--
-- Name: TABLE taxref_12; Type: ACL; Schema: flore; Owner: flore
--

REVOKE ALL ON TABLE flore.taxref_12 FROM flore;
GRANT SELECT ON TABLE flore.taxref_12 TO flore;
GRANT ALL ON TABLE flore.taxref_12 TO admin;
GRANT SELECT ON TABLE flore.taxref_12 TO consult_flore;
GRANT SELECT ON TABLE flore.taxref_12 TO pnm_consult;


--
-- Name: TABLE "flore_vasculaire_sensible_SINP_PACA_2021"; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore."flore_vasculaire_sensible_SINP_PACA_2021" TO PUBLIC;
GRANT SELECT ON TABLE flore."flore_vasculaire_sensible_SINP_PACA_2021" TO pnm_consult;


--
-- Name: TABLE gn_synthese; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.gn_synthese TO pnm_consult;


--
-- Name: TABLE redirection_taxon; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.redirection_taxon TO consult_flore;
GRANT SELECT ON TABLE flore.redirection_taxon TO pnm_consult;


--
-- Name: TABLE strategie_taxons; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.strategie_taxons TO consult_flore;
GRANT SELECT ON TABLE flore.strategie_taxons TO pnm_consult;


--
-- Name: TABLE redirection_cache; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.redirection_cache TO consult_agpasto;
GRANT SELECT ON TABLE flore.redirection_cache TO consult_eau;
GRANT SELECT ON TABLE flore.redirection_cache TO consult_flore;
GRANT SELECT ON TABLE flore.redirection_cache TO pnm_consult;


--
-- Name: TABLE observation_redirigee; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.observation_redirigee TO consult_agpasto;
GRANT SELECT ON TABLE flore.observation_redirigee TO consult_eau;
GRANT SELECT ON TABLE flore.observation_redirigee TO consult_flore;
GRANT SELECT ON TABLE flore.observation_redirigee TO pnm_consult;


--
-- Name: TABLE qgis_projects; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.qgis_projects TO consult_flore;
GRANT SELECT ON TABLE flore.qgis_projects TO pnm_consult;


--
-- Name: TABLE strategie_maille_resume_attributs; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.strategie_maille_resume_attributs TO consult_agpasto;
GRANT SELECT ON TABLE flore.strategie_maille_resume_attributs TO consult_eau;
GRANT SELECT ON TABLE flore.strategie_maille_resume_attributs TO consult_flore;
GRANT SELECT ON TABLE flore.strategie_maille_resume_attributs TO pnm_consult;


--
-- Name: TABLE strategie_maille_taxon_attributs; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.strategie_maille_taxon_attributs TO consult_agpasto;
GRANT SELECT ON TABLE flore.strategie_maille_taxon_attributs TO consult_eau;
GRANT SELECT ON TABLE flore.strategie_maille_taxon_attributs TO consult_flore;
GRANT SELECT ON TABLE flore.strategie_maille_taxon_attributs TO pnm_consult;


--
-- Name: TABLE strategie_mailles; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.strategie_mailles TO pnm_consult;


--
-- Name: TABLE strategie_notation; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.strategie_notation TO pnm_consult;


--
-- Name: TABLE strategie_taxonomie; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.strategie_taxonomie TO consult_agpasto;
GRANT SELECT ON TABLE flore.strategie_taxonomie TO consult_eau;
GRANT SELECT ON TABLE flore.strategie_taxonomie TO consult_flore;
GRANT SELECT ON TABLE flore.strategie_taxonomie TO pnm_consult;


--
-- Name: TABLE taxref; Type: ACL; Schema: flore; Owner: flore
--

GRANT SELECT ON TABLE flore.taxref TO pnm_consult;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: flore; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA flore GRANT SELECT ON TABLES  TO consult_agpasto;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA flore GRANT SELECT ON TABLES  TO consult_eau;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA flore GRANT SELECT ON TABLES  TO consult_flore;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA flore GRANT SELECT ON TABLES  TO pnm_consult;


--
-- PostgreSQL database dump complete
--

