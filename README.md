# Stratégie flore

## Présentation de la stratégie

Lire la doc (répertoire doc)

## Outils

Projet QGIS accessible en ligne (service `projets`, schéma `flore`, projet `Stratégie Flore`) ou dans le répertoire QGIS du projet.

## Structure de la base de données

Les données sont enregistrées dans le schéma flore de la base de données `bd_pnm` (service `projets`).

Le projet exploite par ailleurs les mailles 1k (vue `limites.grid`) et les observations geonature (vue `flore.gn_synthese`).

`taxref_12` est un extrait de la taxonomie v12. Cette table est utilisée pour associer les cd_nom des observations issues de geonature au bon taxon de référence, sachant que la taxonomie de l'environnement geonature/bd_pnm est en version 11.  
Clé primaire: cd_nom,  
index secondaire sur cd_ref.  
Le script `bin/taxref 12.py` peuple cette table avec les taxons flore de référence (taxref v12).
Le script `bin/taxref 12 cd_nom.py` complète cette table avec les synonymes des taxons de `strategie_taxons` et des taxons source et redirigés de la table de redirection `redirection_taxon`, toujours en taxref v12.

`strategie_taxons` est un import des données compilées par le CBNA pour les besoins du projet.  
Une ligne par cd_ref.  
La table originale comportait quelques taxons qui ne sont pas des cd_ref en v12. Elle a été corrigée par le remplacement du cd_nom par le cd_ref et la fusion des données lorsque le cd_ref apparaîssait en doublon.  
On a supprimé les taxons dont le rang n'est pas 'ES', 'SSES' ou 'VAR' ainsi que ceux dont le cd_ref a une valeur supérieure à 20000000 (code interne CBNA)
Après ces opérations la requête suivante ne retourne aucun taxon, signifiant que tous les taxons de la table `strategie_taxons` sont bien des taxons de référence et que le cd_nom de chacun de ces taxons est enregistré dans la table `taxref_12`:

```
select * from flore.strategie_taxons st left join flore.taxref_12 t on (st.cd_ref = t.cd_nom) where t.cd_ref is null or t.cd_ref != t.cd_nom;
```

Ajout des attributs score et priorite.

Les espèces les plus prioritaires ont un indice de priorité 1, puis 2, etc.  
Les espèces les plus prioritaires sont celles dont le score est le plus élevé.

- score est initialement issu de la table strategie_notation (voir ci dessous).

- priorite est initialement calculé à partir du score de l'espèce.
- score >=9 priorité 1
- score 8 priorité 2
- score 7 priorité 3
- score < 7 priorité 4
- score non calculé priorité null

```
select priorite, count(*) from flore.strategie_taxons
group by priorite
order by priorite
```

La priorité et le score sont éditables de façon indépendante (pas de trigger sur les attributs).

`redirection_taxon` permet de rediriger un taxon de référence v12 vers un autre taxon de référence v12 (avec la contrainte que le taxon redirigé soit un taxon stratégique ou NULL). Ce mécanisme est notamment utilisé pour renvoyer certaines obs de sous-espèces ou variétés vers l'espèce. Un renvoi vers la valeur NULL a pour effet de ne pas prendre en compte les observations de ce taxon.

`strategie_notation` est un import des données de notation (à l'origine une feuille de calcul de tableur).  
Une ligne par cd_ref.  
Certains taxons de strategie_taxons sont absents de la liste.

`strategie_mailles` donne un décompte du nombre de mailles et de nombre de mailles actives avant/depuis 1990 sur divers territoires de référence (Alpes, PNM). Cette table est utile à l'algorithme de notation.

### Vues

La vue `flore.gn_synthese` donne les observations geonature éligibles pour la stratégie flore (observations détaillées, toutes dates, tous taxons faune et flore).

La vue `flore.observation_redirigee` donne la liste des observations (synthèse geonature) de taxons stratégiques avec les attributs du taxon de référence (après redirection éventuelle).

La vue `flore.strategie_maille_taxon_attributs` clé primaire (id, cd_ref), donne les principales informations taxonomiques, de protection, de stratégie, de nombre d'observations et de localisation de la maille relatives aux observations du taxon cd_ref (après redirection éventuelle) sur la maille 1k id (cd_sig pour la référence de la maille).

La vue `flore.strategie_maille_resume_attributs` donne un résumé pour chaque maille 1k, avec le nombre de taxons/taxons récents, le mobre de taxons récents par indice de priorité, le nombre d'observations/ observations récentes et les données territoriales de la maille.

### Vues matérialisées (mise en cache des données d'observation agrégées par maille et taxon)

Les vues matérialisée sont à usage interne, leur préférer les vues dans les projets QGIS.

La vue matérialisée `flore.cor_taxon_attribut` détermine la valeur des attributs de protection et de patrimonialité des taxons de la stratégie flore.

La vue matérialisée `flore.redirection_cache` donne pour chaque taxon cd_nom de la stratégie flore (c'est à dire un taxon dont le cd_ref est dans la table strategie_taxons ou cd_ref_source de la table redirection_taxon) le cd_ref redirigé correspondant (peut être NULL). A noter que la liste des cd_ref est établie avec l'hypothèse que cd_ref_source est un taxon de la stratégie, ce qui en toute rigueur n'est pas requis.

La vue matérialisée `flore.strategie_maille_taxon_cache_v2` compile le cumul d'observations et d'observations récentes (1990 et après) par taxon de référence v12 (après redirection éventuelle du taxon source) et maille 1K sur le territoire recouvrant l'aire optimale totale du PNM.

La vue matérialisée `flore.strategie_maille_resume_cache_v3` donne pour chaque maille 1k le nombre d'observations/observations récentes, le nombre de taxons/taxons récents, le nombre de taxons récents de priorité 1, 2 ou 3.

## QGIS
