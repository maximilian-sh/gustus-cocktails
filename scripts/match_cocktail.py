#!/usr/bin/env python3
"""Fuzzy-match a normalized filename against the known Gustus cocktail IDs.
Prints the matched cocktail ID (correct camelCase spelling) or nothing if no
close enough match is found. Tolerates typos (e.g. "bloody marry" -> bloodyMary).
"""
import sys
import difflib

COCKTAIL_IDS = [
    "mojito", "moscowMule", "daiquiri", "pinaColada", "negroni", "ginSour",
    "oldFashioned", "margarita", "whiskeySour", "cosmopolitan",
    "espressoMartini", "manhattan", "ginTonic", "hurricane", "caipirinha",
    "bloodyMary", "darkNStormy", "tomCollins", "paloma", "maiTai",
    "longIslandIcedTea",
]

ALIASES = {
    "ginandtonic": "ginTonic",
    "darkandstormy": "darkNStormy",
    "longisland": "longIslandIcedTea",
}

def normalize(s):
    return "".join(ch for ch in s.lower() if ch.isalnum())

NORMALIZED_TO_ID = {normalize(cid): cid for cid in COCKTAIL_IDS}
NORMALIZED_TO_ID.update({normalize(k): v for k, v in ALIASES.items()})

def match(raw):
    key = normalize(raw)
    if key in NORMALIZED_TO_ID:
        return NORMALIZED_TO_ID[key]
    candidates = difflib.get_close_matches(key, NORMALIZED_TO_ID.keys(), n=1, cutoff=0.8)
    if candidates:
        return NORMALIZED_TO_ID[candidates[0]]
    return ""

if __name__ == "__main__":
    print(match(sys.argv[1]) if len(sys.argv) > 1 else "")
