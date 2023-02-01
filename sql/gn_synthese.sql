create view flore.gn_synthese as
select *
from gn_synthese.synthese_avec_partenaires s
WHERE s.id_nomenclature_info_geo_type = ref_nomenclatures.get_id_nomenclature(
        'TYP_INF_GEO'::character varying,
        '1'::character varying
    )
    AND s.id_nomenclature_observation_status = ref_nomenclatures.get_id_nomenclature(
        'STATUT_OBS'::character varying,
        'Pr'::character varying
    );
COMMENT ON VIEW flore.gn_synthese IS 'Observations geonature éligibles pour la stratégie flore';