
# 📦 Datawarehouse E-Commerce Olist

## 📖 Contexte du projet
Ce projet fait partie d’un **laboratoire de Business Intelligence** autour des données publiques de la compagnie brésilienne **[Olist](https://olist.com/)**, un des plus grands e-marketplaces du Brésil.  
L’objectif est de construire un **datawarehouse** à partir de 9 fichiers CSV, afin d’exploiter ces données pour des analyses décisionnelles et du reporting.

Les données couvrent environ **100 000 commandes** passées entre 2016 et 2018.  
Elles contiennent des informations sur les commandes, les paiements, la logistique, les clients, les vendeurs, les produits et les évaluations.

---

## 📊 Données sources
Les données utilisées proviennent de Kaggle :  
🔗 [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/olistbr/brazilian-ecommerce)

Ces 9 fichiers CSV (ignorés dans le repo via `.gitignore`) sont :
- `olist_customers_dataset.csv`  
- `olist_geolocation_dataset.csv`  
- `olist_order_items_dataset.csv`  
- `olist_order_payments_dataset.csv`  
- `olist_order_reviews_dataset.csv`  
- `olist_orders_dataset.csv`  
- `olist_products_dataset.csv`  
- `olist_sellers_dataset.csv`  
- `product_category_name_translation.csv`

---

## 🛠️ Technologies et outils
- **SQL Server** : moteur de base de données principal pour le **staging** et le **datawarehouse**
- **SSMS (SQL Server Management Studio)** : gestion des bases et requêtes SQL
- **SSIS (SQL Server Integration Services)** : ETL pour l’intégration et la transformation des données
- **SQLAlchemy (Python)** : connexion et chargement des CSV dans le staging
- **Power BI / autre outil BI** : pour la visualisation et les rapports
- **Git & GitHub** : versionning et partage du projet

---

## 🎯 Objectifs
- Créer un **staging** contenant les données brutes (issues des CSV)  
- Construire un **modèle dimensionnel** adapté à l’analyse décisionnelle  
- Mettre en place les processus ETL pour alimenter le datawarehouse  
- Développer des rapports permettant de répondre à des questions business, telles que :
  - Montant et quantité par catégorie de produits  
  - Répartition des ventes par type de produit  
  - Identification des meilleurs clients et vendeurs  
  - Produits les plus vendus et les mieux évalués  
  - Suivi des ventes dans le temps (jour, mois, année)  
  - Localisation des clients et vendeurs  
  - Analyse des modes de paiement  

---

## 📂 Structure du dépôt
    .
    ├── exploration.sql                 # Scripts SQL (exploration et création DW)
    ├── olist_staging_csv_to_sqlserver.ipynb  # Notebook pour charger les CSV en staging (via SQLAlchemy)
    ├── .gitignore                      # Exclusion des CSV, environnements virtuels, etc.
    ├── README.md                       # Ce fichier
    └── ...

> ⚠️ **Les CSV et l'environnement virtuel ne sont pas poussés sur
> GitHub** car ils sont listés dans `.gitignore`.\
> Pour récupérer les données, utilisez le lien Kaggle :\
> 🔗 https://www.kaggle.com/olistbr/brazilian-ecommerce

------------------------------------------------------------------------

## 🚀 Utilisation

1.  **Cloner le repo** :

    ``` bash
    git clone https://github.com/HassanSaleban/Datawarehouse_E_Commerce_Olist.git
    cd Datawarehouse_E_Commerce_Olist
    ```

2.  **Télécharger les données** depuis Kaggle et placer les CSV dans un
    dossier local (ex: `data/`).

3.  **Charger les données** :

    -   Soit avec **SQLAlchemy** (via le notebook fourni) pour remplir
        le staging
    -   Soit avec **SSIS** pour automatiser les flux ETL

4.  **Construire le modèle dimensionnel** dans SQL Server et alimenter
    le datawarehouse.

5.  **Analyser les données** via vos outils BI (Power BI, Tableau,
    etc.).

------------------------------------------------------------------------

## ✨ Auteur

Projet réalisé par **[Hassan
Saleban](https://github.com/HassanSaleban)**\
Dans le cadre d'un laboratoire de BI & Datawarehousing.