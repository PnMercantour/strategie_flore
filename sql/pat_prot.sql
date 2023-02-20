-- enrichissement de la taxonomie v12 avec les indications de patrimonialité et de protection
with pat as (
    select cd_ref,
        valeur_attribut patrimoniale
    from flore.cor_taxon_attribut
    where id_attribut = 1
),
prot as (
    select cd_ref,
        valeur_attribut protegee
    from flore.cor_taxon_attribut
    where id_attribut = 2
)
select st.*,
    patrimoniale,
    protegee
from flore.strategie_taxons st
    left join pat using (cd_ref)
    left join prot using (cd_ref);