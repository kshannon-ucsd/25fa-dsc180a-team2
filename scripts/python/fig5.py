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
