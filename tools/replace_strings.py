#!/usr/bin/env python3
# tools/replace_strings.py
"""
Scan Dart files for hard-coded UI strings and optionally replace them with AppLanguage keys.

Usage:
  # dry-run (report only)
  python tools/replace_strings.py --dry-run

  # apply replacements (will create .bak backups)
  python tools/replace_strings.py --apply
"""

import re
import os
import argparse
from pathlib import Path

# Mapping: original_string -> AppLanguage.key
# Start with the most frequent ones. Expand as you go.
REPLACEMENTS = {
    # exact matches (French / common)
    "Annuler": "cancel",
    "Ajouter": "add",
    "Modifier": "edit",
    "Supprimer": "delete",
    "Enregistrer": "save",
    "Confirmer": "confirm",
    "Valider": "validate",
    "Appliquer": "apply",
    "Réinitialiser": "reset",
    "Fermer": "close",
    "Voir tout": "viewAll",
    "Voir le détail": "viewDetails",
    "Réessayer": "retry",
    "Chargement...": "loading",
    "Tout": "all",
    "Produit": "product",
    "Produits": "products",
    "Commande": "order",
    "Commandes": "orders",
    "Utilisateur": "user",
    "Utilisateurs": "users",
    "Catégorie": "category",
    "Catégories": "categories",
    "Marque": "brand",
    "Marques": "brands",
    "Prix": "price",
    "Stock": "stock",
    "Actions": "actions",
    "Nom": "name",
    "Date": "date",
    "Statut": "status",
    "Rôle": "role",
    "Adresse": "address",
    "Annulées": "cancelled",
    "En cours": "inProgress",
    "En stock": "inStock",
    "Rupture": "outOfStock",
    "Aucun produit trouvé": "noProductsFound",
    "Aucune commande trouvée": "noOrdersFound",
    "Aucun utilisateur trouvé": "noUsersFound",
    "Aucune catégorie trouvée": "noCategoriesFound",
    "Aucune marque trouvée": "noBrandsFound",
    "Aucun favori trouvé": "noFavoritesFound",
    "Erreur": "error",
    "Erreur de chargement": "loadingError",
    "Veuillez sélectionner une catégorie": "pleaseSelectCategory",
    "Veuillez sélectionner une marque": "pleaseSelectBrand",
    "Payer": "pay",
    "Payer ma commande": "payMyOrder",
    "Mon Panier": "myCart",
    "Paiement": "payment",
    "Mode de paiement": "paymentMethod",
    "Ajouter une adresse": "addAddress",
    "Ajouter une nouvelle adresse": "addNewAddress",
    "Valider l'adresse": "validateAddress",
    "Retour à l'accueil": "backToHome",
    "Télécharger ou visualiser la facture": "downloadOrViewInvoice",
    "Échec du paiement": "paymentFailed",
    "Réessayer le paiement": "retryPayment",
    "Dashboard": "dashboard",
    "Mes Commandes": "myOrders",
    "Mon Compte": "myAccount",
    "Favoris": "favorites",
    "Notifications": "notifications",
    "Language": "language",
    "Se déconnecter": "logout",
    # add more mappings as needed
}

# file extensions to scan
EXTS = ['.dart']

string_pattern = re.compile(r"(['\"])(.+?)\1")  # matches 'text' or "text"

def scan_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    results = []
    for m in string_pattern.finditer(text):
        quote = m.group(1)
        content = m.group(2)
        if content in REPLACEMENTS:
            results.append((m.start(), m.end(), content, quote))
    return results

def replace_in_file(path, apply=False):
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    new_text = text
    matches = []
    # gather matches with positions from end to start to make replacements safe
    for m in list(string_pattern.finditer(text))[::-1]:
        content = m.group(2)
        quote = m.group(1)
        if content in REPLACEMENTS:
            key = REPLACEMENTS[content]
            replacement = f"AppLanguage.{key}"
            # if used inside Text widget, we keep the expression (no quotes)
            # Replace the quoted string only (so no double quotes remain)
            start, end = m.start(), m.end()
            new_text = new_text[:start] + replacement + new_text[end:]
            matches.append((content, key, start))
    if apply and matches:
        bak = path + '.bak'
        Path(bak).write_text(text, encoding='utf-8')
        Path(path).write_text(new_text, encoding='utf-8')
    return matches

def collect_dart_files(root):
    for p in Path(root).rglob('*'):
        if p.suffix in EXTS and 'build' not in p.parts and 'ios' not in p.parts and 'android' not in p.parts:
            yield str(p)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--apply', action='store_true', help='Apply replacements (creates .bak files)')
    parser.add_argument('--root', default='.', help='Project root (default: .)')
    args = parser.parse_args()

    files = list(collect_dart_files(args.root))
    total_matches = 0
    file_matches = {}
    for f in files:
        matches = scan_file(f)
        if matches:
            file_matches[f] = matches
            total_matches += len(matches)

    print(f"Found {total_matches} potential replacements in {len(file_matches)} files.")
    for f, matches in file_matches.items():
        print(f"\nFile: {f}")
        for start, end, content, quote in matches:
            key = REPLACEMENTS[content]
            print(f"  -> \"{content}\"  -> AppLanguage.{key}")

    if not args.apply:
        print("\nDry-run complete. Run with --apply to apply replacements (backups will be created).")
        return

    # apply replacements
    total_applied = 0
    for f in file_matches.keys():
        applied = replace_in_file(f, apply=True)
        if applied:
            print(f"Applied {len(applied)} replacements in {f} (backup: {f}.bak)")
            total_applied += len(applied)
    print(f"\nDone. Applied {total_applied} replacements.")

if __name__ == '__main__':
    main()
