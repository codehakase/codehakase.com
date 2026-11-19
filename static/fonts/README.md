# Self-hosted fonts

PT Serif v19 and Fira Code v27 are served locally to avoid a render-blocking
Google Fonts stylesheet and additional cross-origin connections.

The unmodified WOFF2 files were downloaded from Google Fonts on 2026-11-19.
`assets/css/fonts.css` retains the original weights, styles, Unicode ranges,
and `font-display: swap`. A browser downloads only the subsets it needs.
Each filename includes a SHA-256 prefix so it can be cached immutably.

Licenses are included in each family directory, copied from the Google Fonts
repository:

- https://github.com/google/fonts/blob/main/ofl/ptserif/OFL.txt
- https://github.com/google/fonts/blob/main/ofl/firacode/OFL.txt

Source stylesheet:

https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;500&family=PT+Serif:ital,wght@0,400;0,700;1,400;1,700&display=swap

When updating a font, download the current WOFF2 subsets, retain its license,
use new content hashes in filenames, and update `assets/css/fonts.css`.

The font-face declarations are inlined with the page styles, so fonts are
discovered without fetching another stylesheet. Fonts intentionally load on
demand: a Chrome comparison at 100 ms network latency showed that preloading
the body font delayed first content compared with letting `font-display: swap`
show the fallback immediately.

## Download sources

- `/fonts/fira-code-v27/variable-cyrillic-ext.45638fab5a7c.woff2`: https://fonts.gstatic.com/s/firacode/v27/uU9NCBsR6Z2vfE9aq3bh0NSDqFGedCMX.woff2
- `/fonts/fira-code-v27/variable-cyrillic.98651a0dc896.woff2`: https://fonts.gstatic.com/s/firacode/v27/uU9NCBsR6Z2vfE9aq3bh2dSDqFGedCMX.woff2
- `/fonts/fira-code-v27/variable-greek-ext.54147107b78e.woff2`: https://fonts.gstatic.com/s/firacode/v27/uU9NCBsR6Z2vfE9aq3bh0dSDqFGedCMX.woff2
- `/fonts/fira-code-v27/variable-greek.f8a20a104de9.woff2`: https://fonts.gstatic.com/s/firacode/v27/uU9NCBsR6Z2vfE9aq3bh3tSDqFGedCMX.woff2
- `/fonts/fira-code-v27/variable-symbols2.905afdfcb396.woff2`: https://fonts.gstatic.com/s/firacode/v27/uU9NCBsR6Z2vfE9aq3bhZ_Wmh3mUfBsu_Q.woff2
- `/fonts/fira-code-v27/variable-latin-ext.e08f04687410.woff2`: https://fonts.gstatic.com/s/firacode/v27/uU9NCBsR6Z2vfE9aq3bh09SDqFGedCMX.woff2
- `/fonts/fira-code-v27/variable-latin.d32d5b5a7c97.woff2`: https://fonts.gstatic.com/s/firacode/v27/uU9NCBsR6Z2vfE9aq3bh3dSDqFGedA.woff2
- `/fonts/pt-serif-v19/italic-400-cyrillic-ext.574d529d6a76.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRTQgYoZZY2vCFuvAFT_rC1cgT9rct48Q.woff2
- `/fonts/pt-serif-v19/italic-400-cyrillic.6c04cd23c571.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRTQgYoZZY2vCFuvAFT_rm1cgT9rct48Q.woff2
- `/fonts/pt-serif-v19/italic-400-latin-ext.6ca06514dc77.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRTQgYoZZY2vCFuvAFT_rO1cgT9rct48Q.woff2
- `/fonts/pt-serif-v19/italic-400-latin.219a8e6238f7.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRTQgYoZZY2vCFuvAFT_r21cgT9rcs.woff2
- `/fonts/pt-serif-v19/italic-700-cyrillic-ext.74e166eb4986.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRQQgYoZZY2vCFuvAFT9gaQZyTfoOFC-I2irw.woff2
- `/fonts/pt-serif-v19/italic-700-cyrillic.c28540eacdd5.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRQQgYoZZY2vCFuvAFT9gaQZy3foOFC-I2irw.woff2
- `/fonts/pt-serif-v19/italic-700-latin-ext.b0b1062d323a.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRQQgYoZZY2vCFuvAFT9gaQZyffoOFC-I2irw.woff2
- `/fonts/pt-serif-v19/italic-700-latin.c4ccc041f760.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRQQgYoZZY2vCFuvAFT9gaQZynfoOFC-I0.woff2
- `/fonts/pt-serif-v19/normal-400-cyrillic-ext.3a7b3ec02adf.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRVQgYoZZY2vCFuvAFbzr-_dSb_nco.woff2
- `/fonts/pt-serif-v19/normal-400-cyrillic.a60d74d7dc6d.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRVQgYoZZY2vCFuvAFSzr-_dSb_nco.woff2
- `/fonts/pt-serif-v19/normal-400-latin-ext.3a274c5ae6fd.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRVQgYoZZY2vCFuvAFYzr-_dSb_nco.woff2
- `/fonts/pt-serif-v19/normal-400-latin.202b8aa6108e.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRVQgYoZZY2vCFuvAFWzr-_dSb_.woff2
- `/fonts/pt-serif-v19/normal-700-cyrillic-ext.117410c3c0e4.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRSQgYoZZY2vCFuvAnt66qfVyvVp8NAyIw.woff2
- `/fonts/pt-serif-v19/normal-700-cyrillic.8e7689d80213.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRSQgYoZZY2vCFuvAnt66qWVyvVp8NAyIw.woff2
- `/fonts/pt-serif-v19/normal-700-latin-ext.1895f8fe0add.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRSQgYoZZY2vCFuvAnt66qcVyvVp8NAyIw.woff2
- `/fonts/pt-serif-v19/normal-700-latin.57d3ae6c4b78.woff2`: https://fonts.gstatic.com/s/ptserif/v19/EJRSQgYoZZY2vCFuvAnt66qSVyvVp8NA.woff2
