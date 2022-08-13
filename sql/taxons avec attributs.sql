-- détail par maille/taxon
-- avec attributs pour filtrage sur le client
select m.id,
    m.cd_sig,
    m.geom,
    mt.cd_ref,
    mt.nb_obs,
    mt.nb_obs_recentes,
    t.nom_valide,
    t.priorite,
    t.cd_indigenat,
    m.coeur,
    m.aire_adhesion,
    m.aire_optimale_adhesion,
    m.aire_optimale_totale
from limites.maille1k m
    join flore.vm_strategie_maille_taxon mt using (id)
    join flore.strategie_taxons t on (mt.cd_ref = t.cd_ref12);