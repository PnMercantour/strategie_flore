"Ajout de taxons effectivement observés (collecte des cd_nom) à la table flore.taxref_12"
import csv
import json
import psycopg2


def int_or_none(s):
    return int(s) if s != '' else None


connection = psycopg2.connect(service='projets')
cur = connection.cursor()


# Récupération des taxons observés absents de l'extrait de taxonomie v12
cur.execute("""
with all_taxons as (select distinct cd_nom from flore.gn_synthese gs join taxonomie.taxref using(cd_nom)
where group1_inpn = 'Plantes vasculaires' and id_rang in ('ES', 'SSES', 'VAR'))
select all_taxons.* from all_taxons left join flore.taxref_12 t using (cd_nom) where t.cd_nom is null
""")
taxons = {cd_nom for (cd_nom,) in cur}
print(len(taxons), 'taxons à ajouter à flore.taxref_12')


c = 0

# Insertion dans la table des taxons lus dans le fichier source INPN (long)
with open('data/TAXREF_INPN_v12/TAXREFv12.txt') as csvfile:
    reader = csv.DictReader(csvfile, delimiter='\t')
    for row in reader:
        if row['REGNE'] == 'Plantae' and int(row['CD_NOM']) in taxons:
            c += 1
            # print(row['CD_NOM'], row['CD_REF'], row['CD_TAXSUP'], row['RANG'], row['NOM_COMPLET'], row['NOM_VALIDE'],
            #       row['NOM_COMPLET_HTML'], row['CLASSE'], row['ORDRE'], row['FAMILLE'], row['GROUP1_INPN'], row['GROUP2_INPN'], row['URL'])
            cur.execute(
                "insert into flore.taxref_12(cd_nom, cd_ref, cd_taxsup, id_rang, nom_complet,  nom_valide, nom_complet_html, classe, ordre, famille,  group1_inpn, group2_inpn, url) values (%s,%s,%s,%s,%s, %s,%s,%s,%s,%s, %s,%s,%s)",
                (int(row['CD_NOM']), int(row['CD_REF']), int_or_none(row['CD_TAXSUP']), row['RANG'], row['NOM_COMPLET'], row['NOM_VALIDE'],
                 row['NOM_COMPLET_HTML'], row['CLASSE'], row['ORDRE'], row['FAMILLE'], row['GROUP1_INPN'], row['GROUP2_INPN'], row['URL']))

cur.close()
connection.commit()

print(c, 'taxons ajoutés')
