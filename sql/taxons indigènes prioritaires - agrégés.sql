-- synthèse par maille donnant
-- le nombre de taxons et d'observations (toutes/récentes),
-- la zone du parc
-- pour les taxons indigènes de priorité 1.
select m.id,
    m.cd_sig,
    m.geom,
    count(*) nb_taxons,
    count(*) filter (
        where mt.nb_obs_recentes > 0
    ) nb_taxons_recents,
    sum(mt.nb_obs) nb_obs,
    sum(mt.nb_obs_recentes) nb_obs_recentes,
    m.coeur,
    m.aire_adhesion,
    m.aire_optimale_adhesion,
    m.aire_optimale_totale
from limites.maille1k m
    join flore.vm_strategie_maille_taxon mt using (id)
    join flore.strategie_taxons t on (mt.cd_ref = t.cd_ref12)
where t.priorite = 1
    and t.cd_indigenat = 'I'
group by m.id;