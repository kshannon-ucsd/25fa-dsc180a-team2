# lca_network.py
"""
Plots LCA subgroup comorbidity networks using lca_with_classes.csv exported from R.
"""

import os
import math
import numpy as np
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt
from itertools import combinations
from scipy.stats import fisher_exact
from dotenv import load_dotenv

# Load .env configuration
load_dotenv()
LCA_INPUT_CSV = os.getenv("LCA_OUTPUT_CSV", "data/lca_with_classes.csv")

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

def plot_lca_subgroup_network(df, class_id, node_color, comorbidity_cols,
                             node_size_scale=2000, edge_weight_scale=60, offset_scale=0.052,
                             legend_prevalence=(0.5,0.25,0.1)):
    lca_sub = df[df['latent_class'] == class_id]
    N = len(lca_sub)
    prevalence = {d: lca_sub[d].sum() / N for d in comorbidity_cols}

    G = nx.Graph()
    for d in comorbidity_cols:
        G.add_node(d, prevalence=prevalence[d])
    for a, b in combinations(comorbidity_cols, 2):
        col_a, col_b = lca_sub[a], lca_sub[b]
        n11 = ((col_a == 1) & (col_b == 1)).sum()
        n10 = ((col_a == 1) & (col_b == 0)).sum()
        n01 = ((col_a == 0) & (col_b == 1)).sum()
        n00 = ((col_a == 0) & (col_b == 0)).sum()
        table = [[n11, n10], [n01, n00]]
        _, pval = fisher_exact(table, alternative='greater')
        if n11 > 0 and pval < 0.05:
            G.add_edge(a, b, weight=n11/N)
    node_sizes = [prevalence[n] * node_size_scale for n in G.nodes]
    edge_weights = [G[u][v]['weight'] * edge_weight_scale for u, v in G.edges]
    plt.figure(figsize=(9,9))
    pos = nx.spring_layout(G, k=0.72, scale=10, iterations=350, seed=42)
    nx.draw_networkx_edges(G, pos, width=edge_weights, edge_color='gray', alpha=0.6)
    nx.draw_networkx_nodes(G, pos, node_size=node_sizes, node_color=node_color, edgecolors='black', linewidths=2, alpha=1)

    center_x, center_y = np.mean([x for x, y in pos.values()]), np.mean([y for x, y in pos.values()])
    node_size_map = {node: size for node, size in zip(G.nodes(), node_sizes)}
    label_pos = {}
    for node, (x, y) in pos.items():
        dx, dy = x - center_x, y - center_y
        r = math.sqrt(node_size_map[node])
        dist = np.linalg.norm([dx, dy]) or 1
        label_pos[node] = (x + dx/dist*r*offset_scale, y + dy/dist*r*offset_scale)
    nx.draw_networkx_labels(G, label_pos, font_size=15)


    legend_sizes = [n * node_size_scale for n in legend_prevalence]
    for p, s in zip(legend_prevalence, legend_sizes):
        plt.scatter([], [], s=s, c=node_color, edgecolors='black', linewidths=2, label=f"{int(p*100)}%")
    plt.legend(
        scatterpoints=1, frameon=False, labelspacing=1.2, loc='lower left',
        title="Prevalence", fontsize=12, title_fontsize=13
    )
    plt.axis('off')
    plt.title(f"Subgroup {class_id}", fontsize=20)
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    df = pd.read_csv(LCA_INPUT_CSV)
    subgroup_colors = { 1: "black", 3: "limegreen", 4: "blue", 6: "magenta" }
    for class_id, node_color in subgroup_colors.items():
        plot_lca_subgroup_network(df, class_id, node_color, COMORBIDITY_COLS)