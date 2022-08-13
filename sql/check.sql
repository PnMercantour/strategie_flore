-- taxons dont le cd_ref12 n'est pas un cd_ref dans la taxonomie v12
-- indication du cd_ref s'il est dans la liste des taxons, ou NULL
with liste as (
    select st.cd_ref12 cd_nom,
        nom_valide
    from flore.strategie_taxons st
        left join (
            select distinct cd_ref
            from flore.taxref_12
        ) t on (st.cd_ref12 = t.cd_ref)
    where t.cd_ref is null
        and rang in ('ES', 'SSES', 'VAR')
        and cd_ref12 < 20000000
)
select *
from liste
    left join flore.taxref_12 using (cd_nom);