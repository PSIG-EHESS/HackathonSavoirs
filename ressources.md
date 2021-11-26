### Ressources numériques disponibles pour le hackaton

# Thésaurus *Savoirs* 
   - [Accéssible sur datu.ehess.fr](https://datu.ehess.fr/savoirs/fr/)
   - [téléchargéable en format RDF/Turtle](https://datu.ehess.fr/rest/v1/savoirs/data?format=text/turtle) 
  
# Corpus de textes *Savoirs*
  - corpus d'articles : 1) en format [TXT brut](xxx), 2) avec enrichissement notamment entités nommées en format [XML/TEI](xxx)
  - une version augmentéorpus de ce corpus avec une annotation en entités nommées [plus exhaustive](xxx)
  - [Résultats du travail de stage d'Alex Soares sur le projet](https://github.com/PSIG-EHESS/SavoirsEN), vous trouverez des jupyter notebook avec des exemples de code en Python vous permettant charger les textes et leurs annotations sur Spacy via python
  -  
  
# Codes sources et algorithmes
  - [Vidéo de présentation générale de l'appli](https://drive.protonmail.com/urls/MVADPDEESC#Hl4evDhz3rwQ)
  - Pour l'étude de l'interface :
      - [Brouillon de cahier des charges pour un espace personnel](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/CdCF_Savoirs_espaceperso.pdf)
  - [Extrait du CdCF des algorithmes de suggestion actuels](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/CdCF_suggestion.pdf)
  - Code des algorithmes de suggestion actuels
      - [strategies.rb](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/strategies.rb)
      - [strategies_spec.rb](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/strategies_spec.rb)
      - [entry.rb](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/entry.rb)
  - Pour l'analyse de parcours :
      - Exemples de parcours (pour le défis #3, à venir)
      - Logs serveurs de *Savoirs* sur demande
      - [Wiki sur le format des logs serveurs](https://gitlab.com/ehess/savoirs/-/wikis/références/Api)
      - [Résumé d'un pipeline de clustering morphologique de parcours de navigation par *topological data analysis* (TDA)](https://github.com/PSIG-EHESS/HackathonSavoirs/blob/main/Overview%20of%20TDA%20Pipeline%20for%20Path%20Clustering.pdf)
      - [Github d'un projet sur Gallica](https://github.com/LHST-EPFL/TDA-Gallica)


### Outils 
- Mockups
- TAL et analyse textuelle
      - [TXM](http://textometrie.ens-lyon.fr/?lang=en)
      - [Voyants-Tools](https://voyant-tools.org/)
      - [Spacy](https://spacy.io/)
      - [NERBeyond](http://nerbeyond.jerteh.rs/)
- Analyse réseau : [Gephi] (https://gephi.org/)
- Librairies Python de *topological data analysis* (TDA) :
      - [giotto-tda](https://github.com/giotto-ai/giotto-tda)
      - [scikit-tda](https://github.com/scikit-tda/scikit-tda)
      - [GUDHI](https://gudhi.inria.fr)
