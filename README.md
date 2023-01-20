# Stratégie flore

## Présentation de la stratégie

Lire la doc (répertoire doc)

## Outils

Projet QGIS accessible en ligne (service `projets`, schéma `flore`, projet `Stratégie Flore`) ou dans le répertoire QGIS.

## Structure de la base de données

Les données sont enregistrées dans le schéma flore de la base de données `bd_pnm` (service `projets`).

Le projet exploite par ailleurs les mailles 1k (vue `limites.grid`) et les observations geonature (vue `flore.gn_synthese`).

`taxref_12` est une table de correspondance entre les taxons de référence (cd_ref v12) utiles au projet et les cd_nom v 12 synonymes. Cette table est utilisée pour associer les cd_nom des observations issues de geonature au bon taxon de référence, sachant que la taxonomie de l'environnement geonature/bd_pnm est en version 11.  
Clé primaire: cd_nom, index secondaire sur cd_ref.  
Le script `bin/taxref12.py` alimente cette table avec les taxons de `strategie_taxons` et les taxons source de la table de redirection `redirection_taxon`, à partir du csv taxref_12 de l'INPN.

`strategie_taxons` est un import des données compilées par le CBNA pour les besoins du projet.  
Une ligne par cd_ref.  
La table originale comportait quelques taxons qui ne sont pas des cd_ref en v12. Elle a été corrigée par le remplacement du cd_nom par le cd_ref et la fusion des données lorsque le cd_ref apparaîssait en doublon.  
On ne prend pas en compte les taxons dont le rang n'est pas 'ES', 'SSES' ou 'VAR' ni ceux dont le cd_ref a une valeur supérieure à 20000000 (code interne CBNA)
Après ces opérations la requête suivante ne retourne aucun taxon, signifiant que tous les taxons de la table `strategie_taxons` sont bien des taxons de référence et que le cd_ref de chacun de ces taxons est enregistré dans la table `taxref_12`:

```
select * from flore.strategie_taxons st left join flore.taxref_12 t using(cd_ref) where t.cd_ref is null and st.rang not in ('GPE', 'SECT') and st.cd_ref < 20000000
```

Ajout des attributs score et priorite.

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

`strategie_notation` est un import des données de notation (à l'origine une feuille de calcul de tableur).  
Une ligne par cd_ref.  
Certains taxons de strategie_taxons sont absents de la liste.

`strategie_mailles` donne un décompte du nombre de mailles et de nombre de mailles actives avant/depuis 1990 sur divers territoires de référence (Alpes, PNM). Cette table est utile à l'algorithme de notation.

`redirection_taxon` permet d'associer les observations geonature à un taxon de référence v12 qui n'est pas le cd_ref v12 du taxon observé. Ce mécanisme est notamment utilisé pour renvoyer certaines obs de sous-espèces ou variétés vers l'espèce.

La vue `flore.taxref` construite à partir des tables `flore.taxref_12` et `flore.redirection_taxon` présente les éléments principaux de la taxonomie, indiquant en particulier le taxon cd_ref de redirection pour chaque cd_nom de la liste, à côté du cd_ref original.

La vue matérialisée `flore.strategie_maille_taxon_cache` compile le cumul d'oboservations et d'observations récentes (1990 et après) par taxon (après redirection éventuelle du taxon source) et maille 1K sur le territoire recouvrant l'aire optimale totale du PNM.

## QGIS

Ménage dans la table strategie_taxons (nom valide, rang, suppression de colonnes inutiles)

Validation de la table de redirection.

134858 -> 99373
134859 -> 134859
134858 et 134859 sont des cd_nom synonymes de 99549 Galium spurium L., 1753
Tu les renvoies vers 99373 Galium aparine L., 1753
Je remplace les deux lignes par:
99549 -> 99373

149514 -> 113778
149514 est un synonyme de 138869 Pisum sativum L., 1753 subsp. sativum
Tu le renvoies vers 113778 Pisum sativum L., 1753
Je réécris la ligne:
138869 -> 113778

718386 -> 113474
718386 Phleum paniculatum Huds., 1762 subsp. paniculatum
113474 Picris hieracioides L., 1753
A confirmer après avoir sorti les sses non redirigées vers leur espèce.

```
-- les cas de redirection pour lesquels la redirection n'est pas le taxsup de la source
select
rt.cd_ref_source , src.nom_complet nom_source, src.id_rang rang_source,
rt.cd_ref, cible.nom_complet nom_cible, cible.id_rang rang_cible,
src.cd_taxsup cd_nom_sup, sup.nom_complet nom_sup, sup.id_rang rang_sup
from flore.redirection_taxon rt left join flore.taxref_12 src on (rt.cd_ref_source = src.cd_nom)
left join flore.taxref_12 cible on (rt.cd_ref = cible.cd_nom)
left join flore.taxref_12 sup on (src.cd_taxsup = sup.cd_nom)
where rt.cd_ref is not null and  rt.cd_ref != src.cd_taxsup

-- verif que les taxons redirigés sont bien dans la stratégie
select * from flore.redirection_taxon rt left join flore.strategie_taxons st  using(cd_ref)
where rt.cd_ref is not null and st.score is null and rang not in ('GPE', 'SECT') and st.cd_ref < 20000000

-- verif qu'il n'y a pas de boucle (taxon redirigé sur un taxon redirigé)
select * from flore.redirection_taxon rt  join flore.redirection_taxon t2 on rt.cd_ref = t2.cd_ref_source
```
