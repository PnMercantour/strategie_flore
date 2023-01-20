-- divers contrôles d'intégrité des tables sql
-- en cas d'erreur (retour non vide), ajouter les taxons manquants dans la table  taxref_12 ou corriger le taxon litigieux dans la table incriminée
--
--
-- contrôle d'intégrité de flore.strategie_taxons
-- taxons dont le cd_ref n'est pas un cd_ref  d'espèce, sses, ou var dans la taxonomie v12 ou dont le rang est erroné (par comparaison avec la taxonomie officielle)
select st.*
from flore.strategie_taxons st
    left join flore.taxref_12 t on (st.cd_ref = t.cd_nom)
where t.cd_nom is null
    or t.cd_nom != t.cd_ref
    or t.id_rang not in ('ES', 'SSES', 'VAR')
    or st.rang != t.id_rang;
--
--
-- contrôle d'intégrité de flore.redirection_taxon, colonne cd_ref_source
select r.*
from flore.redirection_taxon r
    left join flore.taxref_12 t on (r.cd_ref_source = t.cd_nom)
where t.cd_nom is null
    or t.cd_nom != t.cd_ref
    or t.id_rang not in ('ES', 'SSES', 'VAR');
-- contrôle d'intégrité de flore.redirection_taxon, colonne cd_ref (si not NULL)
select r.*
from flore.redirection_taxon r
    left join flore.taxref_12 t on (r.cd_ref = t.cd_nom)
where r.cd_ref is not null
    and (
        t.cd_nom is null
        or t.cd_nom != t.cd_ref
        or t.id_rang not in ('ES', 'SSES', 'VAR')
    );
--
-- table flore.redirection_taxon
--
-- Visualisation des redirections nulles
select cd_ref_source,
    tr.nom_valide,
    tr.id_rang
from flore.redirection_taxon r
    left join flore.taxref_12 tr on (r.cd_ref_source = tr.cd_nom)
where r.cd_ref is null;
--
-- Visualisation des redirections vers un autre taxon que celui de l'espèce parente
--
select cd_ref_source, tr.nom_valide  , tr.id_rang, 
flore.find_species_12(r.cd_ref_source) espece_source,
ts.nom_valide,
ts.id_rang,
r.cd_ref,
t_redir.nom_valide,
t_redir.id_rang,
flore.find_species_12(r.cd_ref) espece_redirigee,
ts_redir.nom_valide,
ts_redir.id_rang
from flore.redirection_taxon r
    left join flore.taxref_12 tr on (r.cd_ref_source = tr.cd_nom)
    left join flore.taxref_12 ts on (
        flore.find_species_12(r.cd_ref_source) = ts.cd_nom
    )
    left join flore.taxref_12 t_redir on (r.cd_ref = t_redir.cd_nom)
    left join flore.taxref_12 ts_redir on (
        flore.find_species_12(r.cd_ref) = ts_redir.cd_nom
    )
where r.cd_ref is not null
    and r.cd_ref != flore.find_species_12(r.cd_ref_source);
--
-- Visualisation des redirections naturelles (d'une sous-espèce ou variété vers l'espèce parente)
select cd_ref_source,
    tr.nom_valide,
    tr.id_rang,
    r.cd_ref,
    t_redir.nom_valide,
    t_redir.id_rang
from flore.redirection_taxon r
    left join flore.taxref_12 tr on (r.cd_ref_source = tr.cd_nom)
    left join flore.taxref_12 t_redir on (r.cd_ref = t_redir.cd_nom)
where r.cd_ref is not null
    and r.cd_ref = flore.find_species_12(r.cd_ref_source);