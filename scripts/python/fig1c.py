# cohort_network.py
"""
Plots full-cohort comorbidity co-occurrence network
from the provided cohort file (.csv), before LCA labeling.
"""

import os
import pandas as pd
import numpy as np
import networkx as nx
import matplotlib.pyplot as plt
from itertools import combinations
from dotenv import load_dotenv

# Load .env configuration
load_dotenv()
COHORT_INPUT_CSV = os.getenv("FINAL_COHORT_CSV", "assets/final_cohort.csv")

COMORBIDITY_COLS = [
    "congestive_heart_failure", "cardiac_arrhythmias", "valvular_disease",
    "pulmonary_circulation", "peripheral_vascular", "hypertension", "paralysis",
    "other_neurological", "chronic_pulmonary", "diabetes_uncomplicated",
    "diabetes_complicated", "hypothyroidism", "renal_failure", "liver_disease",
    "peptic_ulcer", "aids", "lymphoma", "metastatic_cancer", "solid_tumor",
    "rheumatoid_arthritis", "coagulopathy", "obesity", "weight_loss",
    "fluid_electrolyte", "blood_loss_anemia", "deficiency_anemias",
    "alcohol_abuse", "drug_abuse", "psychoses", "depression"
]

def plot_cohort_network(df, comorbidity_cols, title="Full-Cohort Network",
                        node_size_scale=2000, edge_weight_scale=20, add_legend=True):
    N = len(df)
    prevalence = {d: df[d].sum() / N for d in comorbidity_cols}
    G = nx.Graph()
    for d in comorbidity_cols:
        G.add_node(d, prevalence=prevalence[d])
    for a, b in combinations(comorbidity_cols, 2):
        n11 = ((df[a] == 1) & (df[b] == 1)).sum()
        if n11 > 0:
            G.add_edge(a, b, weight=n11 / N)
    node_sizes = [prevalence[n] * node_size_scale for n in G.nodes]
    edge_weights = [G[u][v]['weight'] * edge_weight_scale for u, v in G.edges]

    plt.figure(figsize=(10, 10))
    pos = nx.spring_layout(G, k=0.65, scale=10, iterations=300, seed=42)
    nx.draw_networkx_edges(G, pos, width=edge_weights, edge_color='gray', alpha=0.4)
    nx.draw_networkx_nodes(G, pos, node_size=node_sizes, node_color='white', edgecolors='black', linewidths=1, alpha=1)
    nx.draw_networkx_labels(G, pos, font_size=13)
    if add_legend:
        legend_prevalence = [0.5, 0.25, 0.1]
        legend_sizes = [n * node_size_scale for n in legend_prevalence]
        for p, s in zip(legend_prevalence, legend_sizes):
            plt.scatter([], [], s=s, c='white', edgecolors='black', linewidths=1, label=f"{int(p*100)}%")
        plt.legend(scatterpoints=1, frameon=False, labelspacing=1.2,
                   loc='lower left', title="Prevalence", fontsize=12, title_fontsize=13)
    plt.axis('off')
    plt.title(title, fontsize=22)
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    df = pd.read_csv(COHORT_INPUT_CSV)
    plot_cohort_network(df, COMORBIDITY_COLS, title="Full-Cohort Network")
