# Stratégie flore

## Présentation de la stratégie

Lire la doc (répertoire doc)

## Outils

Projet QGIS accessible en ligne (service `projets`, schéma `flore`, projet `Stratégie Flore`) ou dans le répertoire QGIS.

## Structure de la base de données

Les données sont enregistrées dans le schéma flore de la base de données bd*pnm (service \_projets*).

Le projet exploite par ailleurs les mailles 1k (dans le schéma limites) et les observations geonature (dans le schéma gn_synthese).

`strategie_taxons` est un import des données compilées par le CBNA pour les besoins du projet.  
Une ligne par cd_ref.  
Il y a quelques incohérences dans la table : des taxons qui ne sont pas des taxons de référence. A corriger (remplacement du cd_nom par le cd_ref, fusion des données si cd_ref en doublon). Voir le script `sql/check.sql`.  
Ajout des attributs score et priorite.

- score est initialement issu de la table strategie_notation (voir ci dessous).

- priorite est initialement calculé à partir du score de l'espèce.
- score >=9 priorité 1
- score 8 priorité 2
- score 7 priorité 3
- score < 7 priorité 4
- score non calculé priorité null

```
select priorite, count(\*) from flore.strategie_taxons
group by priorite
order by priorite
```

La priorité et le score sont éditables de façon indépendante (pas de trigger sur les attributs).

`strategie_notation` est un import des données de notation (à l'origine une feuille de calcul de tableur).  
Une ligne par cd_ref.  
Certains taxons de strategie_taxons sont absents de la liste.

`strategie_mailles` donne un décompte du nombre de mailles et de nombre de mailles actives avant/depuis 1990 sur divers territoires de référence (Alpes, PNM). Cette table est utile à l'algorithme de notation.

`taxref_12` est une table de correspondance entre les taxons de référence (cd_ref v12) utiles au projet et les cd_nom v 12 synonymes. Cette table est utilisée pour associer les cd_nom des observations issues de geonature au bon taxon de référence, sachant que la taxonomie de l'environnement geonature/bd_pnm est en version 11.

### Vues matérialisées

Les vues matérialisées calculent la correspondance entre observations et maille pour les taxons étudiés.

`vm_strategie_maille_taxon` est une vue matérialisée qui donne le nombre d'observations par maille1k et par taxon de référence, avant/depuis 1990. Cette vue est indexée sur l'id maille et sur le cd_ref. Elle peut être utilisée pour construire des requêtes qgis personnalisées par jointure avec la table des mailles `limites.maille1k`

`vm_strategie` est une vue matérialisée de synthèse par maille (taxons agrégés).
