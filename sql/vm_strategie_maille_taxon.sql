-- flore.vm_strategie_maille_taxon source
CREATE MATERIALIZED VIEW flore.vm_strategie_maille_taxon TABLESPACE pg_default AS
SELECT m.id,
  t.cd_ref,
  count(*) AS nb_obs,
  count(*) FILTER (
    WHERE s.date_min >= '1990-01-01 00:00:00'::timestamp without time zone
  ) AS nb_obs_recentes
FROM gn_synthese.synthese_avec_partenaires s
  JOIN flore.taxref_12 t USING (cd_nom)
  JOIN limites.maille1k m ON m.geom && s.geom
WHERE m.aire_optimale_totale
GROUP BY m.id,
  t.cd_ref WITH DATA;
-- View indexes:
CREATE INDEX vm_strategie_maille_taxon_cd_ref_idx ON flore.vm_strategie_maille_taxon USING btree (cd_ref);
CREATE INDEX vm_strategie_maille_taxon_id_idx ON flore.vm_strategie_maille_taxon USING btree (id);
COMMENT ON MATERIALIZED VIEW flore.vm_strategie_maille_taxon IS 'Cumul des  observations par maille1k et par taxon, date seuil au 1990-01-01';
-- Permissions
ALTER TABLE flore.vm_strategie_maille_taxon OWNER TO flore;
GRANT ALL ON TABLE flore.vm_strategie_maille_taxon TO flore;