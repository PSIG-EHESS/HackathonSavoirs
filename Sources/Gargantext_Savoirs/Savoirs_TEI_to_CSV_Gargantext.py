#!/usr/bin/env python
# coding: utf-8

# In[2]:


#get_ipython().system('git clone https://github.com/PSIG-EHESS/HackathonSavoirs.git')


# In[4]:


import glob, os, re
import pandas as pd
from lxml import etree


# ```
# <teiHeader>
#  <fileDesc>
#   <titleStmt>
#    <title level="a" type="main">
#     <hi xml:lang="fr">L’étruscologie : une histoire contemporaine ?</hi>
#    </title>
#    <author>
#     <persName>
#      <forename>Marie-Laurence</forename>
#      <surname>Haack</surname>
#     </persName>
#     <affiliation> Université de Limoges<lb/>haackml@yahoo.fr </affiliation>
#    </author>
# ...
# ```
# 
# 

# TEI to raw text

# In[5]:


import xml.etree.ElementTree as ET
import re
d = []

input_dir = "HackathonSavoirs-main/CorpusTEI/"

for file_name in glob.glob(input_dir + "*.xml"):
	with open(file_name, encoding="UTF-8") as fp:
		print("FILE:"+file_name)
		parser = etree.XMLParser(recover = True)
		tree = etree.parse(str(file_name), parser)
		filename_short = file_name.split("/")[2].replace(".xml", "")
		txt = ""
		#.//s:body/s:div
		body_div_tei = tree.xpath('.//s:body', namespaces={'s': 'http://www.tei-c.org/ns/1.0'})
		for div_body in body_div_tei:
			for p in div_body:
				#print(ET.tostring(p, encoding='utf8').decode('utf8'))
				res_p = ET.tostring(p, encoding='utf8', method='text').decode('utf8')
				res_p = re.sub("\n", " ", res_p)
				res_p = re.sub(" +", " ", res_p)
				#res_p = re.sub(",", "", res_p)
				txt = txt + res_p #+ "\n\n"
		print(txt)
		fout = open(input_dir+filename_short+".txt", "w", encoding="utf-8")
		fout.write(txt)
		fout.close()
		
		

import os
import stanza
import re
import pandas as pd

nlp = stanza.Pipeline(lang='fr', processors='tokenize')

def clean_str(string):
  return re.sub(r"([a-z_A-Z_éèàîâêôû]+)([0-9]+)", r"\1", string)

d = []
for file_name in glob.glob(input_dir + "*.txt"):
	txt = ""
	count = 1
	with open(file_name, 'r') as f:
		filename = file_name.split("/")[-1].replace(".txt", "")
		print(filename)
		#nom_revue = file_name.split("/")[2].replace(".txt", "").replace("-", "_").split("_")[0]
		#print(nom_revue)
		doc = nlp(f.read())
		ll = [sentence.text for sentence in doc.sentences]
		print("nombre de phrases"+str(len(ll)))
		phrase_avant = ""
		phase_apres = ""
		for item in ll:
			txt = txt + " " + item #concat phrases while < 10
			if count % 10 == 0:
				print("count: "+str(count))
				if count+1 < len(ll):
					phase_apres = ll[count+1]
				else:
					phase_apres = ""
				#print(phase_apres)
				txt = clean_str(txt) #remove notes de bas de page
				d.append({'title': filename,
					'abstract' : clean_str(phrase_avant) + txt + clean_str(phase_apres),
					'publication_year' : 2000,
					'authors' : filename,
					'source' : filename+"_"+str(count),
					'publication_month' : 1,
					'publication_day' : 1})
				txt = ""
				phrase_avant = item
			count=count+1
		
		#last part of txt
		d.append({'title': filename,
					'abstract' : clean_str(phrase_avant) + clean_str(txt),
					'publication_year' : 2000,
					'authors' : filename,
					'source' : filename+"_"+str(count),
					'publication_month' : 1,
					'publication_day' : 1})
		
dataf = pd.DataFrame(d)
dataf['abstract'] = dataf['abstract'].apply(lambda x: f'\"{x}\"')

dataf.to_csv("output.csv", encoding="utf-8", index=False, sep="\t")
	

