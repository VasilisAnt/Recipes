# Οι συνταγές μου — recipe site

A Quarto website, built the same way as the beer-recipes example: Markdown/`.qmd`
recipe files, generated and organized by an R script, rendered by Quarto,
published on GitHub Pages.

## 1. One-time setup

Install these on your machine:

- **R** (you already have this) — https://cran.r-project.org
- **Quarto CLI** — https://quarto.org/docs/get-started/ (download the installer
  for your OS; no separate account needed)
- R packages used by the build script:

```r
install.packages(c("dplyr", "stringr", "stringi", "fs", "glue", "purrr", "tibble"))
```

## 2. Project layout

```
recipes-site/
├── _quarto.yml        # site config (nav, theme, output dir)
├── index.qmd           # auto-generated, filterable recipe listing
├── styles.css           # light custom CSS
├── R/
│   └── build_recipes.R  # recipe DATA lives here + generates the .qmd files
└── recipes/              # OUTPUT — created by the R script, one .qmd per recipe,
                           # grouped into subfolders by category
```

You should not need to hand-edit files inside `recipes/` — treat that folder as
generated output. To add, edit, or remove a recipe, change the `recipes_data`
tibble at the top of `R/build_recipes.R` and re-run the script.

## 3. Adding recipes

Open `R/build_recipes.R` and add a row to `recipes_data`:

```r
"Τίτλος της συνταγής",
"Κατηγορία",
"Το κείμενο της συνταγής, στο πρώτο ενικό, όπως τις γράφεις ήδη."
```

Use `\n\n` inside the body string wherever you want a paragraph break (e.g. to
separate a sub-recipe like the "για το βούτυρο" part in the steak recipe).

Then regenerate the `.qmd` files:

```r
source("R/build_recipes.R")
```

This is idempotent — re-running it just rewrites the files for whatever is
currently in `recipes_data`, so renamed/removed recipes need their old `.qmd`
file deleted manually if the title changes (the filename is derived from the
title).

## 4. Preview locally

From the `recipes-site/` folder:

```bash
quarto preview
```

This opens a live-reloading local preview in your browser.

## 5. Publish to GitHub Pages

```bash
# one-time: turn this folder into a git repo and push it to GitHub
git init
git add .
git commit -m "Initial recipe site"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main

# publish (builds the site into docs/ and pushes it)
quarto publish gh-pages
```

`quarto publish gh-pages` will ask you to confirm and will handle creating the
`gh-pages` branch (or you can instead point GitHub Pages at the `docs/` folder
on `main`, since `_quarto.yml` is already configured with `output-dir: docs`
— whichever you prefer in the repo's Settings → Pages).

After the first publish, your site will be live at:
`https://<your-username>.github.io/<repo-name>/`
