"Ajout de taxons synonymes des taxons de la stratégie floreà la table flore.taxref_12"
import csv
import json
import psycopg2


def int_or_none(s):
    return int(s) if s != '' else None


connection = psycopg2.connect(service='projets')
cur = connection.cursor()


# Récupération des taxons déjà enregistrés (optimisation)
cur.execute(
    "select cd_nom from flore.taxref_12")
taxons = {cd_nom for (cd_nom,) in cur}
print(len(taxons), 'dans la table flore.taxref_12')

# les taxons de la stratégie flore nous intéressent
cur.execute(
    "select cd_ref from flore.strategie_taxons where rang not in ('GPE', 'SECT') and cd_ref < 20000000")
ajout = {cd_ref for (cd_ref,) in cur}

# les taxons redirigés nous intéressent aussi (taxons source)
cur.execute(
    "select cd_ref_source from flore.redirection_taxon"
)
ajout |= {cd_ref for (cd_ref,) in cur}

# les taxons redirigés nous intéressent (taxons redirigés)
cur.execute(
    "select cd_ref from flore.redirection_taxon"
)
ajout |= {cd_ref for (cd_ref,) in cur if cd_ref is not None}

print(len(ajout), 'taxons dont on veut les synonymes')
c = 0

# Insertion dans la table des taxons lus dans le fichier source INPN (long)
with open('data/TAXREF_INPN_v12/TAXREFv12.txt') as csvfile:
    reader = csv.DictReader(csvfile, delimiter='\t')
    for row in reader:
        if row['REGNE'] == 'Plantae' and int(row['CD_NOM']) not in taxons and int(row['CD_REF']) in ajout:
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
