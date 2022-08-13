-- Récupération de la liste des taxons stratégiques au format json
-- voir le script bin/getdata
select json_agg(cd_ref12)::text
from flore.strategie_taxons;