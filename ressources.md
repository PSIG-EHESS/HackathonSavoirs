### Ressources numériques disponibles pour le hackaton

# Thésaurus *Savoirs* 
   - [En RDF](https://datu.ehess.fr/savoirs/fr/)
   - [Squelette de script de parsing RDF](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/parse_rdf_thesaurus.py)
   - squelette pour interroger skosmos (thésaurus *Savoirs*)

# Corpus de textes *Savoirs*
  - textes en TEI, dump XML
  - completer balisage EN, en plusieurs formats via NerBeyond (http://nerbeyond.jerteh.rs/) -> CONLL
  - jupyter notebook pour charger les textes et leurs annotations sur Spacy via python
  
# Codes sources et algorithmes
  - Pour l'étude de l'interface :
      - [Brouillon de cahier des charges pour un espace personnel](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/CdCF_Savoirs_espaceperso.pdf)
  - [Code des algorithmes de suggestion actuels](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/strategies.rb)
  - Pour l'analyse de parcours :
      - Exemples de parcours
      - Logs serveurs de *Savoirs* sur demande
      - [Wiki sur le format des logs serveurs](https://gitlab.com/ehess/savoirs/-/wikis/références/Api)
      - [Résumé d'un pipeline de clustering morphologique de parcours de navigation par *topological data analysis* (TDA)](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/Overview%20of%20TDA%20Pipeline%20for%20Path%20Clustering.pdf)
      - [Github d'un projet sur Gallica](https://github.com/LHST-EPFL/TDA-Gallica)


### Outils 
- Mockups
- tal et analyse textuelle
- Analyse réseau : gephi
- Librairies Python de *topological data analysis* (TDA) :
      - [giotto-tda](https://github.com/giotto-ai/giotto-tda)
      - [scikit-tda](https://github.com/scikit-tda/scikit-tda)
      - [GUDHI](https://gudhi.inria.fr)
