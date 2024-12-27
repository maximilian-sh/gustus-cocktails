# Gustus Cocktails Database

This repository contains the cocktail database for the Gustus app, including recipes and translations.

## Structure

```
/data
  /base/           # Base cocktail data (ingredients, measurements)
    mojito.json
    ...
  /translations/   # Translations for cocktail names and instructions
    /en/
      mojito.json
      ...
    /de/
      mojito.json
      ...
/schema/          # JSON schemas for validation
```

## Adding a New Cocktail

1. Create the base cocktail file in `/data/base/[cocktail-name].json`
2. Add translations in `/data/translations/[lang]/[cocktail-name].json`
3. Run validation: `npm run validate`
4. Submit a pull request

### Base Cocktail Format

```json
{
    "id": "cocktail-name",
    "image": "cocktail-name.png",
    "ingredients": [
        {
            "name": "ingredient-id",
            "amount": 2,
            "unit": "oz"
        }
    ],
    "glassType": "Highball",
    "tags": ["rum", "sweet", "classic"]
}
```

### Translation Format

```json
{
    "id": "cocktail-name",
    "name": "Cocktail Name",
    "instructions": "Step-by-step instructions...",
    "ingredients": {
        "ingredient-id": "Ingredient Name"
    }
}
```

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
