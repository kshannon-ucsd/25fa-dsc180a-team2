# 25fa-dsc180a-team2
Sepsis Research Replication

Our group will be replicating this research on Multimorbidity profiles of Sepsis patients using the MIMIC III dataset.

Paper linked [here](https://ccforum.biomedcentral.com/articles/10.1186/s13054-019-2486-6#Sec14)

# Setup
# Instructions for [MIMIC III dataset upload](https://mimic.mit.edu/docs/gettingstarted/):
MIMIC-III integrates deidentified, comprehensive clinical data of patients admitted to the Beth Israel Deaconess Medical Center. To download the dataset:

### 1. Create a PhysioNet account and become a credentialed user.
### 2. Follow the tutorials for direct cloud access (recommended), or download the data locally.
### 3. [More information on the MIMIC III Dataset](https://physionet.org/content/mimiciii/1.4/)

Instructions for Pixi setup:
# Pixi Environment Setup Instructions

Follow these steps to reproduce the environment used in this project. This ensures reproducibility and consistent dependency management for all contributors and replicators.

---

## 1. Install Pixi (if not already installed)

```bash
curl -fsSL https://pixi.sh/install.sh | sh
```
You may need to restart your shell for the pixi command to become available.

## 2. Clone the Repository

```bash
git clone git@github.com:kshannon-ucsd/25fa-dsc180a-team2.git
cd 25fa-dsc180a-team2
```
If you do not have SSH access, use the HTTPS URL instead:

```bash
git clone https://github.com/kshannon-ucsd/25fa-dsc180a-team2.git
```

## 3. Install Environment Dependencies

```bash
pixi install
```
This command installs all dependencies defined in pixi.toml and pixi.lock.

## 4. Activate the Pixi Environment

```bash
pixi shell
```
This drops you into a shell where all project dependencies are available for scripting and notebooks.

