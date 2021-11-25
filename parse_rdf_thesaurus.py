import argparse
import math
import re
from typing import Callable

import networkx as nx
import numpy as np
import pandas as pd
from rdflib import Graph
from rdflib import URIRef
from rdflib.namespace import RDF
from rdflib.namespace import SKOS

from common import create_file


def load_graph():
    return Graph().parse(file_path, format="ttl")


def find_concept_index(uri, concepts):
    return concepts.index(list(filter(lambda concept: concept['uri'] == uri, concepts))[0])


def truncate_doi_prefix(uri):
    return re.sub("^.*(?=doi:)", "", uri)


def parse_rdf_relations(concepts_list, import_graph, skos_graph):
    # Add narrower relations as graph edges
    for concept_uri in import_graph.subjects(RDF.type, SKOS.Concept):
        for narrower in import_graph.objects(URIRef(concept_uri), URIRef("%s%s" % (SKOS, 'narrower'))):
            source = find_concept_index(concept_uri, concepts_list)
            target = find_concept_index(narrower, concepts_list)
            skos_graph.add_edge(source, target)
            print("adding link form %d to %d" % (source, target))
    # Print summary
    print("Number of nodes : %s" % skos_graph.number_of_nodes())
    print("Number of edges : %s" % skos_graph.number_of_edges())


def store_headers(concepts_list):
    # save labels and identifiers as vectors for further use
    uris = np.array([concept['uri'] for concept in concepts_list])
    labels = np.array([concept['label'] for concept in concepts_list])
    doi_shortener: Callable = np.vectorize(truncate_doi_prefix)
    np.save("arrays/identifiers", doi_shortener(uris))
    np.save("arrays/labels", labels)


def parse_rdf_concepts(import_graph):
    # Graph representation of the SKOS vocabulary
    skos_graph = nx.Graph()
    # data structure to store label and URIS
    concepts_list = []
    # Nodes will be contain only integers (indexes in concepts array)
    concept_index = 0
    # Parse RDF Concepts into the data structures
    for concept_uri in import_graph.subjects(RDF.type, SKOS.Concept):
        label = import_graph.objects(URIRef(concept_uri), URIRef("%s%s" % (SKOS, 'prefLabel')))
        concept_label = str(list(label)[0])
        concepts_list.append({'uri': concept_uri, 'label': concept_label})
        print("Added concept %s (%s) to list at index %s" % (concept_label, concept_uri, concept_index))
        skos_graph.add_node(concept_index)
        concept_index += 1
    return concepts_list, skos_graph


def parse_arguments():
    parser = argparse.ArgumentParser(description='Computes distance matrices between skos concepts')
    parser.add_argument('file', metavar='F', type=str, nargs=1,
                        help='Relative path of the file to handle')
    return parser.parse_args()


args = parse_arguments()
file_path = args.file[0]

# RDF representation of the SKOS vocabulary
import_graph = load_graph()

concepts_list, skos_graph = parse_rdf_concepts(import_graph)

store_headers(concepts_list)

parse_rdf_relations(concepts_list, import_graph, skos_graph)
