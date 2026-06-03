# GitHub Notes

Target repo:

```text
https://github.com/DocDamage/kidgamemaker
```

At the time this Phase 1 package was prepared, the public repo only contained the starter README. The GitHub write connector available in the working session was not directly scoped to this repo, so this package includes a patch and apply script instead of a pushed commit.

## Apply Locally

From a local clone of `DocDamage/kidgamemaker`:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\apply_phase1.ps1 -SourcePath C:\path\to\kidgamemaker_phase1_contract_runner
```

Or copy the package contents into the repo root and commit:

```powershell
git add .
git commit -m "Start contract-first KidGameMaker runner"
git push
```
