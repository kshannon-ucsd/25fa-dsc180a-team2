"""
Plots percentage of patients with multimorbidities within age brackets 
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
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

def create_age_brackets(age):
    if age >= 16 and age <= 24:
        return '16-24'
    elif age >= 25 and age <=44:
        return '25-44'
    elif age >= 45 and age <= 64:
        return '45-64'
    elif age >= 65 and age <= 84:
        return '65-84'
    else:
        return '>85'
    
def build_fig1a_dataframe(df):
    age_order = ['16-24', '25-44', '45-64', '65-84', '>85']
    df['age_brackets'] = pd.Categorical(
        df['age_years'].apply(create_age_brackets),
        categories=age_order,
        ordered=True
    )

    df['comorbidities'] = df[COMORBIDITY_COLS].sum(axis=1)
    df['multimorbidity'] = (df['comorbidities'] >= 2).astype(int)

    output_df = (
        df.groupby('age_brackets')['multimorbidity']
            .agg(['mean','count'])
            .reset_index()
            .rename(columns={'mean': 'pct_multimorbidity', 'count': 'n'})
    )
    
    output_df['pct_multimorbidity'] *= 100
    output_df['se'] = np.sqrt(
        (output_df['pct_multimorbidity'] * (100 - output_df['pct_multimorbidity'])) / output_df['n']
    )
    return output_df

def plot_fig1a(df):
    bars = plt.bar(
        df['age_brackets'],
        df['pct_multimorbidity'],
        yerr=df['se'],
        color='black',
        width=0.4
    )
    plt.xlabel('Age')
    plt.ylabel('Patients with Multimorbidity (%)')
    plt.ylim(0,100)
    plt.title('Fig. 1A')

    for bar, value in zip(bars, df['pct_multimorbidity']):
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2,
            height + 2,
            f'{value:.1f}%',
            ha='center', va='bottom', fontsize=10, color='black'
        )
    plt.show()







if __name__ == "__main__":
    df = pd.read_csv(COHORT_INPUT_CSV)
    fig1a_df = build_fig1a_dataframe(df)
    plot_fig1a(fig1a_df)