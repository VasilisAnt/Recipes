# build_recipes.R
# ----------------------------------------------------------------------------
# Generates one .qmd file per recipe under recipes/<category>/<slug>.qmd
# Run this whenever you add or edit recipes in the `recipes_data` tibble below,
# then re-render the site with `quarto render`.
# ----------------------------------------------------------------------------

library(dplyr)
library(stringr)
library(stringi)
library(fs)
library(glue)

# ---- 1. Recipe data ---------------------------------------------------------
# Add new recipes here as additional rows. `body` accepts multi-line text
# (use \n\n for paragraph breaks); Markdown formatting inside body works as-is.

recipes_data <- tibble::tribble(
  ~title, ~category, ~body,

  "Κοτομπουκιές κοτόπουλου",
  "Κοτόπουλο",
  "Κόβω φιλέτο στήθος κοτόπουλου σε μικρά κομμάτια. Τα βάζω σε ένα μπολ και προσθέτω αλάτι, πιπέρι, πάπρικα και αλεύρι. Μετά τα περνάω από αυγό και panko. Τα βάζω στο air fryer στους 190°C για 11 λεπτά, γυρίζοντάς τα από την άλλη πλευρά στη μέση του χρόνου ψησίματος.",

  "Σπανάκι με σολομό",
  "Ψάρι & θαλασσινά",
  "Τσιγαρίζω κρεμμύδι στο τηγάνι και μετά προσθέτω κατεψυγμένο σπανάκι (750 γρ.), άνηθο, μισό ζωμό ψαριού και νερό, και αφήνω να βράσει λίγο. Στη συνέχεια κόβω σε κύβους φρέσκο σολομό, τον προσθέτω στο σπανάκι και σκεπάζω το τηγάνι με το καπάκι. Δεν το αφήνω πολλή ώρα, μόνο μέχρι να ψηθεί ο σολομός. Στο τέλος προσθέτω λεμόνι.",

  "Κρέπες «Σοφία»",
  "Γλυκά",
  "Χρειάζομαι 1 λίτρο γάλα, 330 ml σπράιτ, 6 αυγά, 30 γρ. ζάχαρη, 15 γρ. αλάτι, 1 σφηνάκι κονιάκ, 2 βανίλιες, περίπου 1 κιλό αλεύρι και 60 γρ. βούτυρο ή Vitam, λιωμένο. Η συνταγή αποδίδει περίπου 20 κρέπες.",

  "Μπριζόλα κομμάτια με πουρέ πατάτας και σπαράγγια",
  "Κρέας",
  "Κόβω σε μικρά τετράγωνα κομμάτια μοσχαρίσια μπριζόλα (sirloin ή entrecote), 500 γρ., για 2 άτομα. Προσθέτω Worcestershire sauce, αλάτι, πιπέρι και buttery steakhouse seasoning. Βάζω ελαιόλαδο στο τηγάνι και ψήνω τα κομμάτια από κάθε πλευρά για 2 λεπτά, σε μέτρια προς δυνατή φωτιά. Χαμηλώνω τη θερμοκρασία και προσθέτω το βούτυρο.\n\nΓια το βούτυρο χρειάζομαι: 2 κουταλιές σούπας βούτυρο, μισή κουταλιά σούπας μουστάρδα Dijon, chives, μαϊντανό, 2 κουταλάκια γλυκού λιωμένο σκόρδο, 1 κουταλάκι γλυκού χυμό λεμονιού και 1/4 κουταλάκι γλυκού πιπέρι καγιέν, πάπρικα, αλάτι και πιπέρι.\n\nΑφού ανακατέψω το βούτυρο με την μπριζόλα, βγάζω το κρέας και βάζω τα σπαράγγια στο ίδιο τηγάνι. Σκεπάζω με το καπάκι για να ψηθούν πιο γρήγορα, περίπου 8 λεπτά, μέχρι να μαλακώσουν. Για τον πουρέ χρειάζομαι πατάτες, αλάτι, βούτυρο και λίγο γάλα."
)

# ---- 2. Helpers --------------------------------------------------------------

# Transliterate Greek -> ASCII for clean, URL-safe file names
slugify <- function(x) {
  x |>
    stri_trans_general("Greek-Latin/BGN; Latin-ASCII") |>
    str_to_lower() |>
    str_replace_all("[^a-z0-9]+", "-") |>
    str_replace_all("(^-+|-+$)", "")
}

write_recipe_qmd <- function(title, category, body) {
  cat_slug <- slugify(category)
  file_slug <- slugify(title)

  out_dir <- path("recipes", cat_slug)
  dir_create(out_dir)

  out_file <- path(out_dir, glue("{file_slug}.qmd"))

  # Escape any double quotes in the title for the YAML front matter
  title_escaped <- str_replace_all(title, '"', '\\\\"')

  content <- glue(
    "---\n",
    "title: \"{title_escaped}\"\n",
    "categories: [\"{category}\"]\n",
    "---\n",
    "\n",
    "{body}\n"
  )

  write_lines(content, out_file)
  out_file
}

# ---- 3. Run --------------------------------------------------------------

dir_create("recipes")

written <- purrr::pmap_chr(
  recipes_data,
  function(title, category, body) as.character(write_recipe_qmd(title, category, body))
)

cat(glue("Wrote {length(written)} recipe files:\n"))
cat(paste(" -", written), sep = "\n")
