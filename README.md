# Clubtech email signatures

The signature every Clubtech address sends from, plus the images it loads and the
steps to install it. One template, one placeholder swap per person.

- **`template.html`** — the signature with `{{PLACEHOLDERS}}`. Start here.
- **`signatures/`** — the filled versions, one file per person.
- **`images/`** — every image the signature loads. Served publicly by GitHub Pages
  from this repo, so a new signature needs no website deploy.

Live preview of any file in `signatures/`:
`https://clubtechglobal.github.io/email-signatures/signatures/matthew-gultom.html`

---

## Make a signature for a new person

**1. Add their headshot.** Export a **square PNG, 100 × 100 px**, named
`ctg_profile_<firstname>.png`, into `images/`. Square is correct — the rounding is
done in CSS, not baked into the file. Aim for under ~25 KB; the existing set runs
12–22 KB. On a Mac, from any square source image:

```bash
sips -Z 100 --setProperty format png ~/Downloads/their_photo.png \
  --out images/ctg_profile_theirname.png
```

If the source isn't square, crop it square first — `sips -Z` fits the long edge and
would letterbox a rectangle.

**2. Copy the template and fill in the five placeholders.**

```bash
cp template.html signatures/firstname-lastname.html
```

| Placeholder | Example | Notes |
|---|---|---|
| `{{FULL_NAME}}` | `Matthew Gultom` | appears twice — heading and image `alt` |
| `{{JOB_TITLE}}` | `Sales Development Representative` | |
| `{{PHONE}}` | `+62 811 750 1206` | country code, grouped with spaces |
| `{{EMAIL}}` | `matthew@clubtechglobal.com` | appears twice — `mailto:` and link text |
| `{{HEADSHOT_FILE}}` | `ctg_profile_matthew.png` | the file added in step 1 |

Or do it in one command:

```bash
sed -e 's|{{FULL_NAME}}|Jane Doe|g' \
    -e 's|{{JOB_TITLE}}|Account Manager|g' \
    -e 's|{{PHONE}}|+62 811 234 5678|g' \
    -e 's|{{EMAIL}}|jane@clubtechglobal.com|g' \
    -e 's|{{HEADSHOT_FILE}}|ctg_profile_jane.png|g' \
    template.html > signatures/jane-doe.html
```

Then check nothing was missed — this should print nothing:

```bash
grep -o '{{[A-Z_]*}}' signatures/jane-doe.html
```

**3. Commit and push.** The headshot must be pushed *before* the person installs
the signature, or their image loads as a broken icon. GitHub Pages republishes
within about a minute; confirm with:

```bash
curl -sIL -o /dev/null -w '%{http_code}\n' \
  https://clubtechglobal.github.io/email-signatures/images/ctg_profile_jane.png
```

`200` means it's live. Anything else — wait a moment and retry before installing.

**4. Install it** using the steps for their mail client below.

---

## Installing

The signature is HTML, so it can't be pasted as code — it has to be pasted as
*rendered content*. Open the file in a browser first, then copy from the page.

### Gmail (what most of the team uses)

1. Open the `signatures/<name>.html` file in Chrome — double-click it, or use the
   Pages preview link above.
2. Click on the page, then select the whole signature: **⌘A** (Mac) / **Ctrl+A**
   (Windows). Copy with **⌘C** / **Ctrl+C**.
3. In Gmail: **⚙ Settings → See all settings → General**, scroll to **Signature**.
4. **Create new**, name it, then click into the editing box and paste — **⌘V**.
   The images should appear immediately; if you see broken icons, the headshot
   hasn't finished publishing (step 3 above).
5. Under **Signature defaults**, set it for both *FOR NEW EMAILS USE* and *ON
   REPLY/FORWARD USE*.
6. Scroll to the bottom and **Save Changes** — easy to miss, and nothing applies
   without it.

Gmail strips a lot of CSS on paste but keeps everything this template relies on.
Don't retype inside the Gmail box; edit the HTML file and re-paste instead.

### Apple Mail

1. **Mail → Settings → Signatures**, pick the account, **+** to add one, and give
   it a name.
2. Leave the placeholder text for now and **quit Mail completely** (⌘Q).
3. Replace the signature file's contents with the HTML. Signatures live in
   `~/Library/Mail/V10/MailData/Signatures/` (the `V10` may differ by macOS
   version) as `ubiquitous_*.mailsignature` files — the newest one is the one just
   created. Keep the `Content-*` header lines at the top of that file and replace
   only the HTML beneath them.
4. Reopen Mail. If it re-renders the old text, uncheck **Always match my default
   message font** in Signatures settings.

The copy-paste route from step 2 of the Gmail instructions also works here and is
less fiddly — it just occasionally loses the rounded corners.

### Outlook

1. Open the HTML file in a browser and copy the rendered signature (**⌘A**, **⌘C**).
2. **Outlook → Settings → Signatures**, create one, paste into the box, save.

Outlook on Windows renders with Word's HTML engine, which **ignores
`border-radius`** — the headshot shows as a square and the outer card loses its
rounded corners. Everything else, including the banner, renders correctly. This is
expected and affects the whole team equally; there's no fix short of baking
transparent rounded corners into every PNG, which then breaks against dark
backgrounds.

---

## Image hosting

The signature loads its images over `https` from GitHub Pages:

```
https://clubtechglobal.github.io/email-signatures/images/<file>.png
```

Mail clients can't read local files, so the images must be on a public URL — this
repo being public is what makes that work. Keep it public.

The same images are also served from the marketing site at
`https://www.clubtechglobal.com/headshots/<file>.png`, which is where earlier
signatures pointed. Both work. This repo is the preferred host because publishing
a new headshot here is a `git push`, whereas the marketing site needs a full
release plus a root-privileged activation step on the production box.

If you ever do point a signature at the marketing site, **use the `www.` host**.
The bare `clubtechglobal.com/headshots/...` URL answers `308` and redirects to
`www.`, and not every mail client follows a redirect for an image.

### Things not to change

- **Filenames are forever.** A signature already pasted into someone's Gmail keeps
  requesting the exact URL it was installed with. Renaming or deleting an image in
  `images/` breaks every signature already out in the wild, including in mail
  already sent. To change someone's photo, add a **new** file
  (`ctg_profile_jane_v2.png`) and update their HTML — don't overwrite, since
  Gmail's image proxy caches aggressively and may serve the old one for days.
- **Don't restructure the tables.** The nested `<table>` layout and inline styles
  are deliberate. Email clients have no reliable flexbox, grid, or stylesheet
  support, and `<div>`-based versions of this signature collapse in Outlook.
- **`sig_banner.png` is 500 px wide** and sets the card's width. A different-width
  banner will visibly mismatch the section above it.
