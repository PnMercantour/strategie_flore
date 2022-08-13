import csv
import json
import psycopg2

connection = psycopg2.connect(service='projets')
cur = connection.cursor()

with open('data/taxons.json') as f:
    taxons = set(json.load(f))

with open('data/TAXREF_INPN_v12/TAXREFv12.txt') as csvfile:
    reader = csv.DictReader(csvfile, delimiter='\t')
    for row in reader:
        if row['REGNE'] == 'Plantae' and int(row['CD_REF']) in taxons:
            print(row['CD_NOM'], row['CD_REF'])
            cur.execute(
                f"insert into flore.taxref_12(cd_nom, cd_ref) values({int(row['CD_NOM'])}, {int(row['CD_REF'])})")

cur.close()
connection.commit()
