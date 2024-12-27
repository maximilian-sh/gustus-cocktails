const Ajv = require("ajv");
const { glob } = require("glob");
const fs = require("fs");
const path = require("path");

const ajv = new Ajv();

// Load schemas
const baseCocktailSchema = JSON.parse(fs.readFileSync(path.join(__dirname, "../schema/base-cocktail.schema.json")));
const translationSchema = JSON.parse(fs.readFileSync(path.join(__dirname, "../schema/translation.schema.json")));

// Compile validators
const validateBaseCocktail = ajv.compile(baseCocktailSchema);
const validateTranslation = ajv.compile(translationSchema);

async function validate() {
    let hasErrors = false;

    // Validate base cocktails
    const baseFiles = await glob("data/base/*.json");
    for (const file of baseFiles) {
        const data = JSON.parse(fs.readFileSync(file));
        const valid = validateBaseCocktail(data);
        if (!valid) {
            console.error(`Validation failed for ${file}:`);
            console.error(validateBaseCocktail.errors);
            hasErrors = true;
        }
    }

    // Validate translations
    const translationFiles = await glob("data/translations/**/*.json");
    for (const file of translationFiles) {
        const data = JSON.parse(fs.readFileSync(file));
        const valid = validateTranslation(data);
        if (!valid) {
            console.error(`Validation failed for ${file}:`);
            console.error(validateTranslation.errors);
            hasErrors = true;
        }

        // Check if base cocktail exists
        const baseFile = path.join("data/base", path.basename(file));
        if (!fs.existsSync(baseFile)) {
            console.error(`Translation ${file} exists but base cocktail does not`);
            hasErrors = true;
        }
    }

    // Check if all base cocktails have translations
    for (const file of baseFiles) {
        const baseName = path.basename(file);
        const languages = ["en", "de"];

        for (const lang of languages) {
            const translationFile = path.join("data/translations", lang, baseName);
            if (!fs.existsSync(translationFile)) {
                console.error(`Missing ${lang} translation for ${baseName}`);
                hasErrors = true;
            }
        }
    }

    if (hasErrors) {
        process.exit(1);
    }
}

validate().catch((error) => {
    console.error("Validation failed:", error);
    process.exit(1);
});
