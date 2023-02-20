-- Certains taxons observés (tous_taxons) sont absents de la stratégie.
-- On cherche à retrouver parmi les taxons stratégiques les sous-espèces (ou var) qui peuvent correspondre à ces taxons
with tous_taxons as (
    select distinct cd_ref
    from flore.gn_synthese
        join flore.taxref_12 using (cd_nom)
    where group1_inpn = 'Plantes vasculaires'
        and id_rang in ('ES', 'SSES', 'VAR')
),
taxons_absents as (
    select tous_taxons.*
    from tous_taxons
        left join flore.redirection_cache rc on tous_taxons.cd_ref = rc.cd_nom
    where rc.cd_nom is null
)
select parent.nom_complet as "nom original",
    parent.cd_nom as "cd_ref original",
    enfants.nom_complet as "nom proposé",
    enfants.cd_nom as "nouveau cd_ref"
from flore.taxref_12 enfants
    join taxons_absents on enfants.cd_taxsup = taxons_absents.cd_ref
    join flore.taxref_12 parent on parent.cd_nom = taxons_absents.cd_ref
    join flore.strategie_taxons st on enfants.cd_nom = st.cd_ref
order by parent.nom_complet;