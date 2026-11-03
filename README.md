# signal-fft-matlab

*[English version below](#english)*

## Français

### Objectif

Simuler une **chaîne de mesure** sous MATLAB : un capteur fournit un signal, et la chaîne lui fait subir une **déformation** (offset, gain, non-linéarité). On cherche à **estimer** les paramètres de cette déformation, notamment par analyse **FFT**, puis à **corriger** le signal pour retrouver le signal d'origine.

Le signal de référence dure 1 s. Il est composé d'une valeur moyenne et d'une somme d'harmoniques :

s(t) = M + Σ Ai · sin(2π · Fi · t)

### Déformations modélisées

| Choix | Déformation | Modèle (`deform_signal`) |
|---|---|---|
| 1 | Offset | `sd = s + P0` |
| 2 | Gain | `sd = P1 · s` |
| 3 | Gain puis offset | `sd = P1 · s + P0` |
| 4 | Offset puis gain | `sd = P1 · (s + P0)` |
| 5 | Exponentielle | `sd = P0 · exp(P1 · s)` |
| 6 | Logarithme | `sd = P0 + P1 · sign(s) · log(1 + \|s\|)` |

### Méthode

- **Offset** : on part du signal centré, dont la raie à 0 Hz est nulle. Après déformation, la partie réelle de la raie à 0 Hz (c'est-à-dire la moyenne) donne directement P0, avec son signe.
- **Gain** : on ajoute +1 au signal centré pour disposer d'une composante continue connue. Le rapport des raies à 0 Hz (déformé / base) donne P1 : son module donne |P1| et sa phase (0 ou π) donne le signe.
- **Gain + offset, offset + gain** : le gain est mesuré sur le pic alternatif dominant (f > 0 Hz), où l'offset n'agit pas, avec la même règle module/phase. L'offset est ensuite déduit de la composante continue.
- **Exponentielle** : on linéarise avec ln|sd| = ln|P0| + P1 · s.
  - Comme la référence est centrée, la moyenne donne ln|P0|.
  - La valeur efficace et la phase sur l'harmonique dominante, comparées à celles connues de la référence (Ai, Fi), donnent P1.
- **Logarithme** : la partie logarithmique est impaire et la référence est antisymétrique sur une seconde, donc la moyenne du signal déformé donne P0.
  - Le signe de P1 se lit sur la phase de l'harmonique dominante.
  - Le module |P1| est l'unique valeur pour laquelle le signal reconstruit retrouve la valeur efficace de la référence. Il est obtenu avec `fzero`.
- **Correction** : on applique la transformation inverse avec les paramètres estimés.

Les estimations n'utilisent jamais les vrais paramètres. Pour l'exponentielle et le logarithme, elles n'utilisent pas non plus le signal de base, seulement ses caractéristiques connues (Ai, Fi). Ces estimations supposent :
- des fréquences Fi entières et distinctes ;
- des fréquences strictement comprises entre 0 et fe/2 ;
- une durée de 1 s.

### Utilisation

Il faut MATLAB **R2016b ou plus récent**. **Aucune toolbox** n'est nécessaire.

```matlab
demo
```

`demo.m` génère le signal et applique chacune des 6 déformations, d'abord avec des paramètres positifs, puis avec des paramètres négatifs. Pour chaque cas, il estime les paramètres, corrige le signal et ouvre une figure en trois parties :
- le signal de base et le signal déformé ;
- les spectres ;
- la correction.

Un tableau récapitulatif des paramètres vrais et estimés, avec l'erreur de reconstruction, s'affiche dans la console.

Chaque correcteur peut aussi être appelé seul :

```matlab
[s_base, s_deforme, s_corrige, gain, offset] = correcteGAIN_OFFSET(2, [5 3 2], [4 6 7], 100, -4, -1.5);
```

| Fichier | Rôle |
|---|---|
| `gene_signal.m` | Génération du signal de référence |
| `deform_signal.m` | Les 6 déformations |
| `correcteOFFSET.m`, `correcteGAIN.m`, `correcteGAIN_OFFSET.m`, `correcteOFFSET_GAIN.m` | Estimation et correction des déformations linéaires |
| `correcteExponentielle.m`, `correcteLogarithmique.m` | Estimation et correction des déformations non linéaires |
| `echelle_reference.m` | Facteur d'échelle signé par rapport à la référence (valeur efficace et phase) |
| `trace_resultats.m` | Tracés communs : spectres et correction |
| `demo.m` | Démonstration complète sans interface |

### Images

Ces captures proviennent de l'interface d'origine, avant les corrections listées plus bas.

**Spectre FFT du signal** (raie dominante à 4 Hz)

![Spectre FFT](images/spectre-fft.png)

**Correction d'un gain** : signal d'origine (bleu pointillé) et signal corrigé (vert)

![Correction du gain](images/correction-gain.png)

**Rapport d'analyse exporté** : signal original, signal déformé, spectre et signal corrigé

![Rapport d'analyse](images/rapport-analyse.png)

### Contexte

Ce projet a été réalisé en équipe de trois dans le cadre de l'ECUE 325 à l'EPISEN. L'interface App Designer n'a pas été conservée : seules les fonctions sont publiées ici.

### Bugs corrigés après le rendu

1. **Composante continue sans signe** : `abs(fft(...))` perdait le signe de la raie à 0 Hz. Un offset de −2 était ainsi mesuré à +2, et un gain de −3 à +3. La composante continue est désormais lue avec `real(fft(...))`, c'est-à-dire la moyenne.
2. **Signe du gain** : il est maintenant déterminé par la phase du rapport des raies (0 ou π).
3. **Exponentielle** :
   - le correcteur supposait `exp(λ·s) + μ` alors que `deform_signal` appliquait `P0·exp(P1·s)` ;
   - l'estimation utilisait la vraie valeur de λ.

   Les deux utilisent désormais le même modèle, linéarisé par ln|sd|.
4. **Logarithme** :
   - `log(s)` d'un signal centré produisait des valeurs complexes ;
   - le correcteur supposait un autre modèle ;
   - la correction utilisait `sign(s_base)`, c'est-à-dire le signal d'origine.

   Le modèle est remplacé par un logarithme symétrique inversible, commun aux deux fonctions, et l'estimation se fait sans le signal de base.
5. **Tracé « Origine »** : il affichait le signal non centré, de moyenne M, et non le signal de base réellement déformé puis corrigé. Les courbes paraissaient donc décalées même quand la correction était parfaite.
6. **Tracés dupliqués** : le code de tracé, répété dans les six correcteurs, est factorisé dans `trace_resultats.m`.
7. **Robustesse** :
   - un gain nul ou l'absence d'harmonique provoque désormais un message d'erreur explicite au lieu d'un `NaN` ;
   - les paramètres des déformations non linéaires s'appellent P0/P1, comme dans `deform_signal`.

---

<a id="english"></a>

## English

### Goal

Simulate a **measurement chain** in MATLAB: a sensor produces a signal, and the chain applies a **distortion** to it (offset, gain, non-linearity). The goal is to **estimate** the distortion parameters, mainly through **FFT** analysis, then **correct** the signal to recover the original.

The reference signal lasts 1 s. It is made of a mean value plus a sum of harmonics:

s(t) = M + Σ Ai · sin(2π · Fi · t)

### Modelled distortions

| Choice | Distortion | Model (`deform_signal`) |
|---|---|---|
| 1 | Offset | `sd = s + P0` |
| 2 | Gain | `sd = P1 · s` |
| 3 | Gain then offset | `sd = P1 · s + P0` |
| 4 | Offset then gain | `sd = P1 · (s + P0)` |
| 5 | Exponential | `sd = P0 · exp(P1 · s)` |
| 6 | Logarithm | `sd = P0 + P1 · sign(s) · log(1 + \|s\|)` |

### Method

- **Offset**: the base signal is centred, so its 0 Hz bin is zero. After distortion, the real part of the 0 Hz bin (that is, the mean) gives P0 directly, sign included.
- **Gain**: +1 is added to the centred signal so that its DC component is known. The ratio of the 0 Hz bins (distorted / base) gives P1: its magnitude gives |P1| and its phase (0 or π) gives the sign.
- **Gain + offset, offset + gain**: the gain is measured on the dominant AC peak (f > 0 Hz), where the offset has no effect, using the same magnitude/phase rule. The offset is then derived from the DC component.
- **Exponential**: linearised with ln|sd| = ln|P0| + P1 · s.
  - Since the reference is centred, the mean gives ln|P0|.
  - The RMS value and the phase on the dominant harmonic, compared with the known reference (Ai, Fi), give P1.
- **Logarithm**: the logarithmic part is odd and the reference is antisymmetric over one second, so the mean of the distorted signal gives P0.
  - The sign of P1 is read from the phase of the dominant harmonic.
  - |P1| is the unique value for which the reconstructed signal matches the reference RMS. It is found with `fzero`.
- **Correction**: the inverse transform is applied with the estimated parameters.

The estimators never use the true parameters. For the exponential and logarithm cases, they do not use the base signal either, only its known characteristics (Ai, Fi). The estimators assume:
- integer, distinct frequencies Fi;
- frequencies strictly between 0 and fe/2;
- a duration of 1 s.

### Usage

Requires MATLAB **R2016b or later**. **No toolbox** is needed.

```matlab
demo
```

`demo.m` generates the signal and applies each of the 6 distortions, first with positive parameters, then with negative ones. For each case it estimates the parameters, corrects the signal and opens a three-part figure:
- base and distorted signals;
- spectra;
- correction.

A summary table of true and estimated parameters, with the reconstruction error, is printed in the console.

Each corrector can also be called on its own:

```matlab
[s_base, s_deforme, s_corrige, gain, offset] = correcteGAIN_OFFSET(2, [5 3 2], [4 6 7], 100, -4, -1.5);
```

| File | Role |
|---|---|
| `gene_signal.m` | Reference signal generation |
| `deform_signal.m` | The 6 distortions |
| `correcteOFFSET.m`, `correcteGAIN.m`, `correcteGAIN_OFFSET.m`, `correcteOFFSET_GAIN.m` | Estimation and correction of linear distortions |
| `correcteExponentielle.m`, `correcteLogarithmique.m` | Estimation and correction of non-linear distortions |
| `echelle_reference.m` | Signed scale factor relative to the reference (RMS and phase) |
| `trace_resultats.m` | Shared plots: spectra and correction |
| `demo.m` | Full demonstration without a GUI |

### Images

These screenshots come from the original interface, before the fixes listed below.

- `images/spectre-fft.png`: FFT spectrum of the signal (dominant line at 4 Hz)
- `images/correction-gain.png`: gain correction, original signal (dashed blue) vs corrected signal (green)
- `images/rapport-analyse.png`: exported analysis report (original, distorted, spectrum, corrected)

### Context

This project was carried out by a team of three as part of course unit ECUE 325 at EPISEN. The App Designer interface was not kept: only the functions are published here.

### Bugs fixed after submission

1. **Unsigned DC component**: `abs(fft(...))` lost the sign of the 0 Hz bin. An offset of −2 was measured as +2, and a gain of −3 as +3. The DC component is now read with `real(fft(...))`, that is, the mean.
2. **Gain sign**: now given by the phase of the bin ratio (0 or π).
3. **Exponential**:
   - the corrector assumed `exp(λ·s) + μ` while `deform_signal` applied `P0·exp(P1·s)`;
   - the estimation used the true value of λ.

   Both now share the same model, linearised through ln|sd|.
4. **Logarithm**:
   - `log(s)` of a centred signal produced complex values;
   - the corrector assumed a different model;
   - the correction used `sign(s_base)`, that is, the original signal.

   The model is replaced by an invertible symmetric logarithm shared by both functions, and the estimation no longer uses the base signal.
5. **"Original" plot**: it showed the uncentred signal, with mean M, instead of the base signal that was actually distorted and then corrected. The curves therefore looked offset even when the correction was perfect.
6. **Duplicated plotting code**: the plotting block, repeated in all six correctors, is now factored into `trace_resultats.m`.
7. **Robustness**:
   - a zero gain or a missing harmonic now raises an explicit error instead of producing `NaN`;
   - the non-linear distortion parameters are named P0/P1, as in `deform_signal`.
