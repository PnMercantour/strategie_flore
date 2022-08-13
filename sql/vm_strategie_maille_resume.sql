-- flore.vm_strategie_maille_resume source
CREATE MATERIALIZED VIEW flore.vm_strategie_maille_resume TABLESPACE pg_default AS
SELECT mt.id,
  count(*) AS nb_taxons,
  count(*) FILTER (
    WHERE mt.nb_obs_recentes > 0
  ) AS nb_taxons_recents,
  sum(mt.nb_obs)::integer AS nb_obs,
  sum(mt.nb_obs_recentes)::integer AS nb_obs_recentes
FROM flore.vm_strategie_maille_taxon mt
GROUP BY mt.id WITH DATA;
-- View indexes:
CREATE INDEX vm_strategie_maille_resume_id_idx ON flore.vm_strategie_maille_resume USING btree (id);
COMMENT ON MATERIALIZED VIEW flore.vm_strategie_maille_resume IS 'Cumul des  observations de taxons stratégiques flore par maille1k, date seuil au 1990-01-01';
-- Permissions
ALTER TABLE flore.vm_strategie_maille_resume OWNER TO flore;
GRANT ALL ON TABLE flore.vm_strategie_maille_resume TO flore;