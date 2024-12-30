# Gustus Cocktails Database

This repository contains the cocktail database for the Gustus app, including recipes, translations, and images.

## Structure

```
/data
  /base/           # Base cocktail data (ingredients, measurements)
    mojito.json
    moscowMule.json
    ...
  /translations/   # Translations for cocktail names and instructions
    /en/
      mojito.json
      moscowMule.json
      ...
    /de/
      mojito.json
      moscowMule.json
      ...
  /images/         # High-quality cocktail images
    mojito.png
    moscowMule.png
    ...
/schema/          # JSON schemas for validation
```

## Available Cocktails

-   Mojito - A refreshing Cuban highball with rum, lime, mint, and soda
-   Moscow Mule - A spicy vodka cocktail served in a copper mug with ginger beer

## Adding a New Cocktail

1. Create the base cocktail file in `/data/base/[cocktailName].json`
2. Add translations in `/data/translations/[lang]/[cocktailName].json`
3. Add a high-quality image (800x800 to 1500x1500 pixels) in `/data/images/[cocktailName].png`
4. Run validation: `npm run validate`
5. Submit a pull request

### Base Cocktail Format

```json
{
    "id": "cocktailName",
    "image": "cocktailName.png",
    "ingredients": [
        {
            "name": "ingredientId",
            "amount": 60,
            "unit": "ml"
        }
    ],
    "glassType": "Highball",
    "tags": ["rum", "sweet", "classic"]
}
```

### Translation Format

```json
{
    "id": "cocktailName",
    "name": "Cocktail Name",
    "instructions": "Step-by-step instructions...",
    "ingredients": {
        "ingredientId": "Ingredient Name"
    }
}
```

## Image Guidelines

-   Format: PNG with transparency
-   Style: Minimalistic aquarelle (watercolor) drawings
-   Background: Transparent (no background)
-   Resolution: 800x800 to 1500x1500 pixels
-   Colors: Soft, watercolor-like tones
-   Design: Clean, artistic representation of the cocktail with essential elements only
-   Consistency: Similar artistic style and scale across all cocktail illustrations

## Development

```bash
# Install dependencies
npm install

# Run validation
npm run validate
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your cocktail(s)
4. Run validation
5. Submit a pull request

## License

MIT
